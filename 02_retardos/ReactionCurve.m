%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Función para determinar un modelo FOPDT mediante la recta tangente al   %
% punto de máximo cambio.                                                 %
%                                                                         %
% Además esta función devuelve las ganancias para un P, PI y PID ajustadas%
% mediante la tabla de Cohen-Coon                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [model,controller]=ReactionCurve(t,y,u)
% REACTIONCURVE   Process Reaction Curve approach to approximate high-order
%                 systems by a first-order-plus-timedelay model using step 
%                 response data. This model can be used to design a PID 
%                 controller
%        [model,P,PI,PID]=ReactionCurve(t,y,u)
%Inputs:
%       t: time vector of step repose
%       y: output vector of step repose
%       u: step input vector or scalar (input change)
%Outputs:
%       model: first-order-plus-timedelay model structue, which includes
%              gain (steady-state gain), time_constant (first-order time
%              constant) and tiem_deltay.
%       controllers: structure of transfer functions of P-only, PI and PID
%       controllers.
%Example:
%       G = tf([2 1],[1 4 6 4 1]);    % (2s+1)/(s+1)^4 
%       [y,t]=step(G); % step response of G
%       [model,controler]=ReactionCurve(t,y);
%       T=feedback(G*controller.PID,1);
%       step(T)
%
% By Yi Cao at Cranfield University, on 1st October 2007
%
if nargin<3
    du=1;
    t0=0;
    u=1;
elseif isscalar(u)
    du=u;
    t0=0;
else
    du=u(end)-u(1);
    t0=find(diff(u));
end
% DC gain
gain=(y(end)-y(1))/du;

% Slope calculation
dy=diff(y);
dt=diff(t);
[mdy,I]=max(abs(dy)./dt); % I indicates the index where the max has been found

% Time parameters of the FOPDT
time_constant=abs(y(end)-y(1))/mdy;
time_delay=t(I)-abs(y(I)-y(1))/mdy-t0;

% Plots
subplot(211)
plot(t,y,[t0+time_delay t0+time_delay+time_constant],[y(1) y(end)],...
    [t(1) t(end)],[y(1) y(1)],'--',[t(1) t(end)],[y(end) y(end)],'--');
title('output')
subplot(212)
if isscalar(u)
    plot([t0 t(end)],[u u])
else
    plot(t,u)
end
title('input')

% Function outputs related to the model
model.gain=gain;
model.time_constant=time_constant;
model.time_delay=time_delay;

% Cohen-Coon PID desing
time_delay=max(time_delay,time_constant/10);
controller.P=time_constant/time_delay/gain;
controller.PI=0.9*time_constant/time_delay/gain*tf([3.3*time_delay 1],[3.3*time_delay 0]);
controller.PID=1.2*time_constant/time_delay/gain*tf([time_delay^2 2*time_delay 1],[2*time_delay 0]);
