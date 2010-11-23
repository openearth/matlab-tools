function xb_write_waves_test()
% XB_WRITE_WAVES_TEST  Test function for xb_write_waves
%  
%   See also xb_write_waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 22 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTest.category('UnCategorized');

%% test 1: default jonswap
delete('test1*.txt');
filename = xb_write_waves('jonswap_file','test1');
assert(exist(filename,'file')==2,'TEST1: JONSWAP spectrum file not created');

d = dir(filename);
assert(d.bytes>0,'TEST1: JONSWAP spectrum file is empty');
assert(d.bytes==144,'TEST1: JONSWAP spectrum file is not the right size');

%% test 2: time-varying jonswap
delete('test2*.txt');

xbSettings = struct('name','Hm0','value',[5:7]);
filename = xb_write_waves(xbSettings,'jonswap_file','test2','filelist_file','test2_filelist');
assert(exist(filename,'file')==2,'TEST2: Filelist file not created');

d = dir(filename);
assert(d.bytes>0,'TEST2: Filelist file is empty');
assert(d.bytes==222,'TEST2: Filelist file is not the right size');

for i = 1:length(xbSettings.value)
    fname = ['test2_' num2str(i) '.txt'];
    assert(exist(fname,'file')==2,['TEST2: JONSWAP spectrum file # ' num2str(i) ' not created']);
    
    d = dir(fname);
    assert(d.bytes>0,['TEST2: JONSWAP spectrum file # ' num2str(i) ' is empty']);
    assert(d.bytes==144,['TEST2: JONSWAP spectrum file # ' num2str(i) ' is not the right size']);
end

%% test 3: time-varying jonswap matrix format
delete('test3*.txt');

xbSettings = struct('name','Hm0','value',[5:7]);
filename = xb_write_waves(xbSettings,'jonswap_file','test3','omit_filelist',true);
assert(exist(filename,'file')==2,'TEST3: JONSWAP spectrum file not created');

d = dir(filename);
assert(d.bytes>0,'TEST3: JONSWAP spectrum file is empty');
assert(d.bytes==213,'TEST3: JONSWAP spectrum file is not the right size');

%% test 4: default vardens
delete('test4*.txt');

xbSettings = struct('name',{'freqs' 'dirs' 'vardens'},'value',{[1:10] [1:5] [magic(5);magic(5)]});
filename = xb_write_waves(xbSettings,'vardens_file','test4','type','vardens');
assert(exist(filename,'file')==2,'TEST4: Variance density spectrum file not created');

d = dir(filename);
assert(d.bytes>0,'TEST4: Variance density spectrum file is empty');
assert(d.bytes==692,'TEST4: Variance density spectrum file is not the right size');

%% test 5: time-varying vardens
delete('test5*.txt');

vardens = [];
vardens(:,:,1) = [magic(5);magic(5)];
vardens(:,:,2) = [magic(5);magic(5)];
vardens(:,:,3) = [magic(5);magic(5)];

xbSettings = struct('name',{'freqs' 'dirs' 'vardens'},'value',{[1:10] [1:5] vardens});
filename = xb_write_waves(xbSettings,'vardens_file','test5','filelist_file','test5_filelist','type','vardens');
assert(exist(filename,'file')==2,'TEST5: Filelist file not created');

d = dir(filename);
assert(d.bytes>0,'TEST5: Filelist file is empty');
assert(d.bytes==222,'TEST5: Filelist file is not the right size');

for i = 1:size(vardens,3)
    fname = ['test5_' num2str(i) '.txt'];
    assert(exist(fname,'file')==2,['TEST5: Variance density spectrum file # ' num2str(i) ' not created']);
    
    d = dir(fname);
    assert(d.bytes>0,['TEST5: Variance density spectrum file # ' num2str(i) ' is empty']);
    assert(d.bytes==692,['TEST5: Variance density spectrum file # ' num2str(i) ' is not the right size']);
end
