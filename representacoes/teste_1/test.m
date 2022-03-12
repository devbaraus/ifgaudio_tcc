clear
clc
close all

[audioIn,fs] = audioread("audios/Frase 1-2.m4a");

audioIn = mean(audioIn, 2);
y = audioIn(1:fs*3);

% figure;
% plot(linspace(1, 3, size(y, 1)),y);
% figure;
% plot(linspace(1, size(audioIn,1)/fs, size(audioIn, 1)), audioIn);

potRelativa = 0.2;
numAmostras = size(y, 1);        
SNR = mag2db(1/potRelativa);
potSinal = rms(y)^2;													
potRuido = 1/potSinal;																	
ruidoAditivo = randn(numAmostras, 1)*std(y)/db2mag(SNR);
y_ruido = y + ruidoAditivo;

% STFT
figure(1);
tiledlayout(2,1);
nexttile;
win = hann(1024,"periodic");
S1 = abs(stft(y,"Window",win,"OverlapLength",512));
surfc(S1), colormap parula, shading flat, view([0 90]);
title('STFT');

nexttile;
win = hann(1024,"periodic");
S2 = abs(stft(y_ruido,"Window",win,"OverlapLength",512));
surfc(S2), colormap parula, shading flat, view([0 90]);
title('STFT ruído 20%');

%MFCC
figure(2);
tiledlayout(2,1);
nexttile;
mfccCoeffs = mfcc(y,fs);
surfc(mfccCoeffs'), colormap parula, shading flat, view([0 90]);
set(gca,'xtick',[],'ytick',[])
pbaspect([8 3 1])
title('MFCC');

colormap autumn

nexttile;
mfccCoeffs = mfcc(y_ruido,fs);
surfc(mfccCoeffs'), colormap parula, shading flat, view([0 90]);
title('MFCC Ruído 20%');

%GTCC
figure(3);
tiledlayout(2,1);
nexttile;
gtccCoeffs = gtcc(y,fs);
surfc(gtccCoeffs'), colormap parula, shading flat, view([0 90]);
title('GTCC');

nexttile;
gtccCoeffs = gtcc(y_ruido,fs);
surfc(gtccCoeffs'), colormap parula, shading flat, view([0 90]);
title('GTCC Ruído 20%');

%LPC
figure(4);
lpcCoeffs = lpc(y,1024);
plot(lpcCoeffs,'LineWidth',2);
hold on;
lpcCoeffs = lpc(y_ruido,1024);
plot(lpcCoeffs,'LineWidth',2);
hold off;
legend('Sem ruído','Com ruído 20%');
title('LPC');

%FFT
figure(5);
fftCoeffs = abs(fft(y, 1024));
sizeFFT = 1:size(fftCoeffs,1);
plot(sizeFFT,fftCoeffs);
hold on;
fftCoeffs = abs(fft(y_ruido, 1024));
sizeFFT = 1:size(fftCoeffs,1);
plot(sizeFFT,fftCoeffs);
hold off;
legend('Sem ruído','Com ruído 20%');
title('FFT');

%FFT
figure(5);
fftCoeffs = abs(fft(y, 1024));
sizeFFT = 1:size(fftCoeffs,1);
plot(sizeFFT,fftCoeffs);
hold on;
fftCoeffs = abs(fft(y_ruido, 1024));
sizeFFT = 1:size(fftCoeffs,1);
plot(sizeFFT,fftCoeffs);
hold off;
legend('Sem ruído','Com ruído 20%');
title('FFT');
