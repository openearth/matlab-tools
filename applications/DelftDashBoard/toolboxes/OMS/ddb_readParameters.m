function hm = ddb_readParameters(hm)
%DDB_READPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   hm = ddb_readParameters(hm)
%
%   Input:
%   hm =
%
%   Output:
%   hm =
%
%   Example
%   ddb_readParameters
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
n=1;
hm.Parameters(n).Name='wl';
hm.Parameters(n).LongName='water level';
hm.Parameters(n).Title='Water Level';
hm.Parameters(n).YLabel='water level (m w.r.t. MSL)';
hm.Parameters(n).YLimType='sym';
hm.Parameters(n).CLim=[-2 0.25 2];

% n=n+1;
% hm.Parameters(n).Name='vel';
% hm.Parameters(n).LongName='velocity';
% hm.Parameters(n).Title='Velocity';
% hm.Parameters(n).YLabel='velocity (m/s)';
% hm.Parameters(n).YLimType='sym';

n=n+1;
hm.Parameters(n).Name='hs';
hm.Parameters(n).LongName='significant wave height';
hm.Parameters(n).Title='Significant Wave Height';
hm.Parameters(n).YLabel='significant wave height (m)';
hm.Parameters(n).YLimType='positive';
hm.Parameters(n).CLim=[0 0.5 4];

n=n+1;
hm.Parameters(n).Name='tp';
hm.Parameters(n).LongName='peak wave period';
hm.Parameters(n).Title='Peak Wave Period';
hm.Parameters(n).YLabel='peak period (s)';
hm.Parameters(n).YLimType='positive';
hm.Parameters(n).CLim=[0 2 20];

n=n+1;
hm.Parameters(n).Name='wavdir';
hm.Parameters(n).LongName='wave direction';
hm.Parameters(n).Title='Mean Wave Direction';
hm.Parameters(n).YLabel='wave direction ( \circ)';
hm.Parameters(n).YLimType='angle';
hm.Parameters(n).CLim=[0 30 360];

hm.NrParameters=n;

