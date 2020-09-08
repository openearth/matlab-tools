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
%bcm file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_md(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_mdf(simdef);
else
    D3D_mdu(simdef);
end
