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
%crs file creation
%
%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_crs(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% FILE

if simdef.D3D.structure==1
    D3D_crs_s(simdef,'check_existing',check_existing);
else
    warning('To be done.')
%     D3D_obs_u(simdef,'check_existing',check_existing);
end

end %function
