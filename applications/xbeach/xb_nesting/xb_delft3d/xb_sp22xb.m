function wavefile = xb_sp22xb(fnames, varargin)
%XB_SP22XB  Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary conditions
%
%   Converts a set of Delft3D-WAVE SP2 files into XBeach wave boundary
%   conditions by cropping the timeseries, writing the corresponding SP2
%   files and a filelist file.
%
%   Syntax:
%   wavefile = xb_sp22xb(fnames, varargin)
%
%   Input:
%   fnames    = Path to Delft3D-WAVE SP2 files
%   varargin  = wavefile:       Path to output file
%               tstart:         Datenum indicating simulation start time
%               tlength:        Datenum indicating simulation length
%
%   Output:
%   wavefile  = Path to output file
%
%   Example
%   wavefile = xb_sp22xb('*.sp2')
%
%   See also xb_delft3d_wave, xb_bct2xb

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'wavefile', 'waves.txt', ...
    'tstart', 0, ...
    'tlength', Inf ...
);

OPT = setproperty(OPT, varargin{:});

wavefile = OPT.wavefile;

%% convert sp2 files

% read sp2 files
sp2 = xb_swan_read(fnames);

t = [];
files = xb_swan_struct();

% select sp2 files in time window
n = 1;
for i = 1:length(sp2)
    for j = 1:sp2(i).time.nr
        ti = sp2(i).time.data(j);
        if  ti >= OPT.tstart && ti < OPT.tstart+OPT.tlength
            files(n) = sp2(i);
            t(n) = ti;

            % reduce fields
            ind = true(sp2(i).time.nr,1); ind(j) = false;
            files(n).time.nr = 1;
            files(n).time.data(ind) = [];
            files(n).spectrum.data(ind,:,:,:) = [];
            files(n).spectrum.factor(ind,:) = [];

            n = n + 1;
        end
    end
end

fdir = fileparts(wavefile);

% write selected spectrum files
files = xb_swan_write(fullfile(fdir, 'wave.sp2'), files);

% make relative time axis
t = [0 diff(t)];

% write filelist
fid = fopen(wavefile, 'wt');
fprintf(fid, '%s\n', 'FILELIST');
for i = 1:length(files)
    fprintf(fid, '%8.1f %8.1f %s\n', t(i)*24*60*60, 1.0, files{i});
end
fclose(fid);