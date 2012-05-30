function varargout = hash_files(D,varargin)
%HASH_FILES  Hashes all files and folders in a structure returned by dir2
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = hash_files(varargin)
%
%   Input:
%   D  = structure returned by dir2
%
%   Output:
%   varargout =
%
%   Example
%   D = hash_files(dir2('no_dirs',1))
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 08 Mar 2012
% Created with Matlab version: 7.14.0.834 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.method = 'MD5';
OPT.quiet  = false;
OPT = setproperty(OPT,varargin{:});

if nargin==0;
    varargout = OPT;
    return;
end
%% code
requiredfields =  { 
        'name'
        'date'
        'bytes'
        'isdir'
        'datenum'
        'pathname'
        };

if ~all(ismember(requiredfields,fieldnames(D)))
    error('HASH_FILES:input','input must be a struct returned by dir2');
end

switch upper(OPT.method)
    case 'MD5'
        hashfun = @(filename) uint8(CalcMD5(filename,'File','dec'));
    otherwise
        error('HASH_FILES:input','hash mathod %s not supported',OPT.method);
end


if OPT.quiet
    for ii = 1:length(D)
        if ~D(ii).isdir
            D(ii).hash = hashfun([D(ii).pathname D(ii).name]);
        end
    end
else
    WB.small_file_correction_bytes = 2e6;
    WB.totalbytes   = sum([D(~[D.isdir]).bytes])+sum(~[D.isdir])*WB.small_file_correction_bytes;
    WB.hashedbytes = 0;
    t = tic;
    for ii = 1:length(D)
        if ~D(ii).isdir
            D(ii).hash = hashfun([D(ii).pathname D(ii).name]);
            WB.hashedbytes = WB.hashedbytes + D(ii).bytes + WB.small_file_correction_bytes;
        end
        if toc(t)>0.2
            t = tic;
            multiWaitbar('hashing files',WB.hashedbytes/WB.totalbytes)
        end
    end
    multiWaitbar('hashing files','close')
end

varargout = {D,OPT};
