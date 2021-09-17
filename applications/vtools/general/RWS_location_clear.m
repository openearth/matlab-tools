%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17480 $
%$Date: 2021-09-10 15:22:14 +0200 (Fri, 10 Sep 2021) $
%$Author: chavarri $
%$Id: read_data_stations.m 17480 2021-09-10 13:22:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/read_data_stations.m $
%

function [str_sta,str_found]=RWS_location_clear(stationlist)

if ~iscell(stationlist)
    stationlist_c{1,1}=stationlist;
end
stationlist=stationlist_c;

ns=numel(stationlist);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(stationlist{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false);
end

end %function