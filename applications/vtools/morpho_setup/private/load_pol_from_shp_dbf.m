%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18982 $
%$Date: 2023-06-08 10:31:31 +0200 (Thu, 08 Jun 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18982 2023-06-08 08:31:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%

function pol=load_pol_from_shp_dbf(fpath_shp,fpath_dbf)

%% PARSE

fid_log=NaN;

%% CALC

fdir_tmp=fullfile(pwd,'tmp_shp'); %temporary folder for renaming files
mkdir_check(fdir_tmp);

[fdir_shp,fname_shp,ext_shp]=fileparts(fpath_shp);
fpath_shp_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_shp));
copyfile_check(fpath_shp,fpath_shp_tmp);

[fdir_dbf,fname_dbf,ext_dbf]=fileparts(fpath_dbf);
fpath_dbf_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_dbf)); %rename the dbf file with the name of the shp to be able to read
copyfile_check(fpath_dbf,fpath_dbf_tmp);

messageOut(fid_log,'Start reading shp');
pol=D3D_io_input('read',fpath_shp_tmp,'read_val',1);

end