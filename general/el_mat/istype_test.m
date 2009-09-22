function testresult = istype_test()
% ISTYPE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

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
% Created: 11 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = istype)
% Publishable code that describes the test.

%% $RunCode
testresult = all(istype([gca gca],'axes')) &&...
    all(istype([gcf gcf],'axes')==[false false]) &&...
    all((istype([gca gca],'figure'))==[false false]) && ...
    all(istype([gcf gcf],'figure')) && ...
    all(istype([gcf gca],'figure')==[true false]) && ...
    all(istype([gcf gca],'axes')==[false true]) && ...
    all(istype([gcf gca text(1,1,'a') text(1,1,'a')],'figure')==[true false false false]) && ...
    all(istype([gcf gca text(1,1,'a') text(1,1,'a')],'axes')==[false true false false]) && ...
    all(istype([gcf gca text(1,1,'a') text(1,1,'a')],'text')==[false false true true]);

%% $PublishResult
% Publishable code that describes the test.
