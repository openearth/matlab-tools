function varargout = odv_read(fname)
%ODV_READ   read file in ODV format
%
% D = ODV_READ(fname)
%
% loadsx file in ASCII Ocean Data vIewer format.
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: 

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

% 3.1.1 Metavariables
% ODV requires availability of some types of metadata for its basic operation. The geo-graphic location of a station, for instance, must be known to be able to plot the station in the station map. Date and time of observation, or the names of the station and cruise (or expedition) it belongs to are needed to fully identify the station and to be able to apply station selection filters that only allow stations of given name patterns are from specific time periods. Because of this fundamental importance, ODV defines a set of mandatory metavariables providing name, location and timing information of a given station (see Table 3-3). Other suggested metavariables are optional, and still others may be added by the user, as necessary. Metavariable values can be either text or numeric, and the respective byte lengths can be set by the user. The value type (text or numeric) of the mandatory meta-variables may not be changed, while the byte length may. As an example, the data type of the longitude and latitude metavariables may be set as 8 bytes double precision to accommodate better than cm-scale precision of station location. Metavariables with values in the ranges [0 to 255] or [-32,768 to 32,767] may be represented by 1 or 2 byte integers, respectively, to conserve storage space.

% Table 3-3: Mandatory and optional ODV metavariables.
% ---------------------------------------------------------------------------------------------------------
% Metavariable                                                                          % Recommended Label
% ---------------------------------------------------------------------------------------------------------
% Mandatory
%    Cruise label (text).                                                               %    Cruise
%    Station label (text).                                                              %    Station
%    Station type (text).                                                               %    Type
%    Date and time of observation (numeric year, month, day, hour, minute and seconds). %    yyyy-mm-ddThh:mm:ss.sss
%    Longitude (numeric).                                                               %    Longitude [degrees_east]
%    Latitude (numeric).                                                                %    Latitude [degrees_north]
% ---------------------------------------------------------------------------------------------------------
% Optional
%    SeaDataNet station identifier (text).                                              %    LOCAL_CDI_ID
%    SeaDataNet institution identifier (numeric).                                       %    EDMO_code
%    Bottom depth at station, or instrument depth (numeric).                            %    Bot. Depth [m]
%    ..
%    Additional user defined metavariables (text or numeric).
% ---------------------------------------------------------------------------------------------------------

% 17.3 Generic ODV Spreadsheet Format
% The ODV generic spreadsheet format is the recommended format for exchange of data beween data producers and data users. The generic spreadsheet format allows auto-matic import of data into ODV collections, not requiring any user interaction. ODV also uses the generic spreadsheet format when exporting data from collections, and the ex-ported datasets may easily be re-imported into the same or a different collection, possi-bly after editing and modifying the data in the file. Exporting data from the open collec-tion into a generic spreadsheet file is done via the Export>ODV Spreadsheet option. ODV generic spreadsheet files use the ASCII encoding, and the preferred file extension is .txt. Station metadata and data are provided in separate columns, where metadata and data columns can be in arbitrary order. Every metadata and data column may have an optional quality flag column. A quality flag column may appear anywhere after the metadata or data column it belongs to. Quality flag values may be in any one of the sup-ported quality flag schemes (see Table 17-5). The total number of columns in the file is unlimited. All non-comment lines (see below) in the file must have the same number of columns. Individual columns are separated by TAB or semicolon ; . Typically, ODV spreadsheet files hold the data of many stations from many cruises. The number of lines in a file, as well as the length of individual lines is unlimited. There are three types of lines in ODV generic spreadsheet files: (1) comment lines, (2) the column labels line, and (3) data lines.

