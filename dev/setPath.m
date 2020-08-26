function setPath(pathFolder);
% This script add the path all the scripts in the Matlab library
%
%
% INPUTS:-pathFolder (optional): Location to save path
%
% OUTPUTS:-none
%
% STEPS:-
%
% International Marine and Dredging Consultants, IMDC
% Antwerp Belgium
%
%
%% Written by: Sebastian Osorio
%
% Date: Okt 2014
% Modified by:
% Date:

currentDir = fileparts(mfilename('fullpath'));

paths = {currentDir,...
    [currentDir '\Calculate'],...
    [currentDir '\External'],...
    [currentDir '\Input_Output'],...
    [currentDir '\Interpolate'],...
    [currentDir '\Model'],...
    [currentDir '\Plot'],...
    [currentDir '\Util'],...
    [currentDir '\Web'],...
    [currentDir '\Test']};

for nI = 1:length(paths)
    addpath(genpath(paths{length(paths)-nI+1}));
end;
if nargin>=1
    savepath(pathFolder);
else
    savepath;
end