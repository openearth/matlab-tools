function testresult = OPT2txt_test
% OPT2TXT_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also: OPT2txt, txt2OPT

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jan 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;



%% some test data
OPT.double1 = [1 2 3; 1 3 6];
OPT.double2 = magic(10);
OPT.double3 = [];
OPT.double4 = [ 1 2 3 nan 2 1];
% OPT.double5 = [nan]; % does not work
OPT.char1   = char([1:12 14:127]); % char(13) does not process correctly
OPT.char3   = ['sdg sdg shseths' char(10) 'sdg sdg shseths'];
OPT.cell1   = {'sdg',1:5;'a','b'};
OPT.cell2   = {'sdg',1:5,'a'};
OPT.char4   = char([1:12 14:127]);
% OPT.char5   = ['asfasf';'asfasf']; does not work

%% save it
fname = fullfile(tempdir,'OPT.txt');

%% read it
OPT2txt(OPT,fname);
OPT2 = txt2OPT(fname);

%% compare OPT vs OPT2
fields = fieldnames(OPT);
testresult = false(size(fields));
for ii = 1:length(fields);
    testresult(ii) = isequalwithequalnans(OPT.(fields{ii}),OPT2.(fields{ii}));
end

testresult = all(testresult);