function [u, t] = generar_prbs(N, Tprbs, num_periodos, amplitud)
% GENERAR_PRBS Genera una secuencia PRBS (Pseudo Random Binary Sequence).
%
%   [u, t] = generar_prbs(N, Tprbs, num_periodos, amplitud)
%
% Entradas:
%   N           -> orden del generador (ej: 7)
%   Tprbs       -> duración de cada bit [s]
%   num_periodos-> cuántos periodos de la secuencia repetir (ej: 3)
%   amplitud    -> amplitud de la señal (default = 1)
%
% Salidas:
%   u -> vector con la PRBS generada (valores +/- amplitud)
%   t -> vector de tiempo asociado

    if nargin < 4
        amplitud = 1; % valor por defecto
    end
    if nargin < 3
        num_periodos = 1; % al menos 1 periodo
    end

    % Polinomios primitivos conocidos (feedback taps para LFSR)
    % Pág 616 del libro Tangirala
    taps_map = containers.Map('KeyType','double','ValueType','any');
    taps_map(2) = [2 1];
    taps_map(3) = [3 2];
    taps_map(4) = [4 1];
    taps_map(5) = [5 2];
    taps_map(6) = [6 1];
    taps_map(7) = [7 3];
    taps_map(8) = [1 2 7 8];
    taps_map(9) = [9 4];
    taps_map(10)= [10 7];
    taps_map(11)= [11 9];
    % taps_map(12)= [12 6 4 1];
    % taps_map(13)= [13 12 11 8];
    % taps_map(14)= [14 13 12 2];
    % taps_map(15)= [15 14];
    % taps_map(16)= [16 15 13 4];

    if ~isKey(taps_map, N)
        error('No hay taps definidos para N = %d en este script.', N);
    end

    taps = taps_map(N);

    % Longitud de la secuencia máxima: 2^N - 1
    L = 2^N - 1;
    reg = ones(1,N); % semilla inicial (no puede ser todo ceros)
    seq = zeros(1,L);

    for k = 1:L
        seq(k) = reg(end);                % salida = último bit
        fb = mod(sum(reg(taps)), 2);      % feedback XOR
        reg = [fb, reg(1:end-1)];         % shift
    end

    % Convertir {0,1} -> {-1,+1} y escalar con amplitud
    u_bit = (2*seq - 1) * amplitud;

    % Repetir num_periodos veces
    u_bit = repmat(u_bit, 1, num_periodos);

    % Construir vector de tiempo
    t = 0:Tprbs:(length(u_bit)-1)*Tprbs;

    % Salida
    u = u_bit(:);

    % Graficar
    figure;
    stairs(t,u,'LineWidth',1.2);
    xlabel('Tiempo [s]');
    ylabel('u(t)');
    % title(sprintf('PRBS: N=%d, Tprbs=%.3f s, Periodo=%.2f s', N, Tprbs, L*Tprbs));
    grid on;

end
