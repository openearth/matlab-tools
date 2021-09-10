%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 28 $
%$Date: 2021-09-06 11:46:58 +0200 (Mon, 06 Sep 2021) $
%$Author: chavarri $
%$Id: defaultFlags.m 28 2021-09-06 09:46:58Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/defaultFlags.m $
%

function [str_sta,str_found]=D3D_convert_station_names_obs_normal(sss)

ns=numel(sss);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(sss{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false);
end