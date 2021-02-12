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
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.grd.M = number of nodes in the domain [-] [integer(1,1)] e.g. [1002]
%   -simdef.grd.dx = horizontal discretization [m] [integer(1,1)]; e.g. [0.02] 
%   -simdef.ini.s = bed slope [-] [integer(1,1)] or [integer(nx-1,1)] from upstream to downstream; e.g. [3e-4] or linspace(0.005,0.003,101)
%   -simdef.grd.L = domain length [m] [integer(1,1)] [100]
%   -simdef.ini.etab = %initial downstream bed level [m] [double(1,1)] e.g. [0]
%
%OUTPUT:
%   -a .dep compatible with D3D is created in file_name
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%   -Uniform slope
%   -Depth in D3D is defined positive downward and it is bed level and not flow depth
%   -The number of input is over defined. In this way we double check it. 
%
%150728->151118
%   -Introduction of boundary at the downstream end as input
%
%151118->151125
%   -Introduction of a varying slope

function D3D_dep_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim; 
path_grd=fullfile(dire_sim,'grd.grd');

%only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

slope=simdef.ini.s; %slope (defined positive downwards)
dx=simdef.grd.dx;
dy=simdef.grd.dy;
% nx=simdef.grd.M;
% N=simdef.grd.N;
nx=M;
L=simdef.grd.L;
B=simdef.grd.B;
etab=simdef.ini.etab;
etab0_type=simdef.ini.etab0_type;

%other
ncy=N-2; %number of cells in y direction (N in RFGRID) [-]
d0=etab; %depth (in D3D) at the downstream end (at x=L, where the water level is set)

%varying slope flag
% if numel(slope)>1; flg_vars=
%% CALCULATIONS

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1
        ny=ncy+2; %number of depths points in y direction

        depths=-9.99e2*ones(ny,nx); %initial depths with dummy values

        if numel(slope)==1
            vd=-(d0+slope*(L+dx/2):-dx*slope:d0+dx/2*slope); %depths vector 
        elseif numel(slope)==nx-1
            vd(nx-1)=d0+slope(nx-1)*dx/2;
            for kx=nx-2:-1:1
                vd(kx)=vd(kx+1)+dx*slope(kx);
            end
            vd=-vd;
        else
            error('The input SLOPE can be a single value or a vector with nx+1 components')
        end

        depths(1:ny-1,1:nx-1)=repmat(vd,length(1:ny-1),1);
    case 2
        ny=ncy+2; %number of depths points in y direction

        depths=-etab*ones(ny,nx); 
    case 3
%         depths=simdef.ini.xyz;
        error('..')
end


%add noise
noise=zeros(ny,nx);
rng(0)
switch simdef.ini.etab_noise
    case 0
%         noise=zeros(ny,nx);
    case 1 %random noise
        warning('Check indeces after changin ny def')
        noise_amp=simdef.ini.noise_amp;
        noise(1:end-3,3:end-1)=noise_amp.*(rand(ny-3,nx-3)-0.5);
    case 2 %sinusoidal
        warning('Check indeces after changin ny def')
        noise_amp=simdef.ini.noise_amp;
        noise_Lb=simdef.ini.noise_Lb;
        x_v=2*dx:dx:L;
        y_v=-B/2:dy:B/2;
        [x_m,y_m]=meshgrid(x_v,y_v);
        noise(1:end-3,3:end-1)=noise_amp*sin(pi*y_m/B).*cos(2*pi*x_m/noise_Lb-pi/2);
    case 3 %random noise including at x=0
        warning('Check indeces after changin ny def')
        noise_amp=simdef.ini.noise_amp;
%         noise(1:end-3,2:end-1)=noise_amp.*(rand(ny-3,nx-2)-0.5);
        noise(1:end-3,1:end)=noise_amp.*(rand(ny-3,nx)-0.5);
    case 4 %trench
        noise_amp=simdef.ini.noise_amp;
        noise_trench_x=simdef.ini.noise_trench_x;
        
        %identify patch coordinates
        xedge=-dx/2:dx:L-dx/2;
        [~,x0_idx]=min(abs(xedge-noise_trench_x(1)));
        [~,xf_idx]=min(abs(xedge-noise_trench_x(2)));
        
        noise(:,x0_idx:xf_idx)=noise_amp;
        
    otherwise
        error('say something about it!')
end

depths=depths+noise;

%% WRITE

file_name=fullfile(dire_sim,'dep.dep');  
write_2DMatrix(file_name,depths);

% file_name=fullfile(dire_sim,'dep.dep');  
% 
% %check if the file already exists
% if exist(file_name,'file')
%     error('You are trying to overwrite a file!')
% end
% 
% fileID_out=fopen(file_name,'w');
% write_str_x=strcat(repmat('%0.7E ',1,nx),'\n'); %string to write in x
% 
% for ky=1:ny
%     fprintf(fileID_out,write_str_x,depths(ky,:));
% end
% 
% fclose(fileID_out);


