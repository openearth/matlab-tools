%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18086 $
%$Date: 2022-06-01 10:12:31 +0200 (Wed, 01 Jun 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 18086 2022-06-01 08:12:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;

%% READ RAW

data_sal=gdm_read_data_map(fdir_mat,fpath_map,'sal','tim',time_dnum); 
data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum);

%% CALC

%squeeze to take out the first (time) dimension. Then layers are in dimension 2.
cl=sal2cl(1,squeeze(data_sal.val)); %mgCl/l
thk=diff(squeeze(data_zw.val),1,2); %m
mass=sum(cl/1000.*thk,2,'omitnan')'; %mgCl/m^2; cl*1000/1000/1000 [kgCl/m^2]

%data
data_var.val=mass; 

end %function