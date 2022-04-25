%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17593 $
%$Date: 2021-11-16 10:28:04 +0100 (Tue, 16 Nov 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17593 2021-11-16 09:28:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function stations=gdm_station_names(fid_log,flg_loc,fpath_his)

if isnan(flg_loc.stations)
    stations=EHY_getStationNames(fpath_his,'dfm');
else
    stations=flg_loc.stations;
end

end %function
