load('./ifgaudioData2seg.mat');

fs = 24000;

audio1 = reshape(ifgaudioData.Data(1,:), [], 1);
sizeRep = size(mfcc(audio1, fs));

data = ifgaudioData.Data;
labels = string(ifgaudioData.Labels(:, 1));
classes = string(cellstr(unique(labels,'rows')));

% %% Pego as quantidade de classes
% qtdClasses = 20;
% idx = ismember(labels, classes(1:qtdClasses));
% 
% data = data(idx, :);
% labels = labels(idx, :);

%%
qtdSegmentos = size(data,1);
representationData = zeros(qtdSegmentos, sizeRep(1) * sizeRep(2));

for i = 1 : qtdSegmentos
    audioIn = reshape(ifgaudioData.Data(i,:), [], 1);
    audioRep = mfcc(audioIn, fs);
    audioRep = reshape(audioRep, [], 1);
    
    representationData(i,:) = audioRep;
end
%%
[trainInd,valInd,testInd] = dividerand(qtdSegmentos,0.6,0.2,0.2);

trainData = representationData(trainInd, :);
valiData = representationData(valInd, :);
testData = representationData(testInd, :);
trainLabels = labels(trainInd, :);
testLabels = labels(valInd, :);
validLabels = labels(testInd, :);

% data = [trainData; testData];
% labels = cellstr([trainLabels; testLabels]);
%%
template = templateSVM(...
    'KernelFunction','polynomial',...
    'PolynomialOrder',2,...
    'KernelScale','auto',...
    'BoxConstraint',1,...
    'Standardize',true);

% model = fitcecoc(...
%     data,...
%     labels,...
%     'Learners',template,...
%     'Coding','onevsone',...
%     'ClassNames',classes);

% kfoldmodel = crossval(model,'KFold',3);
% classLabels = kfoldPredict(kfoldmodel);
% loss = kfoldLoss(kfoldmodel)*100;
model = fitcecoc(...
     trainData,...
     trainLabels,...
     'Learners',template,...
     'Coding','onevsone',...
     'ClassNames',classes);
predLabels = predict(model,testData);
save('workspace.mat')