function testresult = dir2_test()
% DIR2_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

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
% Created: 13 Mar 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;

%% compare outcomes of dir and dir2

current_dir = pwd;
cd(oetroot)

% compare behaviour of dir and dir2 for a range of filepaths
testpath = {...
    '.'         ,... current dir
    'docs'      ,... current dir\docs
    '..\matlab' ,... up one\matlab
    '/..'       ,... D:
    '\..'       ,... D:
    '/checkouts',... D:\checkouts
    '..'        ,...up one
    '../'       ,...up one
    '..\'       ,...up one
    '\..'       ,... D:
    '..\..'     ,... up two
    '..\..\'    ,... up two
    '\..\..'    ,... D:
    '...'       ,... this is an invalid file name (expected behaviour), so it produces errors 
    };
testresult = false(length(testpath),3);
for ii = 1:length(testpath)
    D1                 = dir (testpath{ii});
    if isempty(D1)
        % then expect an error
        try
            dir2(testpath{ii},'depth',0,'dir_excl','')
        catch
            testresult(ii,1:3) = true;
        end
        continue
    end

    D2                 = dir2(testpath{ii},'depth',0,'dir_excl','');
    
    % do a normal dir on first path returned by dir2 (which should be the
    % basepath)
    D3                 = dir([D2(1).pathname D2(1).name]);
    
    testresult(ii,1)   = isequal(D1,D3);
    if strcmp(D1(1).name,'.')
        D1(1:2) = [];
    end
    testresult(ii,2)   = isequal([D1.name],[D2(2:end).name]);
    testresult(ii,3)   = isequal([D1(~[D1.isdir]).name],[D2(~[D2.isdir]).name]);
end

cd(current_dir);

testresult = all(testresult(:));
