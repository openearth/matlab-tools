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

function D3D_bcm(simdef,varargin)
%% RENAME

D3D_structure=simdef.D3D.structure;
IBedCond=simdef.mor.IBedCond;

%% FILE

if any(IBedCond==[2,3,5,7])
    if D3D_structure==1
        D3D_bcm_s(simdef,varargin{:});
    else
        D3D_bcm_u(simdef,varargin{:});
    end
end
