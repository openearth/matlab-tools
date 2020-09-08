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
%obs file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_obs(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_obs_s(simdef);
else
    D3D_obs_u(simdef);
end

