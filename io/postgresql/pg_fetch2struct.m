function D = pg_fetch2struct(R,nams,typs)
%pg_fetch2struct  parse resultsset cell into struct 
%
% PG_FETCH2STRUCT parses a ResultsSet cell as returned by PG_FETCH 
% or PG_SELECT_STRUCT into a struct using the table column_names
% and column data_types for type conversion (casting). PG dates
% are converted to matlab datenumbers with PG_DATENUM. All
% column are turned into column vector fields.
%
% D = PG_FETCH2STRUCT(R, column_name, data_type) where R is the 
% cell returned by PG_FETCH or PG_SELECT_STRUCT, 
% column_name are the names of the columns, and data_type
% are the column data types to be used for type casting (conversion)
% into field of struct D. Make sure the order in R and column_name, 
% data_type match.
%
% Example: extract an entire PG table into a Matlab struct:
%
%  conn=pg_connectdb('my_db','user','my_user','pass','my_pass','schema','my_schema');
%  [nams, typs] = pg_getcolumns(conn,'my_table_name');
%  R = pg_select_struct(conn,'my_table_name',struct([]));
%  D = pg_fetch2struct(R,nams,typs)
%
%See also: PG_FETCH, PG_SELECT_STRUCT, PG_GETCOLUMNS

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

   for i=1:length(nams) % 1-based column index

      if     strcmp(typs{i},'real'                       );D.(nams{i}) =            [R{:,i}]';
      elseif strcmp(typs{i},'double precision'           );D.(nams{i}) =            [R{:,i}]';

      elseif strcmp(typs{i},'timestamp with time zone'   );D.(nams{i}) = pg_datenum({R{:,i}})';
      elseif strcmp(typs{i},'timestamp without time zone');D.(nams{i}) = pg_datenum({R{:,i}})';

      elseif strcmp(typs{i},'integer'                    );D.(nams{i}) =      int32([R{:,i}])';
      elseif strcmp(typs{i},'bigint'                     );D.(nams{i}) =      int64([R{:,i}])';

      elseif strcmp(typs{i},'text'                       );D.(nams{i}) =            {R{:,i}}';
      elseif strcmp(typs{i},'character varying'          );D.(nams{i}) =            {R{:,i}}';
      elseif strcmp(typs{i},'character'                  );D.(nams{i}) =        char(R{:,i});

      elseif strcmp(typs{i},'USER-DEFINED'               );D.(nams{i}) =            {R{:,i}}';
          
      else                                                 D.(nams{i}) =            {R{:,i}}';
      
         fprintf(2,[mfilename, ': datatype not yet implemented: ',typs{i},' \n'])

      end
   end