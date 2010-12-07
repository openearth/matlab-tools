function dat = xb_dat_read(fname, dims, varargin)
%XB_DAT_READ  Bytewise reading of XBeach DAT files using strides
%
%   Reading of XBeach DAT files. Two read methods are available: minimal
%   reads and minimal memory. The former minimizes the number of fread
%   calls, while the latter minimizes the amount of data read into memory.
%   In case the number of reads is for both methods equal, the memory
%   method is used. This method is also used if the average number of reads
%   per item is less than with the read method. The method used can also be
%   forced. The results is a matrix of the size dims containing the
%   requested data.
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
%                 force:    Force read method (read/memory)
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

if ndims(dims) < 2; error(['DAT file should be at least 2D [' num2str(ndims(dims)) ']']); end;

OPT = struct( ...
    'start', [], ...
    'length', [], ...
    'stride', [], ...
    'force', '' ...
);

OPT = setproperty(OPT, varargin{:});

%% check options

dat = [];

[OPT.start OPT.length OPT.stride] = xb_index(dims, OPT.start, OPT.length, OPT.stride);

% determine size of read matrix
sz = [1 1];
if OPT.stride(1) == 1; sz(1) = OPT.length(1); end;
if OPT.stride(2) == 1; sz(2) = OPT.length(2); end;

%% determine read method

nitems = prod(OPT.length./OPT.stride);
nreads = nitems/prod(sz);

if isempty(OPT.force)
    if (OPT.stride(1) == 1 && OPT.stride(2) == 1 && ~all(OPT.stride == 1)) || ...
        (nreads/nitems < prod(dims(3:end))/prod(dims))
        method = 'memory';
    else
        method = 'read';
    end
else
    method = OPT.force;
end

%% read dat

fname = fullfile(fname);

if exist(fname, 'file')
    f = dir(fname);
    
    % determine filetype
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
    
    switch method
        case 'read'
            % METHOD: minimal reads

            dat = nan(dims);

            % read entire file
            for i = 1:prod(dims(3:end))
                dat(:,:,i) = fread(fid, dims(1:2), ftype);
            end

            % dispose data out of range
            for i = 1:length(dims)
                if OPT.length(i) < dims(i)
                    idx = num2cell(repmat(':',1,length(dims)));
                    idx{i} = 1+OPT.start(i)+[0:OPT.stride(i):OPT.length(i)-1];
                    dat = dat(idx{:});
                end
            end
        case 'memory'
            % METHOD: minimal memory
            
            dat = nan(OPT.length);

            % determine dimensions to remove from loop and read at once
            % (maximum first two)
            nn = OPT.length(1);
            if sz(1) > 1; nn = 1; end;
            
            mm = OPT.length(2);
            if sz(2) > 1; mm = 1; end;

            % build output index
            idx = [num2cell(repmat(':',1,2)) {1}];
            
            % loop through data arrays
            for i = 1:prod(OPT.length(3:end))
                
                % select starting point of current data array
                ii = (i-1)*prod(dims(1:2));
                
                idx{3} = i;

                % loop through current data array
                for n = 1:nn
                    for m = 1:mm

                        if sz(1) == 1; idx{1} = n; end;
                        if sz(2) == 1; idx{2} = m; end;
                        
                        ii = ii + (m-1)*dims(1) + n;
                        
                        % set pointer to data point to be read and read
                        fseek(fid, ii*byt, 'bof');
                        dat(idx{:}) = fread(fid, sz, ftype);
                    end
                end
            end
        otherwise
            error(['Unknown read method [' method ']']);
    end
    
    fclose(fid);
else
    error(['File not found [' fname ']']);
end
