function detran_about
%DETRAN_ABOUT Detran GUI function that displays the about-information
%
%   See also detran

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

% find the path to detran_about.txt
% detranPath = [fileparts(which('detran.m')) filesep];
% if isdeployed
%     detranPath = detranPath(1:end-7);
% end
% 
% aboutPath = [detranPath filesep 'detran_gui' filesep]

aboutPath = ShowPath;
disp(['Path is: ' ShowPath]);

fid=fopen([aboutPath filesep 'detran_about.txt']);
aboutText=fread(fid,'char');
aboutText(aboutText==13)=[];

uiwait(msgbox(char(aboutText'),'About Detran','modal'));

function [thePath] = ShowPath()
% Show EXE path:
if isdeployed % Stand-alone mode.
    [status, result] = system('set PATH');
    thePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % Running from MATLAB.
    [macroFolder, baseFileName, ext] = fileparts(mfilename('fullpath'));
    thePath = macroFolder;
    % thePath = pwd;
end