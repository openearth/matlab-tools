%Toolbox for <a href="http://www.postgresql.org/">PostgreSQL</a> relational database management system
%
% START:
% pg_settings                    - Load toolbox for JDBC connection to a PostgreSQL database
% pg_connectdb                   - Creates a JDBC connection to a PostgreSQL database
% 
% high-level READ,INSPECT:
% pg_gettables                   - List all tables in current database
% pg_getcolumns                  - List all columns in a given table
% pg_getpk                       - Retrieve name of primary key for given table
% pg_getid                       - Retrieves primary key value for specific record in given table
% pg_getids                      - Retrieves primary key value for many records in given table
% pg_select_struct               - Selects records from a table based on a structure
%
% WRITE,CHANGE:
% pg_insert_struct               - Inserts a structure into a table
% pg_update_struct               - Updates a record in a table based on a structure
% pg_upsert_struct               - Updates existing records or inserts it otherwise
% pg_cleartable                  - Deletes all contents from a table
%
% low-level SQL query: for explanation see <a href="http://www.postgresql.org/docs/current/static/sql.html">SQL primer</a> 
% pg_quote                       - Wrap identifiers (table, column names) in " quotes to enable mixed upper/lower case
% pg_query                       - Builts a SQL query string from structures
% pg_exec                        - Executes a SQL query
% pg_fetch                       - Executes a SQL query and fetches the result
% pg_error                       - Checks a SQL query result for errors
% pg_value2sql                   - Makes a cell array of arbitrary values suitable for the use in an SQL query
% pg_datenum                     - conversion between Matlab datenumbers and PG datetime
% pg_test                        - unit test for postgresql
% pg_tutorial                    - example with OPeNDAP time series for postgresql
%
%See also: database, netcdf, save, load

% useful links

% http://www.cybertec.at/postgresql_produkte/pg_matlab-matlab-postgresql-integration/
% http://www.mathworks.com/matlabcentral/fileexchange/3027
% http://www-css.fnal.gov/dsg/external/freeware/mysql-vs-pgsql.html
% http://www.serverwatch.com/trends/article.php/3883441/Top-10-Enterprise-Database-Systems-to-Consider.htm
% http://philip.greenspun.com/panda/
