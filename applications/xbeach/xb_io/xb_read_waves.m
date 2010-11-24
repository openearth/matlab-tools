function xbSettings = xb_read_waves(filename, varargin)
%XB_READ_WAVES  Reads wave definition files for XBeach input
%
%   Determines the type of wave definition file and reads it into a
%   name/value struct. If a filelist is given, also the underlying files
%   are read and stored. The resulting struct can be inserted into the
%   generic XBeach settings struct.
%
%   Syntax:
%   xbSettings  = xb_read_waves(filename, varargin)
%
%   Input:
%   filename    = filename of wave definition file
%   varargin    = none
%
%   Output:
%   xbSettings  = structure array with fields 'name' and 'value' containing
%                 all settings of the params.txt file
%
%   Example
%   xbSettings  = xb_read_waves(filename)
%
%   See also xb_read_params, xb_write_waves

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

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% determine filetype

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

xbSettings = xb_empty();

filetype = xb_get_wavefiletype(filename);

switch filetype
    case 'filelist'
        xbSettings.data = read_filelist(filename);
    case 'jonswap'
        xbSettings.data = read_jonswap(filename);
    case 'jonswap_mtx'
        xbSettings.data = read_jonswap_mtx(filename);
    case 'vardens'
        xbSettings.data = read_vardens(filename);
    otherwise
        % unsupported wave definition file, simply dump contents
        xbSettings.data = read_unknown(filename);
end

% set meta data
xbSettings = xb_meta(xbSettings, mfilename, 'waves');

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xbSettings = read_filelist(filename)

tlength = 1;
xbSettings = struct('name',{'type_' 'duration' 'timestep'},'value',[]);

fdir = fileparts(filename);

fid = fopen(filename); fgetl(fid);
while ~feof(fid)
    fline = fgetl(fid);
    
    if isempty(fline); continue; end;
    
    [duration timestep fname] = strread(fline, '%f%f%s', 'delimiter', ' ');

    xbSettings(2).value(tlength) = duration;
    xbSettings(3).value(tlength) = timestep;
    fname = fullfile(fdir, [fname{:}]);

    if exist(fname, 'file')
        filetype = xb_get_wavefiletype(fname);
        
        switch filetype
            case 'jonswap'
                xb = read_jonswap(fname);
            case 'vardens'
                xb = read_vardens(fname);
            otherwise
                % unsupported wave definition file, simply dump contents
                xb = read_unknown(fname);
        end
        
        xbSettings = add_setting(xbSettings, xb, tlength);
    end

    tlength = tlength + 1;
end

xbSettings = consolidate_settings(xbSettings);

function xbSettings = read_jonswap(filename)

xbSettings = struct('name','type_','value','jonswap');

fid = fopen(filename);
txt = fread(fid, '*char')';
fclose(fid);

matches = regexp(txt, '\s*(?<name>.*?)\s*=\s*(?<value>.*?)\s*\n', 'names', 'dotexceptnewline');

names = {matches.name};
values = num2cell(str2double({matches.value}));

% convert frequency to period
idx = strcmpi('fp', names);
if any(idx)
    names = [names {'Tp'}];
    values = [values {1/values{idx}}];
end

xbSettings = add_setting(xbSettings, struct('name',names,'value',values));

function xbSettings = read_jonswap_mtx(filename)

tlength = 1;
xbSettings = struct('name','type_','value','jonswap_mtx');

names = {'Hm0' 'Tp' 'dir' 'gammajsp' 's' 'duration' 'timestep'};
values = [];

fid = fopen(filename);
while ~feof(fid)
    fline = fgetl(fid);
    if isempty(fline); continue; end;
    
    values = num2cell(strread(fline, '%f', length(names), 'delimiter', ' '))';
    xbSettings = add_setting(xbSettings, struct('name',names,'value',values), tlength);
    tlength = tlength+1;
end
fclose(fid);

xbSettings = consolidate_settings(xbSettings);

function xbSettings = read_vardens(filename)

xbSettings = struct('name','type_','value','vardens');

dims = [Inf Inf];

freqs = [];
dirs = [];
vardens = [];

lcount = 1;
fid = fopen(filename);
while ~feof(fid)
    fline = fgetl(fid);
    if isempty(fline); continue; end;
    
    if lcount == 1
        dims(1) = str2double(fline);
    elseif lcount <= dims(1)+1
        freqs(lcount-1) = str2double(fline);
    elseif lcount == dims(1)+2
        dims(2) = str2double(fline);
    elseif lcount <= sum(dims)+2
        dirs(lcount-dims(1)-2) = str2double(fline);
    else
        vardens(lcount-sum(dims)-2,:) = strread(fline, '%f', dims(1), 'delimiter', ' ')';
    end
    
    lcount = lcount+1;
end
fclose(fid);

names = {'freqs' 'dirs' 'vardens'};
values = {freqs dirs vardens};

xbSettings = add_setting(xbSettings, struct('name',names,'value',values));

function xbSettings = read_unknown(filename)

xbSettings = struct('name',{'type_' 'contents'},'value',{'unknown',''});

fid = fopen(filename);
xbSettings(2).value = fread(fid, '*char')';
fclose(fid);

function xbSettings = add_setting(xbSettings, setting, t)

if ~exist('t', 'var'); t = 1; end;

for i = 1:length(setting)
    idx = strcmpi(setting(i).name, {xbSettings.name});
    
    if ~any(idx)
        idx = length(xbSettings)+1;
        xbSettings(idx).name = setting(i).name;
    end
    
    if ischar(setting(i).value)
        xbSettings(idx).value{t} = setting(i).value;
    else
        switch sum(size(setting(i).value)>1)
            case 0
                xbSettings(idx).value(t) = setting(i).value;
            case 1
                xbSettings(idx).value(:,t) = setting(i).value;
            case 2
                xbSettings(idx).value(:,:,t) = setting(i).value;
        end
    end
end

function xbSettings = consolidate_settings(xbSettings)

for i = 1:length(xbSettings)
    ndo = sum(size(xbSettings(i).value)>1);
    ndu = sum(size(unique(xbSettings(i).value))>1);
    
    if ndo - ndu == 1 || ndo == 0
        if iscell(xbSettings(i).value)
            xbSettings(i).value = xbSettings(i).value{1};
        else
            switch ndo
                case 1
                    xbSettings(i).value = xbSettings(i).value(1);
                case 2
                    xbSettings(i).value = xbSettings(i).value(:,1);
                case 3
                    xbSettings(i).value = xbSettings(i).value(:,:,1);
            end
        end
    end
end