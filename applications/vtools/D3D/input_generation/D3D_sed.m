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
%sediment initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_sed_s(simdef);
else
    D3D_sed_u(simdef);
end