function varargout = publish_OET_documentation(varargin)
%PUBLISH_OET_DOCUMENTATION  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = publish_OET_documentation(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   publish_OET_documentation
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl	
%
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 12 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% add m2html toolbox
addpath([fileparts(which(mfilename)) filesep 'm2html']);

% go to OET root dir
curPath = pwd;
[oetroot, dum] = fileparts(which('oetsettings'));
cd(oetroot);

% prepare m2html inputs
mFiles = {'applications','io','general'};
template = 'blue';
htmlDir = [oetroot filesep 'docs' filesep 'OpenEarthHtmlDocs' filesep template filesep];
ignoredDir = {'.snv'};
excludedFiles = {'.*_test.m'};
source = 'off';
recursive = 'on';
index = 'menu';
search = 'on';

% execute m2html
m2html_AM('mFiles',mFiles,...
    'htmlDir',htmlDir,...
    'source',source,...
    'recursive',recursive,...
    'ignoredDir',ignoredDir,...
    'search',search,...
    'excludedFiles',excludedFiles,...
    'template',template,...
    'index',index);
