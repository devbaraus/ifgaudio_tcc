%% stftgt
clc;
clear;

qtd_augmentation = 1;
algo = 'stft';
if ~exist(algo,'dir')
    mkdir(strcat('images/',algo))
end

for sec = [4,2,1]
    load(sprintf('ifgaudioData%iseg.mat', sec));
    intensidade = 0:0.1:1;
    intensidade_acc = zeros(size(intensidade,2), 4);

    for intensidade_idx = 1:size(intensidade,2)
        return_data = pyrunfile("split_data.py", "return_data", ...
            data=ifgaudioData.Data, ...
            labels=ifgaudioData.Labels(:,1)');

        svm_params.X_train = double(return_data{'X_train'});
        svm_params.X_test = double(return_data{'X_test'});
        svm_params.y_train = double(return_data{'y_train'});
        svm_params.y_test = double(return_data{'y_test'});

        size_train = size(svm_params.X_train);
        X_train_augmentation = zeros((qtd_augmentation + 1) * size_train(1), size_train(2));
        X_train_augmentation(1:size_train(1),:) = svm_params.X_train;

        SNR = mag2db(1/intensidade(intensidade_idx));
        media_audios = mean(ifgaudioData.Data,1);
        potencia_sinal = rms(media_audios)^2;
        tamanho_segmento = size(media_audios,2);

        ruido_aditivo = zeros(1,tamanho_segmento);

        % augmentation train
        if qtd_augmentation > 0
            for aug = 1:qtd_augmentation
                for i = 1 : size_train(1)
                    ruido_aditivo = randn(1, tamanho_segmento)*std(media_audios)/db2mag(SNR);
                    position = size_train(1) * aug + i;
                    X_train_augmentation(position, :) = svm_params.X_train(i,:) + ruido_aditivo;
                end
            end
        elseif qtd_augmentation == 0
            for i = 1 : size_train(1)
                ruido_aditivo = randn(1, tamanho_segmento)*std(media_audios)/db2mag(SNR);
                X_train_augmentation(i, :) = svm_params.X_train(i,:) + ruido_aditivo;
            end
        end


        % ruido em segmentos aleatórios do test
        for i = 1 : size(svm_params.X_test,1)
            if rand(1,1) < 0.2
                ruido_aditivo = randn(1, tamanho_segmento)*std(media_audios)/db2mag(SNR);
                svm_params.X_test(i, :) = svm_params.X_test(i,:) + ruido_aditivo;
            end
        end

        svm_params.X_train = X_train_augmentation;
        svm_params.y_train = repmat(svm_params.y_train, 1, qtd_augmentation + 1);

        idx2keep_rows = sum(abs(svm_params.X_train),2)>0;
        svm_params.X_train = svm_params.X_train(idx2keep_rows, :);
        svm_params.y_train = svm_params.y_train(:,idx2keep_rows);

        idx2keep_rows = sum(abs(svm_params.X_test),2)>0;
        svm_params.X_test = svm_params.X_test(idx2keep_rows, :);
        svm_params.y_test = svm_params.y_test(:,idx2keep_rows);

        snr_media = snr(media_audios, ruido_aditivo);

        fs = ifgaudioData.Labels{1,2};

        coeff_tests = [13, 18, 24, 30];
        fold_acc = zeros(size(coeff_tests,2),4);

        for idxcoeff = 1:size(coeff_tests,2)
            size_rep = size(stft(svm_params.X_train(1,:)', fs));
            size_rep = size_rep(1) * size_rep(2);
            X_train_representation = zeros(size(svm_params.X_train,1), size_rep);
            X_test_representation = zeros(size(svm_params.X_test,1), size_rep);

            % representação train
            parfor i = 1:size(X_train_representation,1)
                segment_rep = stft(svm_params.X_train(i,:)', fs);
                segment_rep = reshape(segment_rep,[], size_rep);
                X_train_representation(i,:) = segment_rep;
            end
            
            % representacao teste
            parfor i = 1:size(X_test_representation,1)
                segment_rep = stft(svm_params.X_test(i,:)', fs);
                segment_rep = reshape(segment_rep,[], size_rep);
                X_test_representation(i,:) = segment_rep;
            end

            return_data = pyrunfile("encode_split.py", "return_data", ...
                X_train=X_train_representation, ...
                X_test=X_test_representation, ...
                y_train=svm_params.y_train, ...
                y_test=svm_params.y_test);

            X_train=return_data{'X_train'};
            X_test=return_data{'X_test'};
            y_train=return_data{'y_train'};
            y_test=return_data{'y_test'};

            return_data = pyrunfile("train_svm.py", "return_data", ...
                X_train=X_train,...
                y_train=y_train);

            scores = struct(return_data{'scores'});
            folds_macro = scores.test_f1_macro.mean();
            folds_micro = scores.test_f1_micro.mean();
            [el, idx] = max(double(scores.test_f1_micro));

            return_data = pyrunfile("predict_svm.py", "return_data", ...
                X_test=X_test,...
                y_test=y_test,...
                estimator=scores.estimator(idx));

            predict_return = struct(return_data);
            predict_macro = predict_return.f1_macro;
            predict_micro = predict_return.f1_micro;

            fold_acc(idxcoeff,1) = folds_macro;
            fold_acc(idxcoeff,2) = folds_micro;
            fold_acc(idxcoeff,3) = predict_macro;
            fold_acc(idxcoeff,4) = predict_micro;
        end

        figure(1);
        plot(fold_acc, 'LineWidth',4);

        title(sprintf('F1 Score %s - %i seg - %2.2fdB', upper(algo), sec, snr_media));
        legend({'fold macro', 'fold micro', 'predicao macro', 'predicao micro'});
        set(gca,'xticklabel',{'13 coeffs','18 coeffs','24 coeffs', '30 coeffs'}, 'xtick', 1:4);
        savefig(sprintf('./images/%s/%s_%isec_%2.0fruido.fig', algo, algo, sec, intensidade(intensidade_idx) * 100));
        saveas(gca,sprintf('./images/%s/%s_%isec_%2.0fruido.png',algo, algo, sec, intensidade(intensidade_idx) * 100))

        close();

        intensidade_acc(intensidade_idx,:) = fold_acc(:, 4)';
    end

    figure(1);
    plot(intensidade_acc, 'LineWidth',4);
    title(sprintf('Acurácia %s - %i seg',upper(algo), sec));
    legend({'13 coeffs','18 coeffs','24 coeffs', '30 coeffs'});
    savefig(sprintf('./images/%s/%s_%isec.fig', algo, algo, sec));
    close();
end