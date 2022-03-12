clear
clc
close all

idxSegmentoSelecionado = [26,2]; % arquivo segmento
intensidadePotenciaRuido = 0:0.05:1;
numExperimentos = 10000;	
plotAudio = 0;

%% Faz um levantamento dos arquivos de audio disponiveis para criacao da "base de dados de treinamento"
strPasta = 'audios\';
xx = ls(strcat(strPasta, '*.m4a'));
numArquivos = size(xx, 1);

%% Verifica a quantidade de segmentos que cada arquivo tem

tempoSegmento = 2;
overlap = 0;
overlap = 1 - overlap;
fs = 48000;
tamanhoFsSegmento = fs * tempoSegmento;
tamanhoFsOverlapSegmento = tamanhoFsSegmento * overlap;
tamREP = prod(size(mfcc(zeros(tamanhoFsSegmento,1),fs)));

qtdSegmentosArr = zeros(numArquivos,1);

parfor aa = 1:numArquivos
	[audioIn, fs] = audioread(strcat(strPasta, xx(aa, :)));
	audioIn = mean(audioIn, 2);
    
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


%% Guarda os segmentos de cada audio e as representações de cada segmento
maxQtdSegmentos = max(qtdSegmentosArr);
segmentosAudiosMat = zeros(tamanhoFsSegmento,numArquivos,maxQtdSegmentos);
repAudiosMat = zeros(tamREP,numArquivos,maxQtdSegmentos);

for aa = 1:numArquivos
    [audioIn, fs] = audioread(strcat(strPasta, xx(aa, :)));
	audioIn = mean(audioIn, 2);
    
    parfor i = 1:qtdSegmentosArr(aa,1)
        comecoSegmento = (i - 1) * fs * tempoSegmento * overlap;
        fimSegmento = comecoSegmento + fs * tempoSegmento;
        segmentoAudio = audioIn(comecoSegmento + 1:fimSegmento,1);
        segmentosAudiosMat(:,aa,i) = segmentoAudio;
        repAudiosMat(:,aa,i) = reshape(mfcc(segmentoAudio, fs).', [], 1); 
    end
end


%% Realiza a quantidade de "inferencias" determinada em numExperimentos

taxaAcertoPorSNR = zeros(size(intensidadePotenciaRuido));
arquivoSelecionado = segmentosAudiosMat(:,idxSegmentoSelecionado(1),idxSegmentoSelecionado(2));
numAmostras = size(arquivoSelecionado, 1);
cont = 1;
for potRelativa = intensidadePotenciaRuido
    acerto = zeros(numExperimentos, 1);
	SNR = mag2db(1/potRelativa);				% converto o valor (1/potRelativa) de magnitude absoluta para SNR
	SNRMedia = zeros(numExperimentos, 1);
    parfor i = 1:numExperimentos
        potSinal = rms(arquivoSelecionado)^2;													% calcula-se a var/variancia (potencia) do sinal. rms() e' a raiz do erro quadratico medio e, na estatistica, rms == std/desvio padrao. Lembre-se de que var == std^2!
		potRuido = 1/potSinal;																	% ajusto a potencia de ruido em funcao da potencia de sinal. Lembre-se de que potSinal * (1/potSinal) == 1.
		ruidoAditivo = randn(numAmostras, 1)*std(arquivoSelecionado)/db2mag(SNR);
        
         % se desejado, plotam-se os audio e o ruido aditivo
		if i == 1 && plotAudio == 1
            tempoAudio = linspace(0, tamanhoFsSegmento/fs, tamanhoFsSegmento);
			figure(1);
			clf;
			plot(tempoAudio, [arquivoSelecionado, ruidoAditivo]);
			grid on;
			ylabel('Intensidade');
			xlabel('Tempo [s]');
			title(sprintf('Sinal em funcao do tempo (%2.2f%%)', potRelativa*100));
			xlim([0 tempoAudio(end)]);
			legend({'Audio original', 'AWGN'});
			keyboard;
		end
        
        repArquivo = reshape(mfcc(arquivoSelecionado + ruidoAditivo, fs).', [], 1);
        SNRMedia(i) = snr(arquivoSelecionado, ruidoAditivo);
        
        for j = 1:maxQtdSegmentos
            erroFFT = sum( abs((repAudiosMat(:,:,j) - repmat(repArquivo, 1, numArquivos)).^2), 1);
            [~, idx] = min(erroFFT);
            
            if idx == idxSegmentoSelecionado(1) && j == idxSegmentoSelecionado(2)
                acerto(i) = 1;						% o arquivo selecionado na inferencia eh o arquivo esperado? anota o acerto.
            end
        end
    end
    SNRMedia = sum(SNRMedia);
	acerto = sum(acerto);
	SNRMedia = SNRMedia/numExperimentos;				% calcula-se a SNR media
	taxaAcertoPorSNR(cont) = acerto/numExperimentos;	% calcula-se a taxa media de acerto para aquele valor de SNR
	fprintf('Taxa de acerto para (%2.2f%%/SNR: %2.2f dB): %2.2f%%\n', potRelativa*100, SNRMedia, taxaAcertoPorSNR(cont)*100);
	cont = cont + 1;
end

% Mostra o grafico da taxa de acerto em funcao da potencia de ruido
f = figure(2);
clf;
plot(intensidadePotenciaRuido * 100, taxaAcertoPorSNR * 100, 'linewidth', 2);
ylabel('Taxa de acerto (%)');
xlabel('Porcentagem de ruído (%)');
ylim([0 100]);
title(sprintf('Representação MFCC (%i experimentos)', numExperimentos));
grid on;
saveas(gcf,sprintf('mfcc_graph_%i.fig', numExperimentos));
close(f);