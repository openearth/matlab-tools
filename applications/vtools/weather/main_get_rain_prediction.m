%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

%% PREAMBLE

clear
clc
fclose all;

%% ADD OET

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
% path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

fdir_rain='p:\i1000561-riverlab-2021\04_weather\';
url_br='https://www.buienradar.nl/weer/delft/nl/2757345/14daagse';
T_data=1;

%% CALC

t_last=datetime(2000,01,01);
fpath_html=fullfile(fdir_rain,'file.html');
fname_rain=fullfile(fdir_rain,'rain.mat');

while 1
    
    t_now=datetime('now');
    if seconds(t_now-t_last)>T_data
        errstatus=download_web(url_br,fpath_html);
        [rain_one,errstatus,errmessage]=read_web_buienradar(fpath_html);
        delete(fpath_html);
        rain_one.tim_anl=datetime('now');
        if exist(fname_rain,'file')==2
            load(fname_rain,'rain');
            nr=numel(rain);
            rain(nr+1)=rain_one;
        else
            rain=rain_one;
        end
        save(fname_rain,'rain')
        t_last=t_now;
    else
        pause(T_data/6);
    end
    
end