function xb_write_params(filename, xb, varargin)
%XB_WRITE_PARAMS  Write XBeach settings to params.txt file
%
%   Routine to create a XBeach settings file. The settings in the XBeach
%   structure are written to "filename". Optionally an alternative header
%   line or directory containing params.f90 can be defined.
%
%   Syntax:
%   varargout = xb_write_params(filename, xb, varargin)
%
%   Input:
%   filename   = file name of params file
%   xb         = XBeach structure array
%   varargin   = header:    option to parse an alternative header string
%                xbdir :    option to parse an alternative xbeach code directory
%
%   Output:
%   none
%
%   Example
%   xb_write_params(filename, xb)
%
%   See also xb_write_input, xb_read_params

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

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct(...
    'header', {{'XBeach parameter settings input file' '' ['date:     ' datestr(now)] ['function: ' mfilename]}}, ...
    'xbdir', abspath(fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach')));

if nargin > 2
    OPT = setproperty(OPT, varargin{:});
end

if ~iscell(OPT.header); OPT.header = {OPT.header}; end;

%% write parameter file
if exist(OPT.xbdir, 'file')
    [params params_array] = xb_get_params(OPT.xbdir);
    parname = {params_array.name};
    partype = {params_array.partype};
    upartype = unique(partype);
else
    warning('No XBeach parameter category definition found, skipping headers');
    parname = {xb.data.name};
    upartype = {'General'};
    partype = cell(size(parname));
    [partype{:}] = deal(upartype{1});
end

% derive maximum stringsize of all variable names
maxStringLength = max(cellfun(@length, {xb.data.name}));

% open file
fid = fopen(filename, 'w');

% write header
fprintf(fid, '%s\n', repmat('%', 1, 80));
for i = 1:length(OPT.header)
    fprintf(fid, '%s %-72s %s\n', '%%%', OPT.header{i}, '%%%');
end
fprintf(fid, '%s\n', repmat('%', 1, 80));

outputvars = '';
for i = 1:length(upartype)
    pars = parname(strcmpi(upartype{i}, partype));
    
    % create type header
    if any(ismember(pars, {xb.data.name})) && ...
            ~strcmp(upartype{i}, 'Output variables') % collect output variables for printing at the end of the file
        fprintf(fid, '\n%s %s %s\n\n', '%%%', upartype{i}, repmat('%',1,75-length(upartype{i})));
    end
    
    for j = 1:length(pars)
        ivar = strcmpi(pars{j}, {xb.data.name});
        
        if any(ivar)
            if regexp(xb.data(ivar).name, '.*vars$')

                % create line indicating the number items in the cell
                outputvars = [outputvars sprintf('%s\n', var2params(['n' xb.data(ivar).name(1:end-1)], length(xb.data(ivar).value), maxStringLength))];

                % write output variables on separate lines
                for ioutvar = 1:length(xb.data(ivar).value)
                    outputvars = [outputvars sprintf('%s\n', xb.data(ivar).value{ioutvar})];
                end
            elseif strcmp(upartype{i}, 'Output variables')
                % collect output variables for printing at the end of the
                % file
                outputvars = [sprintf('%s\n', var2params(xb.data(ivar).name, xb.data(ivar).value, maxStringLength)) outputvars];
            else
                % create ordinary parameter line
                fprintf(fid, '%s\n', var2params(xb.data(ivar).name, xb.data(ivar).value, maxStringLength));
            end
        end
    end
end

% write output variables separately
header = 'Output variables';
fprintf(fid, '\n%s %s %s\n\n', '%%%', header, repmat('%',1,75-length(header)));
fprintf(fid, '%s', outputvars);

fclose(fid);

%%
function str = var2params(varname, value, maxStringLength)
%VAR2PARAMS  create string from name and value

% derive number of blanks to line out the '=' signs
nrBlanks = maxStringLength - length(varname);
% create first part of line
str = sprintf('%s%s = ', varname, blanks(nrBlanks));
% create last part of line, taking the type into account
if ischar(value)
    str = sprintf('%s', str, value);
else
    str = sprintf('%s%g', str, value);
end