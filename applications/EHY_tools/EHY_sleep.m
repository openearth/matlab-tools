function [varargout] = EHY_sleep (varargin)
%% EHY_sleep(varargin)
%
% This functions helps ensuring that young HAF moms and dads get enough sleep
%
%% initialise
fileName      = mfilename('fullpath');
[dirName,~,~] = fileparts(fileName);

%% Irfanview installed?
if ~exist('c:\Program Files\IrfanView\i_view64.exe')
    txt = sprintf(['This program requires irfanview for displaying images (to avoid using the matlab image toolbox) \n' ...
             'Please install from: https://www.fosshub.com/IrfanView.html']);
    display(txt);
end

%% Check!
nr_times = input('How many times do you feed your baby (natural or by bottle) a day? ');

%% Assign
if nr_times >=10
    fileName = [dirName filesep 'sb.gif'];
else
    fileName = [dirName filesep 'cb.gif'];
end

%% Display
system (['"c:\Program Files\IrfanView\i_view64.exe" /file=' fileName]);

