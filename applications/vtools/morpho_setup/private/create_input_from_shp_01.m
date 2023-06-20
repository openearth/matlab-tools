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