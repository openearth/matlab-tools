function EHY_wait(varargin)
% EHY_wait(varargin)
% EHY_wait(time,path)
% Onces TIME is reached, this function runs the PATH
% time can be either a datenum or datestr
%
% Example1: EHY_wait
% Example2: EHY_wait('23-Mar-2018 12:00','D:\script.m')
%
% created by Julien Groenenboom, March 2017

if nargin==0
    disp('Select MATLAB-script to run')
    path=uigetfile('*.m','Select MATLAB-script to run');
    if isnumeric(path); disp('EHY_wait was stopped by user'); return; end
    disp('Select MATLAB-script to run')
    time=inputdlg('After what time would you like to execute this script? [dd-mm-yyyy HH:MM]','EHY_wait',1,{datestr(now,'dd-mm-yyyy HH:MM')});
    if isempty(time); disp('EHY_wait was stopped by user'); return; end
    time=datenum(time,'dd-mm-yyyy HH:MM');
elseif narargin==2
    time=varargin{1};
    path=varargin{1};
end

if ~isnumeric(time)
    time=datenum(time);
end

[pathstr, name, ext] = fileparts(path);

keepLooping=1;
while keepLooping
    if now > time
        run(path)
        keepLooping=0;
    else
        disp(['Waiting until ' datestr(time) ' to run the script ''' name ext ''' - time now: ' datestr(now)]);
        pause(5)
    end
end

