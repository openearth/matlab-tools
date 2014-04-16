function D = jdb_fetch2struct(R,nams,typs)
%jdb_fetch2struct  parse cell from jdb_fetch or jdb_select_struct into struct 
%
% JDB_FETCH2STRUCT parses a ResultsSet cell as returned by JDB_FETCH 
% or JDB_SELECT_STRUCT into a struct using the table column_names
% and column data_types for type conversion (casting). PG dates
% are converted to matlab datenumbers with JDB_DATENUM. All
% column are turned into column vector fields.
%
% D = JDB_FETCH2STRUCT(R, column_name, data_type) where R is the 
% cell returned by JDB_FETCH or JDB_SELECT_STRUCT. column_name 
% and data_type are returned by JDB_GETCOLUMNS, column_name  are the 
% names of the columns, and data_type are the column data types
% to be used for type casting (conversion) into field of struct D.
% Make sure the order in R matches that of column_name, data_type.
%
% Example: extract an entire PG table into a Matlab struct:
%
%  conn= jdb_connectdb('my_db','user','my_user','pass','my_pass','schema','my_schema');
%  [nams, typs] = pg_getcolumns(conn,'my_table_name');
%  R = pg_select_struct(conn,'my_table_name',struct([]));
%  D = pg_fetch2struct(R,nams,typs)
%
%See also: JDB_FETCH, JDB_SELECT_STRUCT, JDB_GETCOLUMNS, jdb_fetch_struct

%% Copyright notice: see below

for i=1:length(nams) % 1-based column index
    
    nam = mkvar(nams{i}); % remove special characters
    typ = lower(typs{i});
    if     strcmp(typ,'real'                       ); D.(nam)     =     single([R{:,i}])';
    elseif strcmp(typ,'double precision'           ); D.(nam)     =            [R{:,i}]';
    elseif ismember(typ,{'numeric' 'number'}       ); D.(nam)     =            [R{:,i}]';
        
    elseif strcmp(typ,'date'                       ); D.(nam)     = jdb_datenum({R{:,i}});%';
    elseif strcmp(typ,'time without time zone'     ); D.(nam)     = jdb_datenum({R{:,i}});%';
    elseif strcmp(typ,'time with time zone'        );[D.(nam),...
            D.timezone] = jdb_datenum({R{:,i}});
    elseif strcmp(typ,'timestamp without time zone'); D.(nam)     = jdb_datenum({R{:,i}});%';
    elseif strcmp(typ,'timestamp with time zone'   );[D.(nam),...
            D.timezone] = jdb_datenum({R{:,i}});
        
    elseif strcmp(typ,'serial'                     ); D.(nam)     =       int8([R{:,i}])'; %int4
    elseif strcmp(typ,'smallint'                   ); D.(nam)     =       int8([R{:,i}])'; %int2
    elseif strcmp(typ,'integer'                    ); D.(nam)     =       int8([R{:,i}])'; %int4
    elseif strcmp(typ,'bigint'                     ); D.(nam)     =       int8([R{:,i}])'; %int8
        
    elseif strcmp(typ,'boolean'                    ); D.(nam)     =     logical([R{:,i}])';
        
    elseif strcmp(typ,'text'                       ); D.(nam)     =            {R{:,i}}';
    elseif ismember(typ,{'character varying' 'varchar' 'varchar2'} ); D.(nam)     =            {R{:,i}}';
    elseif strcmp(typ,'character'                  ); D.(nam)     =        char(R{:,i});
    elseif strcmp(typ,'uuid'                       ); D.(nam)     =            {R{:,i}}';
        
    elseif strcmp(typ,'user-defined'               ); D.(nam)     =            {R{:,i}}';
        
    else                                              D.(nam)     =            {R{:,i}}';
        
        fprintf(2,[mfilename, ': datatype not yet implemented: ',typs{i},' \n'])
        
    end
end
   
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Tu Delft / Deltares for Building with Nature
%       Gerben J. de Boer
%   Copyright (C) 2014 Van Oord
%       R.A. van der Hout
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl
%       ronald.vanderhout@vanoord.com
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
