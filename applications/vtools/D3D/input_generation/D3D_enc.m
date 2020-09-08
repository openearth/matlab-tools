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
%   -simdef.grd.dx = horizontal discretization [m] [integer(1,1)]; e.g. [0.02] 
%
%OUTPUT:
%   -a .grd file compatible with D3D is created in folder_out
%   -a .end file compatible with D3D is created in folder_out
%
%ATTENTION:
%   -
%
%HISTORY:
%   -161110 V. Creation of the grid files itself

function D3D_enc(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
path_grd=fullfile(dire_sim,'grd.grd');

%% only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%% read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

%% FILE

%preamble
data{1  ,1}='1 1 *** begin external enclosure';
data{2  ,1}=sprintf('%d 1',M);
data{3  ,1}=sprintf('%d %d',M,N);
data{4  ,1}=sprintf('1 %d',N);
data{5  ,1}='1 1 *** end external enclosure';

%% WRITE

file_name=fullfile(dire_sim,'enc.enc');
writetxt(file_name,data)
