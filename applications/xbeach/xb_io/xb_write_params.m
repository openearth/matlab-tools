function varargout = xb_write_params(filename, xbSettings, varargin)
%XB_WRITE_PARAMS  write xbeach settings to params.txt file
%
%   Routine to create a xbeach settings file. The settings in "xbSettings"
%   are written to "filename". Optionally an alternative header line can be
%   defined.
%
%   Syntax:
%   varargout = xb_write_params(filename, xbSettings, varargin)
%
%   Input:
%   filename   = file name of params file
%   xbSettings = structure with fields 'name' and 'value' containing the
%                xbeach settings
%   varargin   = 'header'  - option to parse an alternative header string
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_params
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

%%
OPT = struct(...
    'header', ['XBeach parameter settings input file automatically created by OpenEarthTools function XB_WRITE_PARAMS (date: ' datestr(now) ')']);

if nargin > 2
    OPT = setproperty(OPT, varargin{:});
end

%%
%TODO: create input categories
XBdir = fullfile(fileparts(which(mfilename)), '..', '..', '..', '..', 'fortran', 'XBeach'); 
[XBparams XBparams_array]=XB_updateParams(XBdir);
name = {XBparams_array.name};
partype = {XBparams_array.partype};

% derive maximum stringsize of all variable names
maxStringLength = max(cellfun(@length, {xbSettings.name}));

% open file
fid = fopen(filename, 'w');

% write header
fprintf(fid, '%s %s\n\n', '%', OPT.header);

for ivar = 1:length(xbSettings)
    if regexp(xbSettings(ivar).name, '.*vars$')
        % create line indicating the number items in the cell
        fprintf(fid, '%s\n', var2params(['n' xbSettings(ivar).name(1:end-1)], length(xbSettings(ivar).value), maxStringLength));
        % write output variables on separate lines
        for ioutvar = 1:length(xbSettings(ivar).value)
            fprintf(fid, '%s\n', xbSettings(ivar).value{ioutvar});
        end
    else
        % create line
        fprintf(fid, '%s\n', var2params(xbSettings(ivar).name, xbSettings(ivar).value, maxStringLength));
    end
end

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