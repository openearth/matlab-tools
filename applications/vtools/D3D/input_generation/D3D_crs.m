%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19054 $
%$Date: 2023-07-14 15:34:18 +0200 (Fri, 14 Jul 2023) $
%$Author: chavarri $
%$Id: D3D_obs.m 19054 2023-07-14 13:34:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_obs.m $
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
