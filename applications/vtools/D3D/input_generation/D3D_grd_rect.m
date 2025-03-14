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
%grid files

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.D3D.grd = folder the grid files are [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\files\grd\'
%   -simdef.grd.L = domain length [m] [double(1,1)] e.g. [100]
%   -simdef.grd.dx = horizontal discretization [m] [double(1,1)]; e.g. [0.02] 
%   -simdef.grd.B = domain width [m] [double(1,1)] e.g. [2]
%   -simdef.grd.dy = transversal discretization [m] [double(1,1)]; e.g. [0.05]
%
%OUTPUT:
%   -a .grd file compatible with D3D is created in folder_out
%
%ATTENTION:
%   -
%
%HISTORY:
%   -161110 V. Creation of the grid files itself

function D3D_grd_rect(simdef)

%% RENAME

L=simdef.grd.L;
B=simdef.grd.B;
dx=simdef.grd.dx;
dy=simdef.grd.dy;

%in case we call directly
if isfield(simdef.grd,'M')==0 || isfield(simdef.grd,'N')==0
    simdef.grd.node_number_x=simdef.grd.L/simdef.grd.dx; %number of nodes 
    simdef.grd.node_number_y=simdef.grd.B/simdef.grd.dy; %number of nodes 
    simdef.grd.M=simdef.grd.node_number_x+2; %M (number of cells in x direction)
    simdef.grd.N=simdef.grd.node_number_y+2; %N (number of cells in y direction)
end

M=simdef.grd.M;
N=simdef.grd.N;
    
%% GRID

vx=0:dx:L;
vy=0:dy:B;

ycord=repmat(vy',1,M-1);

%% FILE

kl=1;
%preamble
data{kl  ,1}='*';kl=kl+1;
data{kl  ,1}=sprintf('* %s',username);kl=kl+1;
data{kl  ,1}=sprintf('* FileCreationDate = %s         ',string(datetime('now')));kl=kl+1;
data{kl  ,1}='*';kl=kl+1;
data{kl  ,1}='Coordinate System = Cartesian';kl=kl+1;
data{kl  ,1}='Missing Value     =   -9.99999000000000024E+02';kl=kl+1;
data{kl  ,1}=sprintf('\t %d \t %d',M-1,N-1);kl=kl+1;
data{kl  ,1}=' 0 0 0';kl=kl+1;

for ky=1:N-1
    aux=strcat('ETA=   %d',repmat(' %11.10E',1,M-1));
    data{kl,1}=sprintf(aux,ky,vx);kl=kl+1;
end
for ky=1:N-1
    aux=strcat('ETA=   %d',repmat(' %11.10E',1,M-1));
    data{kl,1}=sprintf(aux,ky,ycord(ky,:));kl=kl+1;
end
        
%% WRITE

writetxt(simdef.file.grd,data)

end %function