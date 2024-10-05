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

%% PATHS

fpath_add_oet='p:\studenten-riv\05_OpenEarthTools\01_matlab\applications\vtools\general\addOET.m';
fdir_d3d='p:\studenten-riv\05_OpenEarthTools\02_qp\';

%% ADD OET

if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% INPUT

fdir_rain='p:\dflowfm\users\chavarri\02_weather\';
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
            errstatus_dw=1; %if you don't manage to read, try to download again
            messageOut(NaN,'Trying to read.')
            [rain_one,errstatus_rd,errmessage]=read_web_buienradar(fpath_html);
        end
        errstatus_rd=1; %set to error, such that it reads in the next loop
        
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
        messageOut(NaN,'Data read.')
    else
        messageOut(NaN,'In pause.')
        pause(T_data/6);
    end
    
end