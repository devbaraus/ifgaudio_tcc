clear
clc
close all

tempoSegmento = 2;
overlap = 0.5;
overlap = 1 - overlap;

[audioIn,fs] = audioread("audios/Frase 1-2.m4a");
audioIn = mean(audioIn, 2);

tamanhoFsSegmento = fs * tempoSegmento;
tamanhoFsOverlapSegmento = tamanhoFsSegmento * overlap;

%% Verifica a quantidade de segmentos que o áudio pode ter
% qtdSegmentos = fix(size(audioIn, 1) / (fs * tempoSegmento * overlap));                           
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

%% Guarda os segmentos em um vetor
segmentosAudio = zeros(fs*tempoSegmento,qtdSegmentos);

for i = 1:qtdSegmentos
    comecoSegmento = (i - 1) * fs * tempoSegmento * overlap;
    fimSegmento = comecoSegmento + fs * tempoSegmento;
    fprintf('Começo %i : Fim %i\n', comecoSegmento, fimSegmento);
    segmentosAudio(:,i) = audioIn(comecoSegmento + 1:fimSegmento,1);
end

%% Faz a comparação de cada segmento com o áudio
% tiledlayout(ceil(sqrt(qtdSegmentos)),floor(sqrt(qtdSegmentos)));
clf;
figure(1);
tiledlayout('flow');
for i = 1:qtdSegmentos
    if i == 1
        nexttile;
        plot(linspace(0, size(audioIn,1)/fs, size(audioIn, 1)), audioIn);
        hold on;
        segmento = zeros(size(audioIn,1),1);
        segmento((i-1) * tamanhoFsOverlapSegmento + 1:(i-1) * tamanhoFsOverlapSegmento + tamanhoFsSegmento,1) = segmentosAudio(:,i);
        plot(linspace(0, size(audioIn,1)/fs, size(audioIn, 1)),segmento);
%         title(sprintf('Segmento %i',i
        set(gca,'xtick',[], 'ytick',[])
        xlim('tight')
        pbaspect([8 3 1])
        hold off;
    end

end
saveas(gca, 'segmento.png')

figure(2);
plot(linspace(0, size(audioIn,1)/fs, size(audioIn, 1)), audioIn);
set(gca,'xtick',[], 'ytick',[])
xlim('tight')
pbaspect([8 3 1])
hold off;
saveas(gca, 'trim.png')

intensidade = 0.4;
SNR = mag2db(1/intensidade);
potencia_sinal = rms(audioIn)^2;
ruido_aditivo = randn(1, size(audioIn,1))*std(audioIn)/db2mag(SNR);
ruido_aditivo = ruido_aditivo';

figure(3);
plot(linspace(0, size(audioIn,1)/fs, size(audioIn, 1)), audioIn);
hold on;
plot(linspace(0, size(ruido_aditivo,1)/fs, size(ruido_aditivo, 1)), ruido_aditivo);
set(gca,'xtick',[], 'ytick',[])
xlim('tight')
pbaspect([8 3 1])
hold off;
saveas(gca, 'ruido.png')