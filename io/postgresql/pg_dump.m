function pg_dump(conn,varargin)
%PG_DUMP  Display overview of tables, columns and sizes of database schema
%
% PG_DUMP(conn) shows alls tables with all columns
% PG_DUMP(conn, table_name) shows only requested tables where
% table_name is a cellstr.
%
% Example: pg_test datamodel
%  pg_dump(conn,{'TEST01'})
%  pg_dump(conn) 
%
%  TEST01(6) :
%      ObservationID(integer)
%      ObservationTime(timestamp with time zone)
%      Value(real)
%
%See also: nc_dump, postgresql, netcdf

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
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
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

   if nargin>1
      tables = varargin{1};
      if ischar(tables);tables = cellstr(tables);end
   else
      tables = pg_gettables(conn);
   end

   for i=1:length(tables)
      table = tables{i};
      try % ERROR: relation "topology" does not exist
      [column_name,data_type,data_length] = pg_getcolumns(conn, table);

     %disp([repmat('-',size(table))])
      disp([table,'(',num2str(data_length),') :'])
      for j=1:length(column_name)
         disp(['    ',column_name{j},'(',data_type{j},')'])
      end
      disp(' ')
      end
   end
   
