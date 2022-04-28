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

function stations=gdm_station_names(fid_log,flg_loc,fpath_his)

if isnan(flg_loc.stations)
    stations=EHY_getStationNames(fpath_his,'dfm');
else
    stations=flg_loc.stations;
end

end %function
