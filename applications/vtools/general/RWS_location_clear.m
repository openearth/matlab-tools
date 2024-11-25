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

function [str_sta,str_found]=RWS_location_clear(stationlist)

if ~iscell(stationlist)
    stationlist_c{1,1}=stationlist;
    stationlist=stationlist_c;
end

ns=numel(stationlist);
str_sta=cell(1,ns);
str_found=false(1,ns);
for ks=1:ns
[str_sta{ks},str_found(ks)]=waterDictionary(stationlist{ks},NaN,'normal','dict','rwsNames.csv','stationnodot',false,'do_warning',false);
end

end %function