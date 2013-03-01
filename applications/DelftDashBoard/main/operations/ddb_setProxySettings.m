function ddb_setProxySettings(varargin)
%DDB_SETPROXYSETTINGS  Set the proxy settings on initialization or when changed in menu.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles=getHandles;

if isempty(varargin)

    % Changing proxy settings from menu

    ddb_zoomOff;
    
    xmldir=[handles.settingsDir 'xml' filesep];
    xmlfile='delftdashboard.proxysettings.xml';
    
    h=handles.proxysettings;
    
    [h,ok]=gui_newWindow(h,'xmldir',xmldir,'xmlfile',xmlfile,'iconfile',[handles.settingsDir filesep 'icons' filesep 'deltares.gif']);

    if ok
        
        handles.proxysettings=h;
        
        if handles.proxysettings.useproxy
            com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(true);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost(handles.proxysettings.proxyhost);
            com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort(handles.proxysettings.proxyport);
        else
            com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(false);
        end

        % Check if proxy settings file exists
        if ~isdir(handles.proxyDir)
            mkdir(handles.proxyDir)
        end
        
        % No write proxy settings file
        filename=[handles.proxyDir 'proxysettings.xml'];
        
        xml=handles.proxysettings;
        if handles.proxysettings.useproxy
            xml.useproxy='true';
        else
            xml.useproxy='false';
        end
        struct2xml(filename,xml,'structuretype','supershort');
                
    end
    
else
    
    % Changing proxy settings on initialization
    handles.proxysettings.useproxy=0;
    handles.proxysettings.proxyhost='';
    handles.proxysettings.proxyport='';
    
    % Find out if proxy settings file exists
    if isdir(handles.proxyDir)
        if exist([handles.proxyDir 'proxysettings.xml'],'file')
            % If so, read it
            xml=xml2struct([handles.proxyDir 'proxysettings.xml']);
            switch lower(xml.useproxy(1))
                case{'1','y','t'}
                    handles.proxysettings.useproxy=1;
            end
            handles.proxysettings.proxyhost=xml.proxyhost;
            handles.proxysettings.proxyport=xml.proxyport;
            % If use proxy
            if handles.proxysettings.useproxy
                com.mathworks.mlwidgets.html.HTMLPrefs.setUseProxy(true);
                com.mathworks.mlwidgets.html.HTMLPrefs.setProxyHost(handles.proxysettings.proxyhost);
                com.mathworks.mlwidgets.html.HTMLPrefs.setProxyPort(handles.proxysettings.proxyport);
            end
        end
    end
    
end

setHandles(handles);
