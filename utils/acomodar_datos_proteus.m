%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                        
% Cuando extraigan los puntos de Proteus van a notar que no fueron        %
% generados con un paso fijo, necesario para que podamos procesarlo en lo %
% que vamos a hacer luego.                                                %
%                                                                         %
% Este código fue creado para cargar los datos de Proteus y cambiarle la  %
% base de tiempo a un paso fijo con el que se pueda trabajar.             %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc
% Proteus entrega la información en un archivo .DAT
dataset = readtable('utils_data/proteus_data.DAT');

% Acorde con el ejemplo en /utils_data/ organizamos las columnas así:
t_var   = dataset.TIME;
y_var   = dataset.y6;

% Ahora modificamos el vector tiempo para que tenga un paso fijo
t_ini = t_var(1);
t_fin = t_var(end);
paso  = 1e-3;

t_fix = t_ini:paso:t_fin;

% Interpolá la señal a los nuevos tiempos
y_fixed = interp1(t_var, y_var, t_fix, 'linear');

% Plot de verificación
plot(t_var,y_var,t_fix,y_fixed)