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

function D3D_grd(simdef)
%% RENAME

grd_type=simdef.grd.type;

%% GRID TYPE

switch grd_type
    case 1
        D3D_grd_rect(simdef)
    case 2
        D3D_grd_sing(simdef)
    otherwise
        D3D_grd_DHL(simdef)
end

