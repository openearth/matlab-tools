%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19054 $
%$Date: 2023-07-14 15:34:18 +0200 (Fri, 14 Jul 2023) $
%$Author: chavarri $
%$Id: D3D_obs_s.m 19054 2023-07-14 13:34:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_obs_s.m $
%
%obs file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_crs_s(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;

obs_cord=simdef.mdf.crs_cord;
obs_name=simdef.mdf.crs_name;

np=size(simdef.mdf.crs_cord,1); %number of observation points

%% FIND M N

%This is not good. We first should find whether it is a U or a V cross-section. 
%Then, we should find the coordinate in grid.u_full or grid.v_full
ponts_xy=cat(1,obs_cord(:,1:2),obs_cord(:,3:4)); %order in [np,2] = [x,y]
points_nm=D3D_xy2nm(simdef.file.grd,ponts_xy,'position','cor');
crs_nm=cat(2,points_nm(1:end/2,:),points_nm(end/2+1:end,:));

%% FILE

for kp=1:np
data{kp, 1}=sprintf('%s                    %d     %d     %d     %d',obs_name{kp},crs_nm(kp,1),crs_nm(kp,2),crs_nm(kp,3),crs_nm(kp,4));
end

%% WRITE

% file_name=fullfile(dire_sim,'obs.obs');
file_name=simdef.file.crs;
writetxt(file_name,data,'check_existing',check_existing);

