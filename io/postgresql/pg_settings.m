function OK = pg_settings(varargin)
%PG_SETTINGS  Load toolbox for JDBC connection to a PostgreSQL database
%
% PG_SETTINGS() adds correct JDBC to java path. You need to do this
% every Matlab session. Alternatively make sure it is available and 
% listed in the following file: <matlabroot>/toolbox/local/classpath.txt
%
%See also postgresql, http://jdbc.postgresql.org/download.html, netcdf_settings

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 27 Jul 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.check = 0;
OPT.quiet = 0;

OPT = setproperty(OPT,varargin);

   if any(strfind(version('-java'),'Java 1.6')) | ...
      any(strfind(version('-java'),'Java 1.7'))
      java2add = path2os([fileparts(mfilename('fullpath')),filesep,'postgresql-9.1-902.jdbc4.jar']);
   else
      java2add = path2os([fileparts(mfilename('fullpath')),filesep,'postgresql-9.1-902.jdbc3.jar']);
   end
   
   dynjavaclasspath = path2os(javaclasspath);
   indices          = strfind(javaclasspath,java2add);
    
    if isempty(cell2mat(indices))

       if OPT.check
        disp('checked status PostgreSQL: JDBC NOT present.')
        OK = -1;
       else
        javaaddpath (java2add)
        disp('PostgreSQL: JDBC driver added.')
        OK = 1;
       end
       
   
    elseif ~(OPT.quiet)

       if OPT.check
        disp('checked status PostgreSQL: JDBC present.')
        OK = 1;
       else
        disp(['PostgreSQL: JDBC driver not added, already there: ',java2add]);
        OK = 1;
       end
        
   end