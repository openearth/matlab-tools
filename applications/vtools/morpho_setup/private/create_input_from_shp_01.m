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

function input_struct=create_input_from_shp_01(fpath_shp,fpath_dbf_csv)

dbf_list=readcell(fpath_dbf_csv,'NumHeaderLines',1,'Delimiter',';');
[fdir,~,~]=fileparts(fpath_dbf_csv);
nd=size(dbf_list,1);

input_struct=struct('shp',{},'dbf',{},'tim',[]);
for kd=1:nd
    input_struct(kd).shp=fpath_shp;
    input_struct(kd).dbf=fullfile(fdir,dbf_list{kd,1});
    input_struct(kd).tim=datenum(dbf_list{kd,2},'dd-mm-yyyy'); %is it read as datetime already? add time zone if not present
end %kd

end %function