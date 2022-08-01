%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17614 $
%$Date: 2021-11-30 12:06:07 +0100 (Tue, 30 Nov 2021) $
%$Author: chavarri $
%$Id: D3D_observation_stations.m 17614 2021-11-30 11:06:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_observation_stations.m $
%

function stru_out=D3D_read_xyn(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'version',1);

parse(parin,varargin{:});

v=parin.Results.version;


%%
obs_xy=readmatrix(fname,'FileType','text');
obs_nam=readcell(fname,'FileType','text');

switch v
    case 1
        stru_out.name=obs_nam(:,3)';
        stru_out.x=obs_xy(:,1)';
        stru_out.y=obs_xy(:,2)';
    case 2
        stru_out=struct('name',obs_nam(:,3),'xy',num2cell(obs_xy(:,1:2),2));
end
end %function