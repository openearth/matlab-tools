function EHY_simulationInputTimes(varargin)
%% EHY_simulationInputTimes
%
% This function calculates the start and stop time w.r.t. the reference date
% of D-FLOW FM, Delft3D and SIMONA models.
% As input, one of the corresponding input files (.mdu / .mdf / siminp) can
% be provided
%
% Example1: EHY_simulationInputTimes
% Example2: EHY_simulationInputTimes('D:\model.mdu')
%
% created by Julien Groenenboom, April 2017

%% general settings
format{1}='yyyymmdd';
format{2}='yyyymmdd HHMMSS';

%% get time info from mdFile
if nargin==0
    [option,~]=  listdlg('PromptString','Choose between:',...
        'SelectionMode','single',...
        'ListString',{'Start with blank fields','Open a .mdu / .mdf or SIMONA file as input'},...
        'ListSize',[300 50]);
    if option==1
        mdInput={'','','','','',''};
    elseif option==2
        [filename, pathname]=uigetfile('*.*','Open a .mdu / .mdf / siminp file');
        mdFile=[pathname filename];
    end
elseif nargin==1
    mdFile=varargin{1};
end

if exist('mdFile','var')
    modelType=nesthd_det_filetype(mdFile);
    [pathstr,name,ext]=fileparts(mdFile);
    [refdate,tunit,tstart,tstop]=getTimeInfoFromMdFile(mdFile);
   
     mdInput{1}=datestr(refdate,format{1});
     mdInput{2}=tunit;
     mdInput{3}=num2str(tstart);
     mdInput{5}=num2str(tstop);

    % complement the mdInput
    mdInput=EHY_simulationInputTimes_calc(mdInput,format);
    mdInput=cellfun(@num2str,mdInput,'UniformOutput',0);
end

%% get input from user
prompt={['RefDate (' format{1} '): '],'Tunit (H, M or S): ',...
    'TStart: Start time w.r.t. RefDate (in TUnit)',['TStart: Start time as date (' format{2} ')'],...
    'TStop: Stop time w.r.t. RefDate (in TUnit)',['TStop: Stop time as date (' format{2} ')']};
userInput=inputdlg(prompt,'Input',1,mdInput);

%% check changes wrt mdInput
[~,changedLine]=setdiff(mdInput,userInput);

% if RefDate was changed, recompute TStart and TStop
if any(changedLine==1); userInput{3}=''; userInput{5}=''; end
% if TUnit was changed, recompute start date and stop date
if any(changedLine==2); userInput{3}=''; userInput{5}=''; end
% if TStart was changed, change start date and vice versa.
if any(changedLine==3); userInput{4}=''; elseif any(changedLine==4); userInput{3}='';  end
% if TStop was changed, change stop date and vice versa.
if any(changedLine==5); userInput{6}=''; elseif any(changedLine==6); userInput{5}='';  end

%% complement the userInput and display output
output=EHY_simulationInputTimes_calc(userInput,format);
% inputdlg(prompt,'Output',1,output);

clc
disp(['========================EHY_simulationInputTimes========================'])
disp(['RefDate (yyyymmdd) :                            ' output{1}])
disp(['Tunit   (H, M or S):                            ' output{2}])
disp(['TStart: Start time w.r.t. RefDate (in TUnit):   ' output{3}])
disp(['TStop :  Stop time w.r.t. RefDate (in TUnit):   ' output{5}])
disp(['========================================================================'])
disp(['start date:                                     ' output{4}])
disp(['stop  date:                                     ' output{6}])
disp(['========================================================================'])

end
%% calculate missing fields
function A=EHY_simulationInputTimes_calc(A,format)
if length(A)<6
    for ii=length(A)+1:6
        A{ii}='';
    end
end

RefDateNum=datenum(num2str(A{1}),format{1});
factor=timeFactor(A{2},'D');

% TStart
if isempty(A{3}) && ~isempty(A{4})
    TStartNum=datenum(A{4},format{2});
    A{3}=num2str((TStartNum-RefDateNum)*factor);
elseif ~isempty(A{3}) && isempty(A{4})
    TStartNum=RefDateNum+str2double(A{3})*factor;
    A{4}=datestr(TStartNum,format{2});
end

% TStop
if isempty(A{5}) && ~isempty(A{6})
    TStartNum=datenum(A{6},format{2});
    A{5}=num2str((TStartNum-RefDateNum)*factor);
elseif ~isempty(A{5}) && isempty(A{6})
    TStartNum=RefDateNum+str2double(A{5})*factor;
    A{6}=datestr(TStartNum,format{2});
end
end