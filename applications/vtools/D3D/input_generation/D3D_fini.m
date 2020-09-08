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
%generate water level and velocity in rectangular grid 

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.grd.M = number of nodes in the domain [-] [integer(1,1)] e.g. [1002]
%   -simdef.grd.dx = horizontal discretization [m] [integer(1,1)]; e.g. [0.02] 
%   -simdef.ini.s = bed slope [-] [integer(1,1)]; e.g. [3e-4] 
%   -simdef.ini.h = uniform flow depth [m] [double(1,1)]; e.g. [0.19]
%   -simdef.ini.u = uniform flow velocity [m/s] [double(1,1)]; e.g. [0.6452] 
%   -simdef.grd.L = domain length [m] [integer(1,1)] [100]
%   -simdef.ini.etab = initial downstream bed level [m] [double(1,1)] e.g. [0]
%
%OUTPUT:
%   -a .ini compatible with D3D is created in file_name
%
%ATTENTION:
%   -Very specific for 1D case in positive x direction
%   -Uniform slope
%
%150728->151118
%   -Introduction of boundary at the downstream end as input
%
%151118->151125
%   -Introduction of a varying slope

function D3D_fini(simdef)
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

slope=simdef.ini.s;
dx=simdef.grd.dx;
nx=M;
ny=N;
nk=simdef.grd.K;
h=simdef.ini.h;
% u=simdef.ini.u;
etab=simdef.ini.etab;
L=simdef.grd.L;
I=simdef.ini.I0;
secflow=simdef.mdf.secflow;
etab0_type=simdef.ini.etab0_type;
u=0;
v=0; %v velocity

%other
% ncy=N-2; %number of cells in y direction (N in RFGRID) [-]
% ny=ncy+2; %number of depths points in y direction
% ny=N; %number of depths points in y direction
% ny=N+4; %number of depths points in y direction

%% CALCULATIONS

water_levels=-9.99e2*ones(ny,nx); %initial water levels with dummy values
u_mat=-9.99e2*ones(ny,nx); %initial u velocity with dummy values
v_mat=-9.99e2*ones(ny,nx); %initial v velocity with dummy values
I_mat=-9.99e2*ones(ny,nx); %initial secondary flow velocity with dummy values

switch etab0_type %type of initial bed elevation: 1=sloping bed; 2=constant bed elevation
    case 1

        if numel(slope)==1
            d0=h+etab; 
            %water level
            vd=d0+slope*L:-dx*slope:d0+dx*slope;
        elseif numel(slope)==nx-1
            d0=etab;
            %water level
               %bed level 
            bl(nx-1)=d0+slope(nx-1)*dx/2;
            for kx=nx-2:-1:1
                bl(kx)=bl(kx+1)+dx*slope(kx);
            end
                %bed level+water depth
            vd=NaN(nx-2,1);    
            for kx=1:nx-2
                vd(kx)=(h(kx)+bl(kx)+h(kx+1)+bl(kx+1))/2;
            end   
        else
            error('The input SLOPE can be a single value or a vector with nx+1 components')
        end
        water_levels(2:ny-1,2:nx-1)=repmat(vd,length(2:ny-1),1);
    case 2
        water_levels(2:ny-1,2:nx-1)=h+etab;
    otherwise
        error('..')
end
%u velocity
u_mat(2:ny-1,1:nx-1)=u;

%v velocity
v_mat(2:ny-1,1:nx-1)=v;

%seconday flow intensity 
I_mat(2:ny-1,1:nx-1)=I;

%% WRITE

file_name=fullfile(dire_sim,'fini.ini');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
write_str_x=strcat(repmat('%0.7E ',1,nx),'\n'); %string to write in x

%water level
for ky=1:ny
    fprintf(fileID_out,write_str_x,water_levels(ky,:));
end
%u velocity
for kk=1:nk
    for ky=1:ny
        fprintf(fileID_out,write_str_x,u_mat(ky,:));
    end
end
%v velocity
for kk=1:nk
    for ky=1:ny
        fprintf(fileID_out,write_str_x,v_mat(ky,:));
    end
end
%secondary flow intensity
if secflow==1
    for ky=1:ny
        fprintf(fileID_out,write_str_x,I_mat(ky,:));
    end
end
fclose(fileID_out);
