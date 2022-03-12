# Teste 2
Continuamos utilizando a base de teste contendo os 30 arquivos de áudios.
Desta fez foi realizado a segmentação de cada arquivo de audio em pedaços de 2 segundos, sem overlap. Por exemplo, se um arquivo de áudio tem o tamanho de 5s, este é transformado em 2 pedaços de 2s cada.
Cada segmento de áudio foi passado por uma transformação (FFT, MFCC, GTCC e LPC), desta vez não foi utilizando o STFT, já que ele apresenta resultados duvidosos.

- FFT:
    - 1024 pontos
- STFT:
    - Overlap de 50%
    - Janela de Hanning de 1024 pontos
- GTCC:
    - parâmetros padrões
- MFCC:
    - parâmetros padrões
- LPC:
    - 1024 pontos

Escolheu-se um segmento tido como instância de inferência, que foi infectado por AWGN com SNR ajustada em função da porcentagem do RMS do sinal de áudio (entre 0% e 100%). Essa instância de inferência é comparada com todas instâncias de treinamento. Anotou-se a taxa de acerto para cada um desses valores.

Calculou-se o erro quadrático acumulado entre a instância de inferência e a base de dados em 10000 experimentos independentes (Monte-Carlo) por valor de SNR. Anotou-se a taxa de acerto para cada um desses valores.