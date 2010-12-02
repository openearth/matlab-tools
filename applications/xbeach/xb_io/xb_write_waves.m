function filename = xb_write_waves(varargin)
%XB_WRITE_WAVES  Writes wave definition files for XBeach input
%
%   Writes JONSWAP or variance density spectrum files for XBeach input. In 
%   case of conditions changing in time, a file list file is created
%   refering to multiple wave definition files. In case of a JONSWAP
%   spectrum, the file list file can be omitted and a single matrix 
%   formatted file is created. Returns the filename of the file to be
%   referred in the params.txt file.
%
%   In order to generate time varying wave conditions, simply add an extra
%   dimension to the input arguments specifying the spectrum. The
%   single-valued parameters Hm0, Tp, dir, gammajsp, s fnyq, duration and
%   timestep then become one-dimensional. The one- and two-dimensional
%   parameters freqs, dirs and vardens then become two- and
%   three-dimensional respectively. It is not necessary to provide
%   time-varying values for all parameters. In case a specific parameter is
%   constant, simply provide the constant value. The value is reused in
%   each period of time. However, it is not possible to provide for one
%   parameter more than one value and for another too, while the number of
%   values are not the same.
%
%   Syntax:
%   filename = xb_write_waves(xbSettings, varargin)
%
%   Input:
%   xbSettings  = XBeach structure array that overwrites the
%                 default varargin options (optional)
%   varargin    = type:             type of wave file (jonswap/vardens)
%                 Hm0:              significant wave height of jonswap
%                                   spectrum
%                 Tp:               peak wave period of jonswap spectrum
%                 dir:              direction of waves in nautical
%                                   convention
%                 gammajsp:         peak-enhancement factor of jonswap
%                                   spectrum
%                 s:                directional spreading factor of jonswap
%                                   spectrum
%                 fnyq:             Nyquist frquency of jonswap spectrum
%                 freqs:            frequencies of variance density
%                                   spectrum
%                 dirs:             directions of variance density spectrum
%                 vardens:          variance density matrix (freq,dir,time)
%                 duration:         duration for individual wave files
%                 timestep:         timestep for individual wave files
%                 contents:         plain contents of unknown wave files
%                 filelist_file:    name of filelist file without extension
%                 jonswap_file:     name of jonswap file without extension
%                 vardens_file:     name of vardens file without extension
%                 unknown_file:     name of unknown wave file without
%                                   extension
%                 omit_filelist:    flag to omit filelist generation in
%                                   case of jonswap spectrum
%
%   Output:
%   filename = filename to be referred in parameter file
%
%   Example
%   filename = xb_write_waves()
%   filename = xb_write_waves(xbSettings)
%   filename = xb_write_waves(xbSettings,'type','vardens')
%   filename = xb_write_waves('type','vardens','freqs',freqs,'dirs',dirs,'vardens',vardens)
%   filename = xb_write_waves('Hm0',[2.5:1:5.5 4.5:-1:2.5],'Tp',[12:1:15 14:-1:12],'omit_filelist',true)
%
%   See also xb_write_input, xb_read_waves

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~isempty(varargin) && isstruct(varargin{1})
    xbSettings = varargin{1};
    varargin = varargin(2:end);
    
    if ~xb_check(xbSettings); error('Invalid XBeach structure'); end;
end

OPT = struct( ...
    'type', 'jonswap', ...
    'Hm0', 7.6, ...
    'Tp', 12, ...
    'dir', 270, ...
    'gammajsp', 3.3, ...
    's', 20, ...
    'fnyq', 1, ...
    'freqs', [0], ...
    'dirs', [270], ...
    'vardens', [0], ...
    'duration', 3600, ...
    'timestep', 1, ...
    'contents', [], ...
    'filelist_file', 'filelist', ...
    'jonswap_file', 'jonswap', ...
    'vardens_file', 'vardens', ...
    'unknown_file', 'wave', ...
    'omit_filelist', false ...
);

OPT = setproperty(OPT, varargin{:});

if exist('xbSettings','var')
    OPT = mergestructs('overwrite', OPT, struct_flip(xbSettings.data, 'name', 'value'));
end

if strcmpi(OPT.type, 'jonswap_mtx')
    OPT.type = 'jonswap';
    OPT.omit_filelist = true;
end

%% check input

