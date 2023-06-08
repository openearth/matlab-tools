%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18632 $
%$Date: 2022-12-20 06:26:16 +0100 (di, 20 dec 2022) $
%$Author: chavarri $
%$Id: absmintol.m 18632 2022-12-20 05:26:16Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absmintol.m $
%
%General Runge-Kutta 4 algorithm
%
%INPUT:
%   -f: function handle for the derivative (dy/dt = f(t, y))
%   -tspan: time span [t0, tf]
%   -y0: initial condition
%   -h: step size
%
%OUTPUT:
%   -t: time vector
%   -y: solution vector
%
%E.G.:
% 
% %Define the derivative function (example: dy/dt = -2ty)
% f = @(t, y) -2 * t * y;
% 
% %Define the time span and initial condition
% tspan = [0, 1];
% y0 = 1;
% 
% %Choose the step size
% h = 0.1;
% 
% %Call the RK4 function
% [t, y] = rungeKutta4(f, tspan, y0, h);
% 
% %Plot the solution
% plot(t, y);
% xlabel('t');
% ylabel('y');
% title('Runge-Kutta 4th Order');

function [t, y] = RK4(f, tspan, y0, h)

    t0 = tspan(1);
    tf = tspan(2);
    t = t0:h:tf; % time vector
    N = length(t);
    y = zeros(size(t)); % solution vector
    
    y(1) = y0; % initial condition
    
    for i = 1:N-1
        k1 = h * f(t(i), y(i));
        k2 = h * f(t(i) + h/2, y(i) + k1/2);
        k3 = h * f(t(i) + h/2, y(i) + k2/2);
        k4 = h * f(t(i) + h, y(i) + k3);
        
        y(i+1) = y(i) + (k1 + 2*k2 + 2*k3 + k4)/6;
    end
end