function createneweditordocument(str)
%CREATENEWEDITORDOCUMENT  Creates a new document in the matlab editor.
%
%   This function creates a new document in the matlab editor with the
%   string as specified in the input.
%
%   Syntax:
%   createneweditordocument(str)
%
%   Input:
%   str       = (string) Body of the new document
%
%   Example 
%   createneweditordocument('function test()');
%
%   See also oetnewfun oetnewtest oetnewclass

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
% Created: 24 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: createneweditordocument.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/oet_template/createneweditordocument.m $
% $Keywords: $

%% Check input
if nargin == 0
    str = '';
end

%% Check version and open document
if ~exist('verLessThan','file') || verLessThan('matlab', '7.11')
    com.mathworks.mlservices.MLEditorServices.newDocument(str)
else
    document = com.mathworks.mlservices.MLEditorServices.getEditorApplication.newEditor(str);
    document.smartIndentContents;
end