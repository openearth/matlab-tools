function testresult = nansparse_test()
% NANSPARSE_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com	
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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

% This tools is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;

% create test data
data = rand(100,1000);
data(data>0.02) = NaN;
data(data<0.01) = 0;

% create nansparse of testdata
ns = nansparse(data);

% test various ways of indexing the nansparse, and compare to original
% data. Also, check > and < functions
testresult = ...
    isequalwithequalnans(data(1:10,1:end),full(ns(1:10,1:end))            ) &&...
    isequalwithequalnans(data            ,full(ns(:   ,1:end)),full(ns)   ) &&...
    isequalwithequalnans(data(1:end)'    ,full(ns(1:end)'    ),full(ns(:))) &&...
    isequalwithequalnans(data> 0.015     ,full(ns> 0.015)) &&...
    isequalwithequalnans(data< 0.015     ,full(ns< 0.015)) &&...
    isequalwithequalnans(data>=0.015     ,full(ns>=0.015)) &&...
    isequalwithequalnans(data<=0.015     ,full(ns<=0.015)) &&...
    isequalwithequalnans(size(data,1)    ,size(ns,1)     ) &&...
    isequalwithequalnans(size(data)      ,size(data)     );

