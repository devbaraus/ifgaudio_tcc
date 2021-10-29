clear
clc
intensidadePotenciaRuido = 0:0.05:1;		% potencia de ruido (dado em % em funcao do sinal de audio) utilizada na "inferencia"
plotAudio = 0;								% flag para mostrar um exemplo a cada potencia de ruido
numExperimentos = 100;						% quantidade de experimentos a serem realizados na "inferencia"
idxArquivoSelecionado = 26;					% id do arquivo selecionado para "inferencia"
tamFFT = 1024;
%% Faz um levantamento dos arquivos de audio disponiveis para criacao da "base de dados de treinamento"
strPasta = 'audios\';
xx = ls(strcat(strPasta, '*.m4a'));
numArquivos = size(xx, 1);

%% Aplica uma representacao (neste caso, FFT) a todos os arquivos do "treinamento"
ffts = zeros(tamFFT, numArquivos);
parfor aa = 1:numArquivos
	[audioIn1, fs1] = audioread(strcat(strPasta, xx(aa, :)));		% le o arquivo
	audioIn1 = mean(audioIn1, 2);									% converte de estereo para mono calculando-se a media dos canais esquerdo e direito
	ffts(:, aa) = fft( audioIn1, tamFFT );						% aplica-se a representacao no arquivo e guarda o resultado num array
end

%% Realiza a quantidade de "inferencias" determinada em numExperimentos
 % A cada inferencia, eh aplicado um AWGN diferente e eh anotado o acerto ou erro.
 % Finalmente, calcula-se a taxa de acerto.
 % Esse processo eh realizado para cada valor de SNR determinado pelo vetor intensidadePotenciaRuido.

[arquivoSelecionado, fs2] = audioread(strcat('audios\',xx(idxArquivoSelecionado, :)));
arquivoSelecionado = mean(arquivoSelecionado, 2);

% Parametros basicos do arquivo carregado
numAmostras = size(arquivoSelecionado, 1);
comprimentoAudio = numAmostras/fs2;							% comprimento do audio dado em segundos
periodoAmostragem = 1/fs2;									% distancia temporal entre as amostras coletadas 'a taxa em Hz especificada em fs2
intTempo(:, 1) = 0:periodoAmostragem:...					% intervalo de tempo (eixo X em um dos graficos abaixo)
	             (comprimentoAudio - periodoAmostragem);

taxaAcertoPorSNR = zeros(size(intensidadePotenciaRuido));	% vetor contendo a taxa de acerto para cada valor de SNR
cont = 1;
for potRelativa = intensidadePotenciaRuido
	acerto = zeros(numExperimentos, 1);
	SNR = mag2db(1/potRelativa);				% converto o valor (1/potRelativa) de magnitude absoluta para SNR
	SNRMedia = zeros(numExperimentos, 1);
	parfor i = 1:numExperimentos
		% crio um vetor de ruido ajustado 'a potencia de sinal do arquivo selecionado
		potSinal = rms(arquivoSelecionado)^2;													% calcula-se a var/variancia (potencia) do sinal. rms() e' a raiz do erro quadratico medio e, na estatistica, rms == std/desvio padrao. Lembre-se de que var == std^2!
		potRuido = 1/potSinal;																	% ajusto a potencia de ruido em funcao da potencia de sinal. Lembre-se de que potSinal * (1/potSinal) == 1.
		ruidoAditivo = randn(numAmostras, 1)*std(arquivoSelecionado)/db2mag(SNR);				% crio o vetor contendo o AWGN (Additive White Gaussian Noise)
																								% AWGN --> ruido branco de media nula e distribuicao estatistica gaussiana/normal
		% se desejado, plotam-se os audio e o ruido aditivo
		if i == 1 && plotAudio == 1
			figure(1);
			clf;
			plot(intTempo, [arquivoSelecionado, ruidoAditivo], 'linewidth', 2);
			grid on;
			ylabel('Intensidade');
			xlabel('Tempo [s]');
			title(sprintf('Sinal em funcao do tempo (%2.2f%%)', potRelativa*100));
			xlim([0 intTempo(end)]);
			legend({'Audio original', 'AWGN'});
			keyboard;
		end
		SNRMedia(i) = snr(arquivoSelecionado, ruidoAditivo);				% acumula-se o valor de SNR para depois calcular a SNR media ao final dos experimentos para um valor de SNR
		fftArquivo = fft(arquivoSelecionado + ruidoAditivo, tamFFT);			% aplica a representacao no arquivo de "inferencia" infectado por ruido branco
% 		keyboard
		erroFFT = sum( abs((ffts - repmat(fftArquivo, 1, numArquivos)).^2), 1);		% calcula a diferenca entre a fft do audio ruidoso e as ffts de cada audio da "base de dados de treinamento"
		[~, idx] = min(erroFFT);													% faz um processo de maxima-verossimilhanca.
																					% em outras palavras 1: qual instancia da base de dados do treinamento teve a fft mais parecida com a fft do audio ruidoso utilizado na inferencia?
																					% em outras palavras 2: o audio ruidoso se parece mais com quem na "base de dados de treinamento"?
		if idx == idxArquivoSelecionado
			acerto(i) = 1;						% o arquivo selecionado na inferencia eh o arquivo esperado? anota o acerto.
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
figure(2)
clf;
plot(intensidadePotenciaRuido * 100, taxaAcertoPorSNR * 100, 'linewidth', 2);
ylabel('Taxa de acerto (%)');
xlabel('Porcentagem de ruído (%)');
ylim([0 100]);
title('Representação FFT');
grid on;
saveas(gcf,'fft_graph.png');