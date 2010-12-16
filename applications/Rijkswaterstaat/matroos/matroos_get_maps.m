function varargout = matroos_get_maps(input);
%Download MATROOS data (December 2010)
%Bram van Prooijen, Joris Vanlede, Gerben de Boer
%
%MATROOS_GET_MAPS  retrieve maps from Rijkswaterstaat MATROOS database
%
% matlab wrapper for matroos url call /direct/get_series.php
% on http://matroos.deltares.nl. You need a free password for this.
%
%note: in the present version, we use:
%serverurl='http://matroos.deltares.nl:80//matroos/scripts/matroos.pl?';
%this implies, that you are logged in already...
%
%  struct                 = matroos_get_series(<keyword,value>);
%
% where the following <keyword,value> are defined:
% REQUIRED matroos url keywords:
% - source    : The source as known by Matroos (see MATROOS_LIST).
% - xmin,xmax,ymin,ymax  : the corners of the area 
% - coords    : coordinate system, e.g. 'RD'
% - tstart    : First time for the timeseries in format YYYYMMDDHHMM.
%               Any '-', <space>, or ':' will be ignored, so a format like 
%               YYYY-MM-DD HH:MM will be accepted as well
% - tstop     : Last time for the timeseries in the same format as tstart.
% - field     : the required variables: 'H' for waterdepth, 'sep' for water
% level, 'VELUV_abs' for absolute velocity.
% 
% see http://matroos.deltares.nl/maps/start/ for further options
%
%
% example input file:
% source = 'kustfijn_astro';
% xmin   = 130000;
% xmax   = 170000;
% ymin   = 570000;
% ymax   = 600000;
% coords = 'RD';
% tstart = '200906300000'; %format YYYYMMDDHHMM
% tstop  = '200907010000';
% field  = {'H','sep','VELUV_abs'};


%% ini
serverurl='http://matroos.deltares.nl:80//matroos/scripts/matroos.pl?';
formaat = 'nc';
%% MATROOS URL's

eval(input)

%Samenstellen URL's
for f=1:length(field)
URL{f}=[serverurl ...
        'source='        source ...
        '&xmin='         num2str(xmin) ...
        '&xmax='         num2str(xmax) ...
        '&ymin='         num2str(ymin) ...
        '&ymax='         num2str(ymax) ...
        '&coords='       coords ...
        '&color='        field{f} ...
        '&interpolate=count' ...
        '&from='         tstart ...
        '&to='           tstop ...
        '&outputformat=' formaat...
        '&xn='           ...
        '&yn='           ...
        '&celly=&cellx=' ...
        '&fieldoutput='  field{f} ...
        '&format='       formaat];
end

%% Retrieve Data
disp('*** Start Data Retrieval')
for f=1:length(field)
    %filename
    datafile{f}=['VLIE_' field{f} '_' num2str(tstart) '_' num2str(tstop) '_' coords '.nc'];
    
    %retrieve data
    urlwrite(URL{f},datafile{f});
    
    %verbose
    disp(['*** Retrieved dataset ' datafile{f}])
end
disp('*** End Data Retrieval')

%% Make one datastructure
FLOW.x=nc_varget(datafile{1},'x');
FLOW.y=nc_varget(datafile{1},'y');

for f=1:length(field)
    switch field{f}
        case 'H'
            FLOW.H=nc_varget(datafile{f},'H');
            FLOW.comment{f}='H is the depth in [m]';
        case 'sep'
            FLOW.sep=nc_varget(datafile{f},'sep');
            FLOW.time_sep=double(nc_varget(datafile{f},'time'))/1440+datenum('01-Jan-1970 00:00:00');
            FLOW.comment{f}='sep is the waterlevel in [m]';
        case 'VELUV_abs'
            FLOW.VELUV_abs=nc_varget(datafile{3},'VELUV_abs');
            FLOW.time_VELUV_abs=double(nc_varget(datafile{f},'time'))/1440+datenum('01-Jan-1970 00:00:00');
            FLOW.comment{f}='VELUV_abs is the absolute velocity in [m/s]';
    end
end

varargout       = {FLOW};