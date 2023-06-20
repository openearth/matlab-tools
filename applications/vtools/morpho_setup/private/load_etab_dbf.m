%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18966 $
%$Date: 2023-05-26 09:39:44 +0200 (Fri, 26 May 2023) $
%$Author: chavarri $
%$Id: interpolate_bed_level_from_xlsx.m 18966 2023-05-26 07:39:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/interpolate_bed_level_from_xlsx.m $
%
%

function [etab_cen,pol]=load_etab_dbf(fpath_shp,fpath_data)

fid_log=NaN;

%temporary folder for renaming files
fdir_tmp=fullfile(pwd,'tmp_shp');
mkdir_check(fdir_tmp);

[fdir_shp,fname_shp,ext_shp]=fileparts(fpath_shp);
fpath_shp_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_shp));
copyfile_check(fpath_shp,fpath_shp_tmp);

[fdir_dbf,fname_dbf,ext_dbf]=fileparts(fpath_data);
fpath_dbf_tmp=fullfile(fdir_tmp,sprintf('%s%s',fname_shp,ext_dbf)); %rename the dbf file with the name of the shp to be able to read
copyfile_check(fpath_data,fpath_dbf_tmp);

messageOut(fid_log,'Start reading shp');
pol=D3D_io_input('read',fpath_shp_tmp,'read_val',1);
str_pol={'polygon:MEAN','polygon:COUNT'}; 
polnames=cellfun(@(X)X.Name,pol.val,'UniformOutput',false);
idx_pol=find_str_in_cell(polnames,str_pol);
if any(isnan(idx_pol))
    error('Could not find variable in shapefile %s. Maybe the variable name is different.',fpath_shp_tmp);
end
etab_cen=pol.val{idx_pol(1)}.Val;
count=pol.val{idx_pol(2)}.Val;

bol_nd=count==0;
etab_cen(bol_nd)=NaN;

end %function
