function EHY_dflowfm_mduTimes
% EHY_dflowfm_mduTimes
% This function calculates the TStart and TStop in Tunit for the .mdu-file
%
% Example: EHY_dflowfm_mduTimes
%
% created by Julien Groenenboom, April 2017
format1='yyyymmdd';
format2='yyyymmdd HHMMSS';

prompt={['RefDate (' format1 '): '],'Tunit (H, M or S): ',...
    'TStart: Start time w.r.t. RefDate (in TUnit)',['TStart: Start time as date (' format2 ')'],...
    'TStop: Stop time w.r.t. RefDate (in TUnit)',['TStop: Stop time as date (' format2 ')']};
input=inputdlg(prompt,'Input',1);
output=input;

RefDateNum=datenum(input{1},format1);

if strcmpi(input{2},'S')
    factor=60*60*24;
elseif strcmpi(input{2},'M')
    factor=60*24;
elseif strcmpi(input{2},'H')
    factor=24;
else
    error('Tunit has to be H, M or S')
end

% TStart
if isempty(input{3}) && ~isempty(input{4})
    TStartNum=datenum(input{4},format2);
    output{3}=num2str((TStartNum-RefDateNum)*factor);
elseif ~isempty(input{3}) && isempty(input{4})
    TStartNum=RefDateNum+str2num(input{3})/factor;
    output{4}=datestr(TStartNum,format2);
end

% TStop
if isempty(input{5}) && ~isempty(input{6})
    TStartNum=datenum(input{6},format2);
    output{5}=num2str((TStartNum-RefDateNum)*factor);
elseif ~isempty(input{5}) && isempty(input{6})
    TStartNum=RefDateNum+str2num(input{5})/factor;
    output{6}=datestr(TStartNum,format2);
end

inputdlg(prompt,'Output',1,output);

clc
disp(['====================EHY_dflowfm_mduTimes==================='])
disp(['RefDate (yyyymmdd):                             ' output{1}])
disp(['Tunit (H, M or S):                              ' output{2}])
disp(['TStart: Start time w.r.t. RefDate (in TUnit):   ' output{3}])
disp(['TStop :  Stop time w.r.t. RefDate (in TUnit):   ' output{5}])
disp(['==========================================================='])
disp(['start date:                                     ' output{4}])
disp(['stop  date:                                     ' output{6}])
disp(['==========================================================='])
