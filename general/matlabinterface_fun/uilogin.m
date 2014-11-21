function [username password] = uilogin(varargin)
%UILOGIN  Prompts for a username and password using a dialog
%
%   Prompts for a username and password and returns password string
%
%   Syntax:
%   [username password] = uilogin(<username>)
%
%   Input:
%   <username>  = username string (OPTIONAL)
%
%   Output:
%   username    = username string
%   password    = password string
%
%   Example
%   [username password] = uilogin;
%   [username password] = uilogin('my username');
%
%   See also uicontrol

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%       Freek Scheel (small update for username input)
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
% Created: 21 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% create password dialog

if ~ispc(); error('This function only works for Windows systems'); end;

if length(varargin) == 0
    user_text = '';
elseif ischar(varargin{1})
    user_text = varargin{1};
else
    error('Unknown input specified');
end

s = get(0,'ScreenSize');
w = 300; h = 90;
pos = [(s(3)-w)/2 (s(4)-h)/2 w h];

dlg = dialog('Name', 'Login', 'pos', pos);

uicontrol(dlg, 'style', 'text', 'units', 'pixels', ...
    'pos', [20 50 60 15], 'Horiz', 'Left', ...
    'string', 'Username:');

uicontrol(dlg, 'style', 'text', 'units', 'pixels', ...
    'pos', [20 20 60 15], 'Horiz', 'Left', ...
    'string', 'Password:');

user = javax.swing.JTextField();
user = javacomponent(user, [100 50 120 20], dlg);
set(user, 'KeyPressedCallback', {@submit, dlg}, 'Text', user_text);
user.setFocusable(true);
drawnow;

pass = javax.swing.JPasswordField();
pass = javacomponent(pass, [100 20 120 20], dlg);
set(pass, 'KeyPressedCallback', {@submit, dlg});
pass.setFocusable(true);
drawnow;

uicontrol(dlg, 'style', 'PushButton', ...
    'pos', [240 20 40 20], 'string', 'OK', ...
    'callback', 'uiresume', 'KeyPressFcn', {@submit, dlg});

if strcmp(user_text,'')
    user.requestFocus;
else
    pass.requestFocus;
end

uiwait(dlg);

if ishandle(user) && ishandle(pass)
    username = deblank(get(user, 'Text'));
    password = deblank(get(pass, 'Text'));
else
    username = '';
    password = '';
end

if ishandle(dlg)
    close(dlg);
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function submit(obj, event, dlg)
    if isjava(event)
        key = get(event, 'keyCode');
    else
        key = event.Key;
    end
    
    switch key
        case {10 'return'}
            uiresume(dlg);
    end