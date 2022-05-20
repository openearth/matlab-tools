%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function [str_sta,str_found]=D3D_convert_station_names_obs_normal(sss)

ns=numel(sss);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(sss{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false);
end