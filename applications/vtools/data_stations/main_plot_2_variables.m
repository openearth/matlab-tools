%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18286 $
%$Date: 2022-08-09 13:35:55 +0200 (Tue, 09 Aug 2022) $
%$Author: chavarri $
%$Id: main_plot_all_data_stations.m 18286 2022-08-09 11:35:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/data_stations/main_plot_all_data_stations.m $
%

%% PREAMBLE

clear
clc
fclose all;

%% PATHS

fpath_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\'; %path to this folder in OET

%% ADD OET

if isunix
    fpath_add_fcn=strrep(strrep(strcat('/',strrep(fpath_add_fcn,'P:','p:')),':',''),'\','/');
end
addpath(fpath_add_fcn)
addOET(fpath_add_fcn) 

%% INPUT

paths_main_folder='C:\Users\chavarri\checkouts\riv\data_stations\'; %path to <data_stations>

%% PATHS

paths=paths_data_stations(paths_main_folder);

%% CALC

load(paths.data_stations_index);

%% DATA

d1=read_data_stations(paths_main_folder,'location_clear','Lobith','grootheid','Q');
d2=read_data_stations(paths_main_folder,'location_clear','Krimpen a/d IJssel','grootheid','CONCTTE','bemonsteringshoogte',-5.5);

%% filter

d2.waarde(d2.waarde>2e11)=NaN;
d2.waarde(d2.waarde<0)=NaN;

%% match

time_out=datetime(2018,01,01,0,0,0,'TimeZone',d1.time.TimeZone):minutes(10):datetime(2019,01,01,0,0,0,'TimeZone',d1.time.TimeZone);
data_int=interpolate_timetable({d1.time,d2.time},{d1.waarde,d2.waarde},time_out);

%%

close all

in_p.d1=d1;
in_p.d2=d2;
in_p.tlims=[time_out(1),time_out(end)];
in_p.dint=data_int;
in_p.fig_print=[1,2];

fig_2_variables(in_p);

