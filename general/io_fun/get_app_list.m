function apps = get_app_list(varargin)
%GET_APP_LIST  Returns a list with installed applications from the Windows registry
%
%   Returns a cell array with applications names installed on the current
%   PC according to the Windows registry.
%
%   Syntax:
%   apps = get_app_list(varargin)
%
%   Input:
%   varargin  = none
%
%   Output:
%   apps      = Cell array with application names
%
%   Example
%   apps = get_app_list

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'extended', false ...
);

OPT = setproperty(OPT, varargin{:});

%% get application list

apps = {};

if ispc()
    
    % export registry to file
    fname = tempname;
    regpath = 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\';
    system(['regedit /e ' fname ' "' regpath '"']);

    % read entire file
    fid = fopen(fname, 'r');
    fcontents = fread(fid, Inf, 'uint16=>char');
    fclose(fid);
    delete(fname);
    
    % search for application names
%     if OPT.extended
%         re = regexp(fcontents', ['\[' strrep(regpath, '\', '\\') '.*?\]'], 'split');
%         re2 = regexp(re, '"(.*?)"="(.*?)"', 'tokens');
%         re2(cellfun('isempty',re2)) = [];
%         
%         for i = 1:length(re2)
%             settings = [re2{i}{:}];
%             apps = cell2struct(settings(1:2:end), settings(2:2:end), 2);
%             break;
%         end
%     else
        re = regexp(fcontents', '"DisplayName"="\s*(.*?)\s*"', 'tokens');
        apps = [re{:}];
%     end
elseif isunix()
    error('Unix systems are not supported'); % TODO
else
    error('Unsupported operating system');
end