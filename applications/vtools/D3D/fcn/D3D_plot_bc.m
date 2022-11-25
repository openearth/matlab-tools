%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17522 $
%$Date: 2021-10-18 07:45:10 +0200 (Mon, 18 Oct 2021) $
%$Author: chavarri $
%$Id: fig_data_station.m 17522 2021-10-18 05:45:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/fig_data_station.m $
%

function D3D_plot_bc(fpath_bc)

%% READ

bc=D3D_io_input('read',fpath_bc);

fdir=fileparts(fpath_bc);

%% PLOT

nbc=numel(bc.Table);

for kbc=1:nbc
    bc_nam=bc.Table(kbc).Location;
    
    in_p.data_station.location_clear=strrep(bc_nam,'_','\_');
    in_p.data_station.grootheid=bc.Table(kbc).Parameter(2).Name;
    in_p.lan='en';
    in_p.data_station.time=bc.Table(kbc).Time;
    in_p.data_station.waarde=bc.Table(kbc).Data(:,2); %check that there is no more data
    in_p.fig_visible=0;
    in_p.fig_print=1;
    in_p.fname=fullfile(fdir,clean_str(bc_nam));
    in_p.fig_size=[0,0,14,7];
    
    fig_data_station(in_p);
end