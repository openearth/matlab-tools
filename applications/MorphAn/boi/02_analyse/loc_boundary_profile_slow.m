function X11 = loc_boundary_profile_slow(znat,xnat,x,zb,maxwl,fig)
%loc_boundary_profile_slow  Compute position of boundary profile with slow
%method
%
%   Compute position of boundary profile
%
%   Syntax:
%   X11 = loc_boundary_profile_slow(znat,xnat,x0,zb0,maxwl)
%
%   Input:
%   znat     = z location of wet point (positive upwards)
%   xnat     = x location of wet point
%   x0       = x coordinates of profile 
%   zb0      = bed level points
%   maxwel   = water level
%
%   Output:
%   X11    = Base point of boundary profile
%


% Created: 20 Okt 2012

% $Id:  $
% $Date:  $
% $Author:  $
% $Revision:  $
% $HeadURL:  $
% $Keywords: $


%% input
% --- upper limit boundary profile (zswetmax+1.5m)
z_max_grensprofiel = znat+1.5;
% --- lower limit boundary profile (Rekenpeil)
z_min_grensprofiel = maxwl;
% --- length boundary profile
length_boundary_profile_top     = 3;
length_boundary_profile_bottom  = 7.5;


helling1 = 1; % left slope 1/1
helling2 = 2; % right slope 1/2



% --- plot profile
if fig
figure
plot(x,zb,'k.-','DisplayName','zb');
hold on
plot(x, x*0+z_max_grensprofiel,'DisplayName','Max GP')
plot(x, x*0+z_min_grensprofiel,'DisplayName','Min GP')
plot(xnat,z_max_grensprofiel-1.5,'*','DisplayName','Wet punt')
end

% --- height boundary profile
height = z_max_grensprofiel - z_min_grensprofiel;

% --- shape boundary profile
x11 = x(1);
x12 = x(1)+height*helling1;
x21 = x(1)+height*helling1+length_boundary_profile_top;
x22 = x(1)+height*helling1+length_boundary_profile_top + helling2*height;

GP_x0 = [x11 x12 x21 x22];
GP_z0 = [z_min_grensprofiel z_max_grensprofiel z_max_grensprofiel z_min_grensprofiel];

dx_GP = 0.1;

GP_x = GP_x0(1):dx_GP:GP_x0(end);
GP_z = interp1(GP_x0, GP_z0,GP_x);


% --- move boundary profile untill it fit
dx = 0.01;
Nx =( x(end)-x(1) )/dx;

for ii=1:Nx
    % --- interpolate 
    z_int               = interp1(x, zb,GP_x);
    
    % --- check whether boundary profile fit
    if GP_z<z_int & GP_x(1)>xnat
        X11 = GP_x(1);
        if fig; plot(GP_x,GP_z,'m','linewidth',2,'DisplayName','final GP'); end
        break
    end
    % --- update location
    GP_x = GP_x + dx;
    
    % --- plot
    if false; plot(GP_x,GP_z,'b'); end % only plot during debug
    
end

if fig; legend('Location','Northwest'); end

% --- no solution is found
if ii==Nx
    disp('Kan geen grensprofiel inpassen');
    X11 = NaN;
end

end