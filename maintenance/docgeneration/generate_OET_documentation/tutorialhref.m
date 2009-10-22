function str = tutorialhref(name,htmlname)
%TUTORIALHREF  Creates an html ref for a tutorial in OET.
%
%   This function creates the html href needed to open a 
%   tutorials in the matlab help navigator.
%
%   Syntax:
%   str = tutorialhref(name,target)
%
%   Input:
%   name   = name of the href
%   html = name of the html file it needs to reference to
%
%   Output:
%   str    = html string
%
%   Example
%   str = tutorialhref('test_tutorial','test_tutorial');
%
%   See also href publish

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Oct 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Construct target
[dum nm] = fileparts(htmlname);
trg = ['matlab:',...
    'web([''jar:file:///'' strrep(openearthtoolsroot,filesep,''/'') ''docs/OpenEarthDocs/oethelpdocs/help.jar!/html/',...
    nm '.html',...
    '''], ''-helpbrowser'');'];

str = href(name,trg);
