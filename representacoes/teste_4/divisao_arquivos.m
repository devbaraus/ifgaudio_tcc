set(0,'DefaultFigureWindowStyle','docked');
clear;
clc;

trim = true;
concat = false;
overlap = 0;
tempoSegmento = 1;

rootdir = sprintf('base_pessoas_trim');


filelist = dir(fullfile(rootdir, '**\*.wav'));  %get list of files and folders in any subfolder
filelist = filelist(~[filelist.isdir]);  %remove folders from list

filelistPath = cell(length(filelist),1);

for i = 1 : length(filelist)
    filelistPath{i} = strcat(filelist(i).folder, '\',filelist(i).name);
end

filelistPath = string(filelistPath);
%%
fs = 24000;
numArquivos = size(filelistPath,1);
overlap = 1 - overlap;
tamanhoFsSegmento = fs * tempoSegmento;
tamanhoFsOverlapSegmento = tamanhoFsSegmento * overlap;

qtdSegmentosArr = zeros(numArquivos,1);

parfor aa = 1:numArquivos
	[audioIn, fs] = audioread(filelistPath(aa, :));
	audioIn = mean(audioIn, 2);
    audioIn = resample(audioIn, 24000,fs);
    fs = 24000;
    
    qtdSegmentos = 0;
    flag = 1;
    startSeg = 0;

    while (flag == 1)
        if(startSeg + tamanhoFsSegmento > size(audioIn,1))
            flag = 0;
        else
            qtdSegmentos = qtdSegmentos + 1;
            startSeg = startSeg + tamanhoFsOverlapSegmento;
        end 
    end
    
    qtdSegmentosArr(aa,:) = qtdSegmentos;
end


%% Guarda os segmentos de cada audio
maxQtdSegmentos = max(qtdSegmentosArr);
segmentosAudiosMat = zeros(numArquivos*maxQtdSegmentos,tamanhoFsSegmento);
% labelsAudios = cell(numArquivos*maxQtdSegmentos,4);
labelsAudios = cell(numArquivos*maxQtdSegmentos,1,2);

contadorPos = 1;
for aa = 1:numArquivos
    filename = filelistPath(aa,:);
    [audioIn, fs] = audioread(filename);
	audioIn = mean(audioIn, 2);
    audioIn = resample(audioIn, 24000,fs);
    fs = 24000;
    
    classeAudio = split(filelist(aa).folder,'\');
    classeAudio = classeAudio(length(classeAudio));
    
    for i = 1:qtdSegmentosArr(aa,1)
        comecoSegmento = (i - 1) * fs * tempoSegmento * overlap;
        fimSegmento = comecoSegmento + fs * tempoSegmento;
        segmentoAudio = audioIn(comecoSegmento + 1:fimSegmento,1);
        segmentosAudiosMat(contadorPos,:) = segmentoAudio;
        labelsAudios{contadorPos,1} = str2num(string(classeAudio));
        labelsAudios{contadorPos,2} = fs;

        contadorPos = contadorPos + 1;
    end
end
%%
ifgaudioData.Data = segmentosAudiosMat(1:contadorPos-1,:);
ifgaudioData.Labels = labelsAudios(1:contadorPos-1,:);

hist_classes = countlabels(string(ifgaudioData.Labels(:,1)));
bar(hist_classes.Label,hist_classes.Count)

filename = sprintf('ifgpessoas%iseg',tempoSegmento);
foldername = '';

if(concat)
    filename = sprintf('%s_concat', filename);
    foldername = sprintf('%s_concat', foldername);
end
if(trim)
    filename = sprintf('%s_trim', filename);
    foldername = sprintf('%s_trim', foldername);
end
if (overlap < 1)
    filename = sprintf('%s_overlap%i', filename, overlap * 100);
    foldername = sprintf('%s_overlap%i', foldername, overlap * 100);
end

if ~exist(sprintf('./dataset/%s', foldername), 'dir')
   mkdir(sprintf('./dataset/%s', foldername))
end

savefig(sprintf('./dataset/%s/%s.fig', foldername, filename))
save(sprintf('./dataset/%s/%s.mat', foldername, filename), 'ifgaudioData');