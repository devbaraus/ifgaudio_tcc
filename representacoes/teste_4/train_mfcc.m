if exist('is_pipeline', 'var') == false
    sec = 2;
    intensidade = 0;
    load(sprintf('./ifgaudioData%iseg.mat', sec));
end

save_audios = false;

fs = ifgaudioData.Labels{1,2};

if save_audios
    return_data = pyrunfile("split_data.py", "return_data", ...
        data=ifgaudioData.Data, ...
        labels=ifgaudioData.Labels(:,1)');

    audios_to_save = double(return_data{'X_test'});
    audios_name = double(return_data{'y_test'})';

    parfor i = 1:size(audios_to_save,1)
        audiowrite(sprintf('./segmentos/p_%i_%i.wav', audios_name(i), i), ...
            audios_to_save(i,:)', fs)
    end
end

coeff_tests = [13, 18, 24, 30];
% coeff_tests = [13];
fold_acc = zeros(size(coeff_tests,2),4);

for idxcoeff = 1:size(coeff_tests,2)
    size_rep = size(mfcc(ifgaudioData.Data(1,:)', fs, NumCoeffs=coeff_tests(1,idxcoeff)));
    size_rep = size_rep(1) * size_rep(2);
    data_representation = zeros(size(ifgaudioData.Data,1), size_rep);
    
    parfor i = 1:size(ifgaudioData.Data,1)
        segment_rep = mfcc(ifgaudioData.Data(i,:)', fs, NumCoeffs=coeff_tests(1,idxcoeff));
        segment_rep = reshape(segment_rep,[], size_rep);
        data_representation(i,:) = segment_rep;
    end
    
    run('train_svm.m');

    fold_acc(idxcoeff,1) = folds_macro;
    fold_acc(idxcoeff,2) = folds_micro;
    fold_acc(idxcoeff,3) = predict_macro;
    fold_acc(idxcoeff,4) = predict_micro;
end

figure(1);
plot(fold_acc, 'LineWidth',4);
title(sprintf('F1 Score MFCC - %i seg - %2.2fdB', sec, snr_media));
legend({'fold macro', 'fold micro', 'predicao macro', 'predicao micro'});
set(gca,'xticklabel',{'13 coeffs','18 coeffs','24 coeffs', '30 coeffs'}, 'xtick', 1:4);
savefig(sprintf('./images/mfcc_%isec_%2.2fruido.fig', sec, intensidade(intensidade_idx) * 100));
close();
