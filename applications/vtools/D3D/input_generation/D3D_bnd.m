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
%bnd file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.grd.M = number of nodes in the domain [integer(1,1)] e.g. [1002]
%
%OUTPUT:
%   -a .bnd compatible with D3D is created in file_name

function D3D_bnd(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_bnd_s(simdef);
else
    D3D_bnd_u(simdef);
    D3D_bnd_pli_us(simdef);
    D3D_bnd_pli_ds(simdef);
end