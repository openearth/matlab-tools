function filename = xb_write_waves(varargin)
%XB_WRITE_WAVES  Writes wave definition files for XBeach input
%
%   Writes JONSWAP or variance density files for XBeach input. In case of
%   conditions changing in time, a file list file is created refering to
%   multiple wave definition files. In case of a JONSWAP spectrum, the file
%   list file can be omitted and a single matrix formatted file is created.
%   Returns the filename of the file to be refered in the params.txt file.
%
%   Syntax:
%   filename = xb_write_waves(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_waves
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <Deltares>
%       Bas Hoonhout
%
%       <bas.hoonhout@deltares.nl>
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

    OPT = struct( ...
        'type', 'jonswap', ...
        'Hm0', 7.6, ...
        'Tp', 12, ...
        'dir', 270, ...
        'gamma', 3.3, ...
        's', 20, ...
        'fnyq', 1, ...
        'freqs', [], ...
        'dirs', [], ...
        'vardens', [], ...
        'duration', [], ...
        'timestep', 1, ...
        'filelist_file', 'filelist', ...
        'jonswap_file', 'jonswap', ...
        'vardens_file', 'vardens', ...
        'omit_filelist', false ...
    );

    OPT = setproperty(OPT, varargin{:});

%% check input

    % check parameter dimensions
    switch OPT.type
        case 'jonswap'
            vars = {'Hm0' 'Tp' 'dir' 'gamma' 's' 'fnyq' 'duration' 'timestep'};

            fname = OPT.jonswap_file;

            tlength = get_time_length(OPT, vars);
        case 'vardens'
            vars = {'duration' 'timestep'};

            fname = OPT.vardens_file;

            tlength = get_time_length(OPT, vars);

            if length(OPT.freqs) ~= size(OPT.vardens, 1) || ...
                    length(OPT.dirs) ~= size(OPT.vardens, 2)
                error('Dimensions of variance density matrix do not match');
            end

            if tlength ~= size(OPT.vardens, 3)
                error('Time dimension of variance density matrix does not match');
            end
        otherwise
            error(['Unknown wave definition type [' OPT.type ']']);
    end

    for i = 1:length(vars)
        switch length(OPT.(vars{i}))
            case 0
                OPT.(vars{i}) = nan*ones(1,tlength);
            case 1
                OPT.(vars{i}) = OPT.(vars{i})*ones(1,tlength);
        end
    end
    
    OPT.fp = 1./OPT.Tp;

%% create file list

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

    if length(OPT.duration) > 1 && strcmpi(OPT.type, 'jonswap') && OPT.omit_filelist
        filename = [fname '.txt'];
        write_jonswap_multiple_file(filename, tlength, OPT)
    else
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
            end
        end
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = get_time_length(OPT, vars)
    t = 1;
    for i = 1:length(vars)
        if t > 1 && length(OPT.(vars{i})) > 1 && t ~= length(OPT.(vars{i}))
            error('Time dimensions do not match');
        end

        t = max(t, length(OPT.(vars{i})));
    end
end
    
function write_jonswap_single_file(fname, idx, OPT)
    vars = {'Hm0' 'fp' 'dir' 'gamma' 's' 'fnyq'};
    
    fid = fopen(fname, 'w');
    for i = 1:length(vars)
        fprintf(fid, '%-10s = %10.4f\n', vars{i}, OPT.(vars{i})(idx));
    end
    fclose(fid);
end
    
function write_jonswap_multiple_file(fname, tlength, OPT)
    vars = {'Hm0' 'Tp' 'dir' 'gamma' 's' 'duration' 'timestep'};
    
    fid = fopen(fname, 'w');
    for i = 1:tlength
        for j = 1:length(vars)
            fprintf(fid, '%10.4f', OPT.(vars{j})(i));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end
    
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
end