% check parameter dimensions
switch OPT.type
    case 'jonswap'
        vars = {'Hm0' 'Tp' 'dir' 'gammajsp' 's' 'fnyq' 'duration' 'timestep'};

        fname = OPT.jonswap_file;

        % determine length of time series
        tlength = get_time_length(OPT, vars);
    case 'vardens'
        vars = {'duration' 'timestep'};

        fname = OPT.vardens_file;

        % determine length of time series
        tlength = get_time_length(OPT, vars);

        if length(OPT.freqs) ~= size(OPT.vardens, 1) || ...
                length(OPT.dirs) ~= size(OPT.vardens, 2)
            error('Dimensions of variance density matrix do not match');
        end

        if tlength ~= size(OPT.vardens, 3)
            if tlength == 1
                tlength = size(OPT.vardens, 3);
            else
                error('Time dimension of variance density matrix does not match');
            end
        end
    case 'unknown'
        vars = {'contents' 'duration' 'timestep'};
        
        fname = OPT.unknown_file;
        
        % determine length of time series
        tlength = get_time_length(OPT, vars);
    otherwise
        error(['Unknown wave definition type [' OPT.type ']']);
end

% extend constant parameters to length of time series
for i = 1:length(vars)
    if strcmpi(vars{i}, 'contents'); continue; end;
    
    switch length(OPT.(vars{i}))
        case 0
            OPT.(vars{i}) = nan*ones(1,tlength);
        case 1
            OPT.(vars{i}) = OPT.(vars{i})*ones(1,tlength);
    end
end

OPT.fp = 1./OPT.Tp;

%% create file list

% create file list file, if necessary
if length(OPT.duration) > 1 && ~(strcmpi(OPT.type, 'jonswap') && OPT.omit_filelist)
    filename = [OPT.filelist_file '.txt'];
    fid = fopen(filename, 'w');
    fprintf(fid, 'FILELIST\n');
    for i = 1:length(OPT.duration)
        fprintf(fid, '%10i%10.4f%50s\n', OPT.duration(i), OPT.timestep(i), [fname '_' num2str(i) '.txt']);
    end
    fclose(fid);
end

%% create wave files

% determine whether single matrix formatted jonswap file should be
% created, otherwise write single or multiple wave files
if length(OPT.duration) > 1 && strcmpi(OPT.type, 'jonswap') && OPT.omit_filelist
    filename = [fname '.txt'];
    write_jonswap_multiple_file(filename, tlength, OPT)
else
    % loop through time series and write wave files
    for i = 1:length(OPT.duration)
        if length(OPT.duration) == 1
            filename = [fname '.txt'];
            fname_i = filename;
        else
            fname_i = [fname '_' num2str(i) '.txt'];
        end

        switch OPT.type
            case 'jonswap'
                write_jonswap_single_file(fname_i, i, OPT)
            case 'vardens'
                write_vardens_file(fname_i, i, OPT)
            case 'unknown'
                write_unknown_file(fname_i, i, OPT)
        end
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine length of time series
function t = get_time_length(OPT, vars)
t = 1;
for i = 1:length(vars)
    if t > 1 && length(OPT.(vars{i})) > 1 && t ~= length(OPT.(vars{i}))
        error('Time dimensions do not match');
    end

    t = max(t, length(OPT.(vars{i})));
end
    
% write single jonswap wave file
function write_jonswap_single_file(fname, idx, OPT)
vars = {'Hm0' 'fp' 'dir' 'gammajsp' 's' 'fnyq'};

fid = fopen(fname, 'w');
for i = 1:length(vars)
    fprintf(fid, '%-10s = %10.4f\n', vars{i}, OPT.(vars{i})(idx));
end
fclose(fid);
    
% write matrix formatted jonswap wave file
function write_jonswap_multiple_file(fname, tlength, OPT)
vars = {'Hm0' 'Tp' 'dir' 'gammajsp' 's' 'duration' 'timestep'};

fid = fopen(fname, 'w');
for i = 1:tlength
    for j = 1:length(vars)
        fprintf(fid, '%10.4f', OPT.(vars{j})(i));
    end
    fprintf(fid, '\n');
end
fclose(fid);
    
% write single variance density spectrum file
function write_vardens_file(fname, idx, OPT)
fid = fopen(fname, 'w');
fprintf(fid, '%10.4f\n', length(OPT.freqs));
for i = 1:length(OPT.freqs)
    fprintf(fid, '%10.4f\n', OPT.freqs(i));
end
fprintf(fid, '%10.4f\n', length(OPT.dirs));
for i = 1:length(OPT.dirs)
    fprintf(fid, '%10.4f\n', OPT.dirs(i));
end
for i = 1:length(OPT.dirs)
    for j = 1:length(OPT.freqs)
        fprintf(fid, '%10.4f', OPT.vardens(j,i,idx));
    end
    fprintf(fid, '\n');
end
fclose(fid);

% write unknown formatted wave file
function write_unknown_file(fname, tlength, OPT)

fid = fopen(fname, 'w');
if iscell(OPT.contents)
    fprintf(fid, '%s', OPT.contents{tlength});
else
    fprintf(fid, '%s', OPT.contents);
end
fclose(fid);