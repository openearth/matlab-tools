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
%

function data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% READ RAW

data_sal=gdm_read_data_map(fdir_mat,fpath_map,'sal','tim',time_dnum,'idx_branch',idx_branch,'branch',branch); 
data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum,'idx_branch',idx_branch,'branch',branch); 

%% CALC

%squeeze to take out the first (time) dimension. Then layers are in dimension 2.
cl=sal2cl(1,squeeze(data_sal.val)); %mgCl/l
thk=diff(squeeze(data_zw.val),1,2); %m
mass=sum(cl/1000.*thk,2,'omitnan')'; %mgCl/m^2; cl*1000/1000/1000 [kgCl/m^2]

%data
data_var.val=mass; 

end %function