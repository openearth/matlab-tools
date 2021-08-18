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

% path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';
path_add_fcn='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\';
addpath(path_add_fcn)
addOET(path_add_fcn)

%% INPUT

fdir_rain='p:\i1000561-riverlab-2021\04_weather\';
url_br='https://www.buienradar.nl/weer/delft/nl/2757345/14daagse';
T_data=3600;

%% CALC

t_last=datetime(2000,01,01);

fname_rain=fullfile(fdir_rain,'rain.mat');
errstatus_dw=1;
errstatus_rd=1;
rain_one=struct();
while 1
    t_now=datetime('now');
    if seconds(t_now-t_last)>T_data
        while errstatus_rd
            while errstatus_dw
                pause(15)
                messageOut(NaN,'Trying to download.')
                t_now=datetime('now');
                fpath_html=fullfile(fdir_rain,sprintf('file_%f.html',datenum(t_now)));
                errstatus_dw=download_web(url_br,fpath_html);
            end
            messageOut(NaN,'Trying to read.')
            [rain_one,errstatus_rd,errmessage]=read_web_buienradar(fpath_html);
        end
%         fclose all; %this should not be necessary, but for some reason sometimes the file cannot be deleted
%         pause(5); %maybe this helps
%         delete(fpath_html);
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
        errstatus_rd=1;
        errstatus_dw=1;
        messageOut(NaN,'Data read.')
    else
        messageOut(NaN,'In pause.')
        pause(T_data/6);
    end
    
end