%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%generate depths in rectangular grid 

%INPUT:
%   -
%
%OUTPUT:
%   -
%
%ATTENTION:
%   -
%

function D3D_dep_u(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim; 

% dx=simdef.grd.dx;
% dy=simdef.grd.dy;
% nx=simdef.grd.M;
% N=simdef.grd.N;

B=simdef.grd.B;
etab=simdef.ini.etab;
etab0_type=simdef.ini.etab0_type;

%other
% ncy=N; %number of cells in y direction (N in RFGRID) [-]
% d0=etab; %depth (in D3D) at the downstream end (at x=L, where the water level is set)

%varying slope flag
% if numel(slope)>1; flg_vars=
%% CALCULATIONS

%data=[
%x0  y0  etab|_(0,0)
%x0  y1  etab|_(1,1)
%...
%]

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1
        slope=simdef.ini.s; %slope (defined positive downwards)
        L=simdef.grd.L;
        depths=[0,0,etab+slope*L;0,B,etab+slope*L;L,0,etab;L,B,etab];
    case 2
        large_number=1e4;
        depths=[-large_number,-large_number,etab;-large_number,large_number,etab;large_number,-large_number,etab;large_number,large_number,etab];
    case 3
        depths=simdef.ini.xyz;
end

%% add noise
% noise=zeros(ny,nx);
% rng(0)
switch simdef.ini.etab_noise
    case 0
%         noise=zeros(ny,nx);
%     case 1 %random noise
%         noise_amp=simdef.ini.noise_amp;
%         noise(1:end-3,3:end-1)=noise_amp.*(rand(ny-3,nx-3)-0.5);
%     case 2 %sinusoidal
%         noise_amp=simdef.ini.noise_amp;
%         noise_Lb=simdef.ini.noise_Lb;
%         x_v=2*dx:dx:L;
%         y_v=-B/2:dy:B/2;
%         [x_m,y_m]=meshgrid(x_v,y_v);
%         noise(1:end-3,3:end-1)=noise_amp*sin(pi*y_m/B).*cos(2*pi*x_m/noise_Lb-pi/2);
%     case 3 %random noise including at x=0
%         noise_amp=simdef.ini.noise_amp;
% %         noise(1:end-3,2:end-1)=noise_amp.*(rand(ny-3,nx-2)-0.5);
%         noise(1:end-3,1:end)=noise_amp.*(rand(ny-3,nx)-0.5);
    otherwise
        error('sorry... not implemented!')
end

% depths=depths+noise;

%% WRITE

file_name=fullfile(dire_sim,'dep.xyz');  
write_2DMatrix(file_name,depths,size(depths,2),size(depths,1));
