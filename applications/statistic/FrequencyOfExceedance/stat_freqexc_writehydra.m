function fname = stat_freqexc_writehydra(res, varargin)
%STAT_FREQEXC_WRITEHYDRA  Write combined frequency of exceedance line to Hydra model input
%
%   Write the combined frequency of exceedance to an input file to be used
%   with Hydra models. The frequency of occurrance in 1/yr is converted to
%   1/month using the fraction property of the result structure used as
%   input. The filename of the generated file is returned.
%
%   Syntax:
%   fname = stat_freqexc_writehydra(res, varargin)
%
%   Input:
%   res       = Results structure from the stat_freqexc_combine function
%   varargin  = filename:       Name of file to be written
%
%   Output:
%   fname     = Name of written file
%
%   Example
%   fname = stat_freqexc_writehydra(res);
%
%   See also stat_freqexc_combine

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
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
% Created: 17 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read settings

OPT = struct( ...
    'filename', 'ovkans_piekmeerpeil.txt' ...
);

OPT = setproperty(OPT, varargin{:});

if ~isfield(res, 'combined')
    error('No combined data available, please use stat_freqexc_combine first');
end

%% write file

fname = OPT.filename;

fid = fopen(fname,'w');
fprintf(fid, '* %25s %25s\n', 'Piekwaarde', 'overschrijdingskans');
fprintf(fid, '* %25s %25s\n', '[m+NAP]', '[-]');
for i=1:length(res.combined.f)
    fprintf(fid, '  %25.3e %25.3e\n', res.combined.y(i), res.combined.f(i)/(12*res.fraction));
end
fclose(fid);
