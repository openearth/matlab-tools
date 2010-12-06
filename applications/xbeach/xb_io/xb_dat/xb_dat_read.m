function dat = xb_dat_read(fname, dims, varargin)
%XB_DAT_READ  Bitwise reading of XBeach DAT files using strides
%
%   Reading of XBeach DAT files without the necessity to read the entire
%   file into memory. Based on given dimensions, start positions, length of
%   dimensions and strides, the exact numbers necessary are read from the
%   DAT file.
%
%   TODO: implement matrix read in case strides of first two dimensions are
%         equal to unity. Also implement threshold where reading the entire
%         file and disposing the part not reuqested is faster (factor
%         option)
%
%   Syntax:
%   dat = xb_dat_read(fname, dims, varargin)
%
%   Input:
%   fname       = Filename of DAT file
%   dims        = Array with lengths of all dimensions in DAT file
%   varargin    = start:    Start positions for reading in each dimension,
%                           first item is zero
%                 length:   Number of data items to be read in each
%                           dimension, negative is unlimited
%                 stride:   Stride to be used in each dimension
%                 factor:   Factor in threshold calculation to determine
%                           read method
%
%   Output:
%   dat         = Matrix with dimensions defined in dims containing
%                 requested data from DAT file
%
%   Example
%   dat = xb_dat_read(fname, [100 3 20]);
%   dat = xb_dat_read(fname, [100 3 20], 'start', 10, 'length', 90, 'stride', 2);
%   dat = xb_dat_read(fname, [100 3 20], 'start', [1 1 10], 'length', [-1 -1 20], 'stride', [2 2 2]);
%
%   See also xb_read_dat, xb_read_output, xb_dat_dims, xb_dat_type

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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'start', [], ...
    'length', [], ...
    'stride', [], ...
    'factor', 0.5 ...
);

OPT = setproperty(OPT, varargin{:});

%% check options

if isempty(OPT.start); OPT.start = zeros(size(dims)); end;
if isempty(OPT.length); OPT.length = -ones(size(dims)); end;
if isempty(OPT.stride); OPT.stride = ones(size(dims)); end;

OPT.start(length(OPT.start)+1:length(dims)) = 0;
OPT.length(length(OPT.length)+1:length(dims)) = -1;
OPT.stride(length(OPT.stride)+1:length(dims)) = 1;

OPT.start(OPT.start<0) = 0;
OPT.length(OPT.length<0) = max(1, dims(OPT.length<0)-OPT.start(OPT.length<0));
OPT.stride(OPT.stride<1) = 1;

%% read dat

fname = fullfile(fname);

dat = [];
if exist(fname, 'file')
    f = dir(fname);

    byt = f.bytes/prod(dims);
    
    switch byt
        case 4
            ftype = 'single';
        case 8
            ftype = 'double';
        otherwise
            error(['Dimensions incorrect [' num2str(dims) ']']);
    end
    
    fid = fopen(fname, 'r');
    
    ranges = {}; dimensions = [];
    for i = 1:length(OPT.start)
        ranges{i} = OPT.start(i)+[0:OPT.stride(i):OPT.length(i)-1];
        dimensions = [dimensions length(ranges{i})];
    end

    dat = nan(dimensions);

    for i = 1:prod(dimensions)
        coords = numel2coord(dimensions, i);
        item = 0;
        for j = 1:length(coords)
            item = item + ranges{j}(coords(j))*prod(dims(1:j-1));
        end
        fseek(fid, item*byt, 'bof');
        dat(i) = fread(fid, 1, ftype);
    end
    
    fclose(fid);
else
    error(['File not found [' fname ']']);
end
