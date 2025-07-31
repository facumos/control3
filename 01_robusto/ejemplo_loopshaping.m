%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             COMANDOS PARA TRABAJAR CON LOOPSHAPING                      %
%                                                                         %
% El siguiente código está basado en un ejemplo.                          %
%                                                                         %
% En este ejempo se utilizan las funciones asymp.m e incert_mag.m que se  %
% pueden encontrar en la carpeta /utils_robusto de este repo              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc,clear,close all

s  = tf('s');
g0 = 1/s;

% Incertidumbre de modelo
Wm = 0.125*s/(1+s/25);

% Incertidumbre de perturbacion/referencia
Wd = 10*sqrt(2)/(1+s/0.1);

% 1er paso:
% Ubico gráficamente cómo se comportan las incertidumbres
[wd_min,wm_max,wd_3db,wm_3db] = incert_mag(Wm,Wd);

% 2do paso:
% Diseño del controlador por loopshaping
k = 10^(20/20)/(1+s/100);

L = k*g0;

% Frecuencias para gráfico de |L|
nl = 100;
a = log10(wd_min);
b = log10(wm_max)+1;
% ww tiene nl puntos entre 10^a y 10^b espaciados logarítmicamente
wwk = logspace(a,b,nl); 

% Función que realiza el bode de módulo asimptótico y real
asymp(L,wwk(1),wwk(end))


% Sensibilidad
S = feedback(1,L);
% Sensibilidad complementaria
T = feedback(L,1);

% Estabilidad robusta para incertidumbre multiplicativa
ER = T*Wm;
% Performance nominal
PN = S*Wd;
% Performance robusta
PR  = abs(squeeze(freqresp(ER+PN,wwk)));
%PR1 = abs(squeeze(freqresp(ER,wwk))) + abs(squeeze(freqresp(PN,wwk)));

figure(33)
semilogx(wwk,zeros(1,length(wwk)),'LineWidth',1.5)
hold on
semilogx(wwk,20*log10(abs(PR)));
%semilogx(wwk,20*log10(abs(PR1)));
grid on
title('Performance Robutsa')
ylabel('Magnitude (dB)');
xlabel('Frequency (rad/s)');

figure(44)
semilogx(wwk,zeros(1,length(wwk)),'LineWidth',1.5)
hold on
semilogx(wwk,20*log10(abs(squeeze(freqresp(ER,wwk)))));
grid on
title('Estabildad Robusta')
ylabel('Magnitude (dB)');
xlabel('Frequency (rad/s)');

disp(['Performance Robusta (en veces): ',num2str(max(PR))])
disp(['Estabilidad Robusta (en veces): ',num2str(max(abs(squeeze(freqresp(ER,wwk)))))])
