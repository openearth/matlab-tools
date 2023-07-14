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

function D3D_obs(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

if D3D_structure==1
    D3D_obs_s(simdef,'check_existing',check_existing);
else
    D3D_obs_u(simdef,'check_existing',check_existing);
end

