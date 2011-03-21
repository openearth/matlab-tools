function varargout = oetsettingsquiet(varargin)
%OETSETTINGSQ  Run QETSETTINGSQ in quiet mode.
%
%   Runs QETSETTINGSQ in quiet mode suitable for calls from a shortcut or
%   Matlab startup script.
%
%   Syntax:
%   oetsettingsquiet
%
%   Example
%   % set OET_HOME system variable to point to root folder of
%   % OpenEarthTools such as set OET_HOME=C:\checkouts\OpenEarthTools
%   % then run code below from STARTUP script
%   % add OpenEarthTools
%   if ~isempty(getenv('OET_HOME'))
%       oetDir = fullfile(getenv('OET_HOME'),'matlab');
%       if exist(fullfile(oetDir,'oetsettingsquiet.m'),'file')
%           run(fullfile(oetDir,'oetsettingsquiet.m'));
%       end
%       clear oetDir
%   end
%
%   See also OETSETTINGSQ

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Moffatt&Nichol
%       Oleg Mouraenko
%
%       omouraenko@moffattnichol.com
%
%       Moffatt&Nichol
%       11011 Richmond Ave, Suite 200
%       Houston, TX 77064
%       USA
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
% Created: 25 Feb 2011
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

oetsettingsq('quiet')
