%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comandos útiles para control robusto:                                   %
% Algunos comandos básicos para visualizar la familia de modelos con      %
% incertidumbre multiplicativa                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc,clear,close all

s = tf('s');

% Si se tiene una planta de la forma:
G0 = 1/s;
G  = G0;

%y quiero emular un retardo variable puedo definir:
n = 10;
L = linspace(0,0.1,n); % genero n puntos equiespaciados

% Además, para la visualización puedo proponer:
nl = 1e3;
a  = -3;
b  = 2;
% ww tiene nl puntos entre 10^a y 10^b espaciados logarítmicamente
ww = logspace(-2,3,nl); 

% Finalmente hago un gráfico en frecuencia con la familia de modelos:
for i =1:n
    G.IODelay = L(i);
    % freqresp nos da la respuesta en frequencia (j\omega) para los ww
    sys_resp    = squeeze(freqresp(G,ww));
    sys_resp0   = squeeze(freqresp(G0,ww));

    % Cálculo de la incerteza multiplicativa en j\omega
    incert_mult = sys_resp./sys_resp0-1;    
    
    % Grafico de módulo en escala logarítmica del eje x
    semilogx(ww,20*log10(abs(incert_mult)));
    hold on
end

% Luego se debe determinar el W(j\omega) para este tipo de incerteza.