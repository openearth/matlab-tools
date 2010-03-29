function postmessage(message,postteamcity,varargin)
%POSTTEAMCITYMESSAGE  Posts a teamcity message file.
%
%   Matlab automatically retorns zero when started, disconnecting the matlab command window from the
%   process it was started with. To still give messages to this process the runner loops until
%   matlab really finishes (a file called matlab.busy is deleted) and searches for a file called
%   teamcitymessage.matlab that contains a message for teamcity. This message is than displayed and
%   the file is deleted afterwards. this function produces the teamcitymessage.matlab file.
%
%   Syntax:
%   varargout = postteamcitymessage(message, postteamcity, varargin)
%
%   Input:
%   message   = teamcity mssage id
%   postteamcity = bool (logical) specifying whether the message has to be posted or just displayed
%                  in the command window of matlab
%
%   See also oetsettings mtestengine TeamCity_runtests

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 29 Mar 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if postteamcity
    h = tic;
    while exist('teamcitymessage.matlab','file')
        pause(0.001);
        if toc(h) > 1
            delete(which('teamcitymessage.matlab'));
        end
    end
    
    teamcityString = ['##teamcity[', message, ' '];
    if nargin/2~=round(nargin/2)
        for ivararg = 1:length(varargin)
            teamcityString = cat(2,teamcityString,'''',varargin{ivararg},'''');
        end
    else
        for ivararg = 1:2:length(varargin)
            teamcityString = cat(2,teamcityString,varargin{ivararg},'=''', varargin{ivararg+1},'''',' ');
        end
    end
    teamcityString = cat(2,teamcityString,']');
    dlmwrite('teamcitymessage.matlabtemp',...
        teamcityString,...
        'delimiter','','-append');
    % To prevent echo that is too early
    movefile('teamcitymessage.matlabtemp','teamcitymessage.matlab');
else
    disp(message);
end