function type = xb_get_wavefiletype(filename)
%XB_GET_WAVEFILETYPE  Determines the type of wave definition file for XBeach input
%
%   Analyzes the contents of a wave definition file for XBeach input and
%   returns a string specifying the type of wave definition files.
%   Currently, the following types can be returned: unknown, filelist,
%   jonswap, jonswap_mtx, vardens, bcflist
%
%   Syntax:
%   type = xb_get_wavefiletype(filename)
%
%   Input:
%   filename  = filename of wave definition file to be analyzed
%
%   Output:
%   type      = string specifying the wave definition filetype
%
%   Example
%   type = xb_get_wavefiletype(filename)
%
%   See also xb_read_params, xb_read_waves

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
% Created: 23 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% set file types

types = {'unknown' 'filelist' 'jonswap' 'jonswap_mtx' 'vardens' 'bcflist'};
counts = zeros(1,length(types));

%% determine filetype

vardens_dim = [Inf Inf];

lcount = 1;
if exist(filename, 'file')
    
    % read lines of file
    fid = fopen(filename, 'r');
    while ~feof(fid)
        fline = fgetl(fid);
        if isempty(fline); continue; end;
        
        cnt = counts;
        
        % test for filelist
        try
            if strcmpi(fline, 'FILELIST') && lcount == 1
                counts = increase_count(types, counts, 'filelist');
            else
                [a b c] = strread(fline, '%f %f %s\n');
                if ~isempty(a) && ~isempty(b) && ~isempty(c) && lcount > 1
                    counts = increase_count(types, counts, 'filelist');
                end
            end
        end
        
        % test for bcflist
        try
            [a b c d e f] = strread(fline, '%f %f %f %f %f %s\n');
            if ~isempty(a) && ~isempty(b) && ~isempty(c) && ...
                    ~isempty(d) && ~isempty(e) && ~isempty(f) 
                counts = increase_count(types, counts, 'bcflist');
            end
        end
        
        % test for single jonswap
        try
            [key value] = strtok(fline, '=');
            if ~isempty(value) && ismember(key, {'Hm0' 'fp' 'dir' 'gamma' 's' 'fnyq'})
                counts = increase_count(types, counts, 'jonswap');
            end
        end
        
        % test for jonswap matrix
        try
            data = strread(fline, '%f', 'delimiter', ' ');
            if length(data) == 7
                counts = increase_count(types, counts, 'jonswap_mtx');
            end
        end
        
        % test for vardens
        try
            data = strread(fline, '%f', 'delimiter', ' ');
            switch length(data)
                case 1
                    if lcount == 1
                        vardens_dim(1) = data(1);
                        counts = increase_count(types, counts, 'vardens');
                    elseif lcount <= vardens_dim(1)+1
                        counts = increase_count(types, counts, 'vardens');
                    elseif lcount == vardens_dim(1)+2
                        vardens_dim(2) = data(1);
                        counts = increase_count(types, counts, 'vardens');
                    elseif lcount <= sum(vardens_dim)+2
                        counts = increase_count(types, counts, 'vardens');
                    end
                case vardens_dim(1)
                    if lcount > sum(vardens_dim)+2
                        counts = increase_count(types, counts, 'jonswap_mtx');
                    end
            end
        end
        
        % if no match found, increase unknown
        if sum(cnt) == sum(counts)
            counts = increase_count(types, counts, 'unknown');
        end
        
        lcount = lcount + 1;
    end
    fclose(fid);
end

% determine filetype with largest match score
[m i] = max(counts);
type = types{i};

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function counts = increase_count(types, counts, type)
idx = strcmpi(type, types);
if counts(idx) >= sum(counts(~idx))
    counts(idx) = counts(idx)+1;
end