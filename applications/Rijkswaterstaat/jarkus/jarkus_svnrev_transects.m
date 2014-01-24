function varargout = jarkus_svnrev_transects(varargin)
%JARKUS_SVNREV_TRANSECTS  Create string containing svn revision info of raw files
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_svnrev_transects(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_svnrev_transects() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_svnrev_transects
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 13 Nov 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct(...
    'mainpath', '',...
    'filenames', {{}},...
    'datefmt', 'yyyy-mm-ddTHH:MMZ');

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% code
rawurl = SVNgetURL(OPT.mainpath);
[~, svnversionMsg] = system(['svnversion "' OPT.mainpath '"']);

[~, svninfoMsg] = system(['svn info "' OPT.mainpath '"']);
timematch = regexp(svninfoMsg, '(?<=Last Changed Date: ).*?(?= (\(|[+-]))', 'match');
timelocal = timematch{1};
timeoffset = regexp(svninfoMsg, ['(?<=' timelocal ' )[^ ]+'], 'match');
timeoffset = eval(timeoffset{1});
offsetM = mod(abs(timeoffset), 100);
offsetH = (abs(timeoffset) - offsetM)/100;
offsetDays = sign(timeoffset) * (offsetH + offsetM/60) / 24;

timestr = datestr(datenum(timelocal) - offsetDays, OPT.datefmt);

txt = sprintf('%s: Raw data received from Rijkswaterstaat\nHEADurl: %s (rev %s)\nFiles:', timestr, rawurl, strtrim(svnversionMsg));

for i = 1:length(OPT.filenames)
    [~, svnversionMsg] = system(['svnversion "' fullfile(OPT.mainpath, OPT.filenames{i}) '"']);
    txt = sprintf('%s\n%s (rev %s)', txt, OPT.filenames{i}, strtrim(svnversionMsg));
end

varargout = {txt};