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

function D3D_obs_s(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

dire_sim=simdef.D3D.dire_sim;

obs_cord=simdef.mdf.obs_cord;
obs_name=simdef.mdf.obs_name;

np=size(simdef.mdf.obs_cord,1); %number of observation points

%% FIND M N

obs_mn=D3D_xy2nm(simdef.file.grd,obs_cord);
    
%% FILE

for kp=1:np
data{kp, 1}=sprintf('%s                   %d     %d',obs_name{kp},obs_mn(kp,1),obs_mn(kp,2));
end

%% WRITE

% file_name=fullfile(dire_sim,'obs.obs');
file_name=simdef.file.obs;
writetxt(file_name,data,'check_existing',check_existing);

