function winscp(varargin)
%WINSCP  Use winscp to automatically transfer files
%
%   Very much Work In Progress
%
%   Syntax:
%   winscp(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   winscp
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 02 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
error('WIP')

OPT.source      = '';
OPT.destination = '';

OPT = setproperty(OPT,varargin);

appPath = fullfile(fileparts(which(mfilename)), 'WinSCP.exe');
commandlineString = [appPath ' ' OPT.source ' ' OPT.destination];
system(commandlineString);

http://winscp.net/eng/docs/commandline
http://silverxtreme.org/content/using-winscp-command-line-automate-file-transfer

% winscp.exe [(sftp|ftp|scp)://][user[:password]@]host[:port][/path/[file]]
% winscp.exe ftps://martin@example.com                        /implicit     /certificate="xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
% winscp.exe [session-name] /upload file1 [file2] [file3] /defaults
