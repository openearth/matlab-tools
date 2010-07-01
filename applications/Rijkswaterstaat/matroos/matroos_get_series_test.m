function matroos_get_series_test()
% MATROOS_GET_SERIES_TEST   test for matroos_get_series
%  
% This function tests matroos_get_series.
%
%
%   See also matroos

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

TeamCity.category('DataAccess');
if TeamCity.running
    TeamCity.ignore('Test requires access to matroos, which the buildserver does not have.');
    return;
end

%% get data, save to file

   O = matroos_get_series('unit','waterlevel','source','observed' ,'loc','hoekvanholland;den helder;delfzijl','tstart',now-7,'tstop',now+7,'check','','file','O.txt');
   P = matroos_get_series('unit','waterlevel','source','dcsm_oper','loc','hoekvanholland;den helder;delfzijl','tstart',now-7,'tstop',now+7,'check','','file','P.txt');
   
%% plot data

for iloc=1:length(O)

   figure

   plot    (P(iloc).datenum,P(iloc).waterlevel,'b-','displayname',mktex('observed' ));
   hold     on
   plot    (O(iloc).datenum,O(iloc).waterlevel,'k.','displayname',mktex('dcsm_oper'));
   vline   (now)
   datetick(gca);
   xlabel  ('time');
   ylabel  ('water level [m]')
   xlabel  (['time ',O(iloc).timezone])
   legend   show
   grid     on
   title   ([O(iloc).loc,' ',O(iloc).latlonstr])

end