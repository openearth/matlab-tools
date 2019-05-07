function [CurFile varargout] = editorCurrentFile
%EDITORCURRENTFILE  provides path to the current file in the matlab editor
%
%   This function uses undocumented matlab stuff to get the path of the
%   file that is currently open in the matlab editor. If more than one
%   files are open it takes the one that is selected).
%
%   Syntax:
%   [CurFile varargout] = EditorCurrentFile
%
%   Output:
%   CurFile   = The path to the current file (string)
%   varargout = java handle to the EditorViewContainer
%
%   Example
%   EditorCurrentFile
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
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

% Created: 08 Apr 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: editorCurrentFile.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/matlabinterface_fun/editorCurrentFile.m $
% $Keywords: $

%% Start of function

% Define the handle for the set of java commands:
desktopHandle=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;

% Determine the last selected document in the editor:
lastDocument=desktopHandle.getLastDocumentSelectedInGroup('Editor');

% Strip off the '*' which indicates that it has been modified.
CurFile=strtok(char(desktopHandle.getTitle(lastDocument)),'*');

if nargout>1
    varargout{1}=lastDocument;
end

%% That's it....