% 17.3.1 Comment Lines
% Comment lines start with two slashes // as first two characters of the line and may con-tain arbitrary text in free format. Comment lines may, in principle, appear anywhere in the file, most commonly, however, they are placed at the beginning of the file and con-tain descriptions of the data, information about the originator or definitions of the va-riables included in the file. Comment lines are optional. Comment lines may be used to carry structured information that may be exploitet by ODV or other software. Examples are the //SDN_parameter_mapping block employed by the SeaDataNet project, and containing references to variable definitions in official pa-rameter dictionaries, or the //<attribute_name> lines defined by ODV, containing values for given attribute names. The currently defined attribute names are summarized in Table 15-6. Structured comment lines may only appear before the column labels line or the first data line.

% 17.3.2 Column Labels
% There has to be exactly one line containing the labels of the columns. This column labels line must always be present, it must appear before any data line and it must be the first non-comment line in the file.
% ODV generic spreadsheet files must provide columns for all mandatory metavariables (see Table 3-3), and the following labels must be used exactly as given as column labels: Cruise, Station, Type, one of the supported date/time formats, Longitude [degrees_east], Latitude [degrees_north], Bot. Depth [m]. The recommended date/time format is ISO 8601, which combines date and time as yyyy-mm-ddThh:mm:ss.sss in a single column. The labels Lon (°E) and Lat (°N) for longitude and latitude are still supported for back-ward compatibility.

fname = 'result_CTDCAST_75___41-260409.txt'

   D.filename     = fname;
   iostat         = 1;
   
   tmp = dir(fname);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fname])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      D.filedate  = tmp.date;
      D.filebytes = tmp.bytes;
   
      filenameshort = filename(fname);
      
      fid       = fopen  (fname,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fname])
         else
            iostat = -2;
         end
      
      elseif fid > 2
      
         %try

            %% Implement actual reading of the ASCII file here
            %--------------------------------
            
            rec   = fgetl(fid);
            iline = 0;
            while (strcmpi(rec(1:2),'//'))
            iline                  = iline + 1;
            D.lines.header{iline}  = rec;
            rec                    = fgetl(fid);
            end
            
            D.lines.column_labels = rec;
            
            ivar = 0;
            [variable,rec]    = strtok(rec)
            while ~isempty(variable)
               ivar              = ivar + 1
               D.variables{ivar} = variable
               [variable,rec]    = strtok(rec)
            end
            
            D.index.cruise    = find(strcmpi(D.variables,'cruise'))
            D.index.station   = find(strcmpi(D.variables,'Station'))
            D.index.type      = find(strcmpi(D.variables,'type'))
            D.index.time      = find(strcmpi(D.variables,'yyyy-mm-ddThh:mm:ss.sss'))
            D.index.latitude  = find(strcmpi(D.variables,'Latitude'))
            D.index.longitude = find(strcmpi(D.variables,'Longitude'))
          
            D.index.latitude  = D.index.latitude  +1;
            D.index.longitude = D.index.longitude +1;
            
                idat = 0;
            while 1
                idat = idat + 1;
                rec = fgetl(fid);
                if ~ischar(rec), break, end
               [D.data.cruise{idat} ,rec]  = strtok(rec);
               [D.data.station{idat},rec] = strtok(rec);
               [D.data.type{idat}   ,rec] = strtok(rec);
               [D.data.type2{idat}  ,rec] = strtok(rec);
               [D.data.time{idat}   ,rec] = strtok(rec);
               [D.data.lat{idat}    ,rec] = strtok(rec);
               [D.data.lon{idat}    ,rec] = strtok(rec);
            end

            D.data.lat = str2num(char(D.data.lat));
            D.data.lon = str2num(char(D.data.lon));

            %% Find column of mandarory variables
            %--------------------------------

         %catch
         % 
         %   if nargout==1
         %      error(['Error reading file: ',fname])
         %   else
         %      iostat = -3;
         %   end      
         %
         %end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
   D.iomethod = '$id$';
   D.read_at  = datestr(now);
   D.iostatus = iostat;

   if nargout==1
      varargout  = {D};
   elseif nargout==2
      varargout  = {D,iostat};
   end

% EOF
