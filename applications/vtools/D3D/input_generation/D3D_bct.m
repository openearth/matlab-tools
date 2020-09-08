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
%bct file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bct(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_bct_s(simdef);
else
    D3D_bc_wL(simdef);
    D3D_bc_q0(simdef);
end