function EHY_dflowfm_mduTimes
% EHY_dflowfm_mduTimes
% This function calculates the TStart and TStop in Tunit for the .mdu-file
%
% Example: EHY_dflowfm_mduTimes
%
% created by Julien Groenenboom, April 2017
format1='yyyymmdd';
format2='yyyymmddHHMMSS';

RefDateStr = input(['RefDate (' format1 '): '],'s');
Tunit =      input('Tunit (H, M or S): ','s');
TStart =     input(['TStart: Start time w.r.t. RefDate (in TUnit) OR date (' format2 '), : '],'s');
TStop =      input(['TStop: Stop time w.r.t. RefDate (in TUnit) OR date (' format2 '), : '],'s');

RefDateNum=datenum(RefDateStr,'yyyymmdd');

if strcmpi(Tunit,'S')
    factor=60*60*24;
elseif strcmpi(Tunit,'M')
    factor=60*24;
elseif strcmpi(Tunit,'H')
    factor=24;
else
    error('Tunit has to be H, M or S')
end

% TStart
try % TStart was given as a date
    datenum(TStart,format2);
    TStartNum=datenum(TStart,format2);
    TStart_unit=(TStartNum-RefDateNum)*factor;
catch % TStart was given w.r.t. RefDate (in TUnit)
    TStartNum=RefDateNum+str2num(TStart)/factor;
    TStart_unit=str2num(TStart);
end
% TStop
try % TStop was given as a date
        datenum(TStop,format2);
    TStopNum=datenum(TStop,format2);
    TStop_unit=(TStopNum-RefDateNum)*factor;
catch % TStop was given w.r.t. RefDate (in TUnit)
    TStopNum=RefDateNum+str2num(TStop)/factor;
    TStop_unit=str2num(TStop);
end
clc
disp(['====================EHY_dflowfm_mduTimes==================='])
disp(['RefDate (yyyymmdd):                             ' RefDateStr])
disp(['Tunit (H, M or S):                              ' Tunit])
disp(['TStart: Start time w.r.t. RefDate (in TUnit):   ' num2str(TStart_unit) ])
disp(['TStop :  Stop time w.r.t. RefDate (in TUnit):   ' num2str(TStop_unit) ])
disp(['==========================================================='])
disp(['start date:                                     ' datestr(TStartNum)])
disp(['stop  date:                                     ' datestr(TStopNum)])
disp(['==========================================================='])

