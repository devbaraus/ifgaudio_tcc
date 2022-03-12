%% MFCC
clc;
clear;

qtd_augmentation = 1;
sec = 1;
coeff = 24;

load(sprintf('ifgaudioData%iseg.mat', sec));
intensidade = 0;

return_data = pyrunfile("split_data.py", "return_data", ...
    data=ifgaudioData.Data, ...
    labels=ifgaudioData.Labels(:,1)');

svm_params.X_train = double(return_data{'X_train'});
svm_params.X_test = double(return_data{'X_test'});
svm_params.y_train = double(return_data{'y_train'});
svm_params.y_test = double(return_data{'y_test'});

size_train = size(svm_params.X_train);
if intensidade ~= 0
    X_train_augmentation = zeros((qtd_augmentation + 1) * size_train(1), size_train(2));
else
    X_train_augmentation = zeros(size_train(1), size_train(2));
end
X_train_augmentation(1:size_train(1),:) = svm_params.X_train;

SNR = mag2db(1/intensidade);
media_audios = mean(ifgaudioData.Data,1);
potencia_sinal = rms(media_audios)^2;
tamanho_segmento = size(media_audios,2);

ruido_aditivo = zeros(1,tamanho_segmento);

% augmentation train
if qtd_augmentation > 0 && intensidade ~= 0
    for aug = 1:qtd_augmentation
        for i = 1 : size_train(1)
            ruido_aditivo = randn(1, tamanho_segmento)*std(media_audios)/db2mag(SNR);
            position = size_train(1) * aug + i;
            X_train_augmentation(position, :) = svm_params.X_train(i,:) + ruido_aditivo;
        end
    end
else
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

size_rep = size(mfcc(svm_params.X_train(1,:)', fs, NumCoeffs=coeff));
size_rep = size_rep(1) * size_rep(2);
X_train_representation = zeros(size(svm_params.X_train,1), size_rep);
X_test_representation = zeros(size(svm_params.X_test,1), size_rep);

% representação train
parfor i = 1:size(X_train_representation,1)
    segment_rep = mfcc(svm_params.X_train(i,:)', fs, NumCoeffs=coeff);
    segment_rep = reshape(segment_rep,[], size_rep);
    X_train_representation(i,:) = segment_rep;
end

% representacao teste
parfor i = 1:size(X_test_representation,1)
    segment_rep = mfcc(svm_params.X_test(i,:)', fs, NumCoeffs=coeff);
    segment_rep = reshape(segment_rep,[], size_rep);
    X_test_representation(i,:) = segment_rep;
end

return_data = pyrunfile("encode_split.py", "return_data", ...
    X_train=X_train_representation, ...
    X_test=X_test_representation, ...
    y_train=svm_params.y_train, ...
    y_test=svm_params.y_test);

svm_train.X_train=double(return_data{'X_train'});
svm_train.X_test=double(return_data{'X_test'});
svm_train.y_train=double(return_data{'y_train'});
svm_train.y_test=double(return_data{'y_test'});

save('svm_train_mfcc_aug1_24coeff_0noise', 'svm_train');

