function xbSettings = xb_read_params(filename, varargin)
%XB_READ_PARAMS  read xbeach params.txt file
%
%   Routine to read the xbeach settings from the params.txt file. The
%   settings are stored in a structure array with fields 'name' and
%   'value'.
%
%   Syntax:
%   xbSettings = xb_read_params(filename)
%
%   Input:
%   filename   = params.txt file name
%   varargin   = include_paths:     flag to determine whether relative
%                                   paths should be included in filenames
%                read_paths:        flag to determine whether relative
%                                   paths should be read and included in
%                                   the result structure. read_path implies
%                                   include_paths.
%
%   Output:
%   xbSettings = structure array with fields 'name' and 'value' containing
%                all settings of the params.txt file
%
%   Example
%   xb_read_params
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
    'include_paths', true, ...
    'read_paths', true ...
);

OPT = setproperty(OPT, varargin{:});

%% read params file

if ~exist(filename, 'file')
    error(['"' filename '" does not exist'])
end

fid = fopen(filename);
txt = fread(fid, '*char')';
fclose(fid);

[fdir fname dext] = fileparts(filename);

%% read params

% obtain all keywords and values using regular expressions
[exprNames endIndex] = regexp(txt, ...
    '\s*(?<name>.*?)\s*=\s*(?<value>.*?)\s*\n', 'names', 'end', 'dotexceptnewline');

names = {exprNames.name};
values = {exprNames.value};

% distinguish between output variable definitions, doubles, strings and
% filenames
for i = 1:length(values)
    if regexp(names{i}, '^n.*var$')
        % output variable definition
        names{i} = [names{i}(2:end) 's'];
        values{i} = strread(txt(endIndex(i):end), '%s', str2double(values{i}));
    elseif ~isnan(str2double(values{i}))
        % numeric value
        values{i} = str2double(values{i});
    else
        % string value
        value = strtrim(values{i});
        
        % distinguish between filenames and ordinary strings
        if (OPT.read_paths || OPT.include_paths) && exist(fullfile(fdir, value), 'file')
            fpath = fullfile(fdir, value);
            
            if OPT.read_paths
                values{i} = struct();
                
                switch names{i}
                    case {'bcfile'}
                        % read waves
                        values{i}.name = 'type_';
                        values{i}.value = 'waves';
                    case {'zs0file'}
                        % read tide
                        values{i}(1).name = 'type_';
                        values{i}(1).value = 'tide';

                        [time tide] = xb_read_tide(fpath);
                        
                        values{i}(2).name = 'time';
                        values{i}(2).value = time;
                        
                        values{i}(3).name = 'data';
                        values{i}(3).value = tide;
                    otherwise
                        % assume file to be a grid and try reading it
                        try
                            values{i}(1).name = 'type_';
                            values{i}(1).value = 'grid';

                            values{i}(2).name = 'data';
                            values{i}(2).value = load(fpath);
                        catch
                            % cannot read file, save filename only
                            values{i} = fpath;
                        end
                end
            else
                values{i} = fpath;
            end
        else
            values{i} = value;
        end
    end
end

% remove doubles
[names idx] = unique(names, 'last');
values = values(idx);

% add meta data
names = [{'file_' 'date_' 'function_'} names];
values = [{fullfile(filename) datestr(now) mfilename} values];

% convert parameter cells to xbeach setting structure
xbSettings = cell2struct([names; values]', {'name' 'value'}, 2);