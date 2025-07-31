function [wd_min,wm_max,w_Wd_3db,w_Wm_3db] = incert_mag(Wm,Wd)
% This function determines where are (in frequency) the crossings of the
% uncertainties for 0 dB, in order to apply the simplifications of the
% robust performance definition and can define a gain by loopshaping
figure(11)
bodemag(Wd,Wm)
grid on
legend('W_d','W_m')

[mag_Wd,ph,w_Wd] = bode(Wd);
mag_Wd = squeeze(mag_Wd);

[mag_Wm,ph,w_Wm] = bode(Wm);
mag_Wm = squeeze(mag_Wm);

% Paso 1: Magnitud en dB
Wd_db = 20*log10(abs(mag_Wd));
% Paso 2: Buscar frecuencias donde Wd < 0 dB
indices = find(Wd_db < 0);
w_Wd_m0 = w_Wd(indices);

% Paso 1: Magnitud en dB
Wm_db = 20*log10(abs(mag_Wm));
% Paso 2: Buscar frecuencias donde Wm > 0 dB
indices = find(Wm_db > 0);
w_Wm_M0 = w_Wm(indices);

if w_Wd_m0(1)>10*w_Wm_M0(1)
    disp('¡Revisar los cruces de las incertidumbres!')
else
    % Valor máximo (en general en baja frecuencia)
    max_db = max(Wd_db);  % o Wd_db(1) si sabés que es monótona decreciente
    % Nivel de -3 dB respecto al máximo
    umbral_3db = max_db - 3;
    % Buscar el primer cruce
    idx = find(Wd_db <= umbral_3db, 1, 'first');
    w_Wd_3db = w_Wd(idx);

    % Valor máximo
    max_db = max(Wm_db);  
    % Nivel de -3 dB respecto al máximo
    umbral_3db = max_db - 3;
    % Buscar el primer cruce
    idx = find(Wd_db <= umbral_3db, 1, 'first');
    w_Wm_3db = w_Wm(idx);

    % Armado del gráfico:
    % Primer parte --> |Wd|>1>|Wm|
    nl = 100;
    a = log10(w_Wd_3db)-2;
    b = log10(w_Wd_3db);
    % ww tiene nl puntos entre 10^a y 10^b espaciados logarítmicamente
    ww1 = logspace(a,b,nl); 

    Wd_resp1 = squeeze(freqresp(Wd,ww1));
    Wm_resp1 = squeeze(freqresp(Wm,ww1));

    % Segunda parte -->|Wm|>1>|Wd|
    nl = 100;
    a = log10(w_Wm_3db);
    b = log10(w_Wm_3db)+2;
    % ww tiene nl puntos entre 10^a y 10^b espaciados logarítmicamente
    ww2 = logspace(a,b,nl); 

    Wm_resp2 = squeeze(freqresp(Wm,ww2));
    Wd_resp2 = squeeze(freqresp(Wd,ww2));

    cond1 = 20*log10((1+abs(Wd_resp1))./(1-abs(Wm_resp1)));   
    cond2 = 20*log10((1-abs(Wd_resp2))./(1+abs(Wm_resp2)));

    figure(22)
    semilogx(ww1,cond1,'LineWidth',1.5,'LineStyle','--','Color','green');
    patch([ww1(1),ww1(end),ww1(end),ww1(1)],[cond1(1),cond1(end),-150,-150],'green')
    hold on
    semilogx(ww2,cond2,'LineWidth',1.5,'LineStyle','--','Color','cyan');
    patch([ww2(1),ww2(end),ww2(end),ww2(1)],[cond2(1),cond2(end),150,150],'cyan')
    axis tight
    grid on
    wd_min = w_Wd(1);
    wm_max = w_Wm(end);
end











