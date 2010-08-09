function testresult = getFunctionCall_test()
% GETFUNCTIONCALL_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Aug 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTest.category('UnCategorized');

testresult = [];

% test 1: only functionname
testresult(end+1) = strcmp('test1',...
    getFunctionCall(@test1));

% test 2: only functionname and brackets without input
testresult(end+1) = strcmp('test2()', getFunctionCall(@test2));

% test 3: only input, but no output
testresult(end+1) = strcmp('test3(varargin)', getFunctionCall(@test3));

% output between brackets
testresult(end+1) = strcmp('[varargout] = test4(varargin)', getFunctionCall(@test4));

% output without brackets
testresult(end+1) = strcmp('varargout = test5(varargin)', getFunctionCall(@test5));

% function distributed over multiple lines
testresult(end+1) = strcmp('varargout = test6( varargin)', getFunctionCall(@test6));

%% combine all testresults in one boolean
testresult = all(testresult);

%% test subfunctions
function test1

function test2()

function test3(varargin)

function [varargout] = test4(varargin)

function varargout = test5(varargin)

function ...
    varargout ...
    = ...
    test6(...
    varargin)