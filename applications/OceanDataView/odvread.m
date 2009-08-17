function varargout = odv_read(fullfilename)
%ODVREAD   read file in ODV format (still test project)
%
%   D = odvread(fname)
%
% loads ASCII file in Ocean Data Viewer (ODV) format into struct D.
%
% ODV is one of the standard file formats of 
% <a href="http://www.SeaDataNet.org">www.SeaDataNet.org</a> of which <a href="http://www.nodc.nl">www.nodc.nl</a> is a member.
%
% ODV files contain the following information:
%
% +---------------------------------------------+----------------------------------------
% | ## Metavariables ########################## | ## Values ############################
% +---------------------------------------------+----------------------------------------
% | Cruise                                      | Cruise, expedition, or instrument name
% | Station                                     | Unique station identifier
% | Type                                        | B for bottle or 
% |                                             | C for CTD, 
% |                                             | XBT or stations with >250 samples
% | yyyy-mm-ddThh:mm:ss.sss                     | Date and time of station (instrument at depth)
% | Longitude [degrees_east]                    | Longitude of station (instrument at depth)
% | Latitude [degrees_north]                    | Latitude of station (instrument at depth)
% | Bot. Depth [m]                              | Bottom depth of station
% | Unlimited number of other metavariables     | Text or numeric; user defined text length 
% |                                             | or 1 to 8 byte integer or floating point numbers
% +---------------------------------------------+----------------------------------------
% | ## Collection Variables ################### | ## Comment ############################
% +---------------------------------------------+----------------------------------------
% | Depth or pressure in water column, ice core | 
% | core, sediment core, or soil; elevation or  | To be used as primary variable
% +---------------------------------------------+----------------------------------------
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a> (Ocean Data Viewer)
%See also: ODVDISP, ODVPLOT

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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
% $Keywords:$

% TO DO: file #Processing 328/764: result_CTDCAST_75___36-260409# is slow, find out why

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

% 15.6 Making Cruise Maps
% You can create full-page, high quality stations maps showing the currently selected sta-tions of the open data collection using View>Window Layout>Layout Templates>Full Screen Map. Station maps may also be produced if you only have access to the station metadata (e.g., station postions, dates, etc.), but the actual station data are unaccessible. Here is how to proceed:
% * In an empty directory on your disk create an ASCII file that contains the longi-tude, latitude coordinates of the stations or way-points of your track. This file should have a descriptive name (e.g., CruiseTrack_xxx.txt, where xxx represents the name of your cruise) and it should comply with the generic ODV spreadsheet format specifications.
% As first line of the file use the following header line (note that columns are TAB sepa-rated): Cruise Station Type yyyy-mm-ddThh:mm Longitude [degrees_east] Latitude [degrees_north] Bot. Depth [m] Dummy1 Dummy2 Immediately following the header line, add one data line for each station or cruise track node and provide the following information for the respective station or node:
%
% ---------------------------------------------------------------------------------------------------------
% Cruise                    % The name of the cruise
% Station                   % Station label or number
% Type                      %"B"
% yyyy-mm-ddThh:mm          % Station date and time
% Longitude [degrees_east]  % Decimal longitude of station
% Latitude [degrees_north]  % Decimal latitude of station
% Bot. Depth [m]            % Bottom depth at station location or "0"
% Dummy1                    % "0"
% Dummy2                    % "0"
% ---------------------------------------------------------------------------------------------------------

% 17.3 Generic ODV Spreadsheet Format
% The ODV generic spreadsheet format is the recommended format for exchange of data beween data producers and data users. The generic spreadsheet format allows auto-matic import of data into ODV collections, not requiring any user interaction. ODV also uses the generic spreadsheet format when exporting data from collections, and the ex-ported datasets may easily be re-imported into the same or a different collection, possi-bly after editing and modifying the data in the file. Exporting data from the open collec-tion into a generic spreadsheet file is done via the Export>ODV Spreadsheet option. ODV generic spreadsheet files use the ASCII encoding, and the preferred file extension is .txt. Station metadata and data are provided in separate columns, where metadata and data columns can be in arbitrary order. Every metadata and data column may have an optional quality flag column. A quality flag column may appear anywhere after the metadata or data column it belongs to. Quality flag values may be in any one of the sup-ported quality flag schemes (see Table 17-5). The total number of columns in the file is unlimited. All non-comment lines (see below) in the file must have the same number of columns. Individual columns are separated by TAB or semicolon ; . Typically, ODV spreadsheet files hold the data of many stations from many cruises. The number of lines in a file, as well as the length of individual lines is unlimited. There are three types of lines in ODV generic spreadsheet files: (1) comment lines, (2) the column labels line, and (3) data lines.

% 17.3.1 Comment Lines
% Comment lines start with two slashes // as first two characters of the line and may con-tain arbitrary text in free format. Comment lines may, in principle, appear anywhere in the file, most commonly, however, they are placed at the beginning of the file and con-tain descriptions of the data, information about the originator or definitions of the va-riables included in the file. Comment lines are optional. Comment lines may be used to carry structured information that may be exploitet by ODV or other software. Examples are the //SDN_parameter_mapping block employed by the SeaDataNet project, and containing references to variable definitions in official pa-rameter dictionaries, or the //<attribute_name> lines defined by ODV, containing values for given attribute names. The currently defined attribute names are summarized in Table 15-6. Structured comment lines may only appear before the column labels line or the first data line.

% 17.3.2 Column Labels
% There has to be exactly one line containing the labels of the columns. This column labels line must always be present, it must appear before any data line and it must be the first non-comment line in the file.
% ODV generic spreadsheet files must provide columns for all mandatory metavariables (see Table 3-3), and the following labels must be used exactly as given as column labels: Cruise, Station, Type, one of the supported date/time formats, Longitude [degrees_east], Latitude [degrees_north], Bot. Depth [m]. The recommended date/time format is ISO 8601, which combines date and time as yyyy-mm-ddThh:mm:ss.sss in a single column. The labels Lon (°E) and Lat (°N) for longitude and latitude are still supported for back-ward compatibility.

   % TO DO: scan first for # data lines, to preallocate  D.rawdata??
   % TO DO: interpret SDN keyword in header

   %disp('error: ODVREAD is still a test project!')
   
   OPT.delimiter     = char(9);% columns are TAB sepa-rated [ODV manual section 15.6]
   OPT.variablesonly = 1; % remove units from variables

  [D.file.path D.file.name D.file.ext] = fileparts(fullfilename);
   D.file.fullfilename = fullfilename;

   iostat        = 1;
   
%% check for file existence (1)                

   tmp = dir(fullfilename);
   
   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',fullfilename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0
   
      D.file.date  = tmp.date;
      D.file.bytes = tmp.bytes;
   
%% check for file opening (2)

      filenameshort = filename(D.file.name);
      
      fid       = fopen  (fullfilename,'r');

      if fid < 0
         
         if nargout==1
            error(['Error opening file: ',fullfilename])
         else
            iostat = -2;
         end
      
      elseif fid > 2
      
%% read file line by line

         %try

            %% I) Header lines (//)
            %--------------------------------
            
            rec   = fgetl(fid);
            iline = 0;
            while (strcmpi(rec(1:2),'//'))
            iline                  = iline + 1;
            D.lines.header{iline}  = rec;
            rec                    = fgetl(fid);
            end
            
            %% II) Column labels (variables)
            %--------------------------------

            D.lines.column_labels = rec;
            
            ivar = 0;
            [variable,rec]    = strtok(rec,OPT.delimiter);
            while ~isempty(variable)
               ivar              = ivar + 1;
               D.variables{ivar} = variable;
               [variable,rec]    = strtok(rec,OPT.delimiter);
            end
            
            nvar = length( D.variables);
            
            %% II) Units
            %--------------------------------
            
            for ivar=1:length(D.variables)
               brack1            = strfind(D.variables{ivar},'[');
               brack2            = strfind(D.variables{ivar},']');
               %-% disp([D.variables{ivar},' ',num2str([ivar brack1 brack2])])
               D.units{ivar}     = D.variables{ivar}([brack1+1:brack2-1]);
               % remove units AFTER extracting units
               if OPT.variablesonly
               if ~isempty(brack1)
               D.variables{ivar} = strtrim(D.variables{ivar}([1:brack1-1]));
               end
               end
               %-% disp([D.variables{ivar},' ',num2str([ivar brack1 brack2])])
            end

            %% Find column index of mandarory variables
            %--------------------------------

            D.index.cruise                 = find(strcmpi(D.variables,'cruise'));
            D.index.station                = find(strcmpi(D.variables,'Station'));
            D.index.type                   = find(strcmpi(D.variables,'type'));
            D.index.time                   = find(strcmpi(D.variables,'yyyy-mm-ddThh:mm:ss.sss'));
            if OPT.variablesonly
            D.index.latitude               = find(strcmpi(D.variables,'Latitude'));
            D.index.longitude              = find(strcmpi(D.variables,'Longitude'));
            D.index.bot_depth              = find(strcmpi(D.variables,'Bot. Depth'));
            D.index.sea_water_pressure     = find(strcmpi(D.variables,'PRESSURE'));
            D.index.sea_water_temperature  = find(strcmpi(D.variables,'T90'));
            D.index.sea_water_salinity     = find(strcmpi(D.variables,'Salinity'));
            D.index.sea_water_fluorescence = find(strcmpi(D.variables,'fluorescence'));
            else
            D.index.latitude               = find(strcmpi(D.variables,'Latitude [degrees_north]'));
            D.index.longitude              = find(strcmpi(D.variables,'Longitude [degrees_east]'));
            D.index.bot_depth              = find(strcmpi(D.variables,'Bot. Depth [m]'));
            D.index.sea_water_pressure     = find(strcmpi(D.variables,'PRESSURE [dbar]'));
            D.index.sea_water_temperature  = find(strcmpi(D.variables,'T90 [degC]'));
            D.index.sea_water_salinity     = find(strcmpi(D.variables,'Salinity [PSU]'));
            D.index.sea_water_fluorescence = find(strcmpi(D.variables,'fluorescence [ugr/l]'));
            end
            D.index.LOCAL_CDI_ID           = find(strcmpi(D.variables,'LOCAL_CDI_ID'));
            D.index.EDMO_code              = find(strcmpi(D.variables,'EDMO_code'));
            
            %% III) Data lines
            %--------------------------------
            
                idat   = 0;
                D.rawdata = cell(nvar,1);
            while 1
                rec = fgetl(fid);
                if ~ischar(rec), break, end
                idat = idat + 1;
                for ivar=1:nvar
                  [D.rawdata{ivar,idat} ,rec] = strtok(rec,OPT.delimiter);
                end
               %[D.data.cruise{idat} ,rec] = strtok(rec,OPT.delimiter);
               %[D.data.station{idat},rec] = strtok(rec,OPT.delimiter);
               %[D.data.type{idat}   ,rec] = strtok(rec,OPT.delimiter);
               %[D.data.time{idat}   ,rec] = strtok(rec,OPT.delimiter);
               %[D.data.lat{idat}    ,rec] = strtok(rec,OPT.delimiter);
               %[D.data.lon{idat}    ,rec] = strtok(rec,OPT.delimiter);
            end
            
            if idat == 0

               disp(['Found empty file: ',D.file.name])

               D.rawdata                     = {[]};
               D.data.cruise                 = {['']}; % {} gives error with char
               D.data.station                = {['']}; % {} gives error with char
               D.data.type                   = {['']}; % {} gives error with char
               D.data.datenum                =  nan;   % datestr gives error on NaN,Inf, while 0 not handy
               D.data.latitude               =  nan;
               D.data.longitude              =  nan;
               D.data.bot_depth              =  nan;
               D.data.sea_water_pressure     =  nan;
               D.data.sea_water_temperature  =  nan;
               D.data.sea_water_salinity     =  nan;
               D.data.sea_water_fluorescence =  nan;
               D.data.LOCAL_CDI_ID           = {['']}; % {} gives error with char
               D.data.EDMO_code              = {['']}; % {} gives error with char

            else

               D.data.cruise                 =             {D.rawdata{D.index.cruise       ,:}};
               D.data.station                =             {D.rawdata{D.index.station      ,:}};
               D.data.type                   =             {D.rawdata{D.index.type         ,:}};
               D.data.datenum                = datenum(char(D.rawdata{D.index.time         ,:}),'yyyy-mm-ddTHH:MM:SS');
               D.data.latitude               = str2num(char(D.rawdata{D.index.latitude     ,:}));
               D.data.longitude              = str2num(char(D.rawdata{D.index.longitude    ,:}));
               D.data.bot_depth              = str2num(char(D.rawdata{D.index.bot_depth    ,:}));
              %Very slow !!!
              %D.data.(odvname2standard_name('T90'))      = str2num(char(D.rawdata{D.index.sea_water_temperature        ,:}));
              %D.data.(odvname2standard_name('Salinity')) = str2num(char(D.rawdata{D.index.sea_water_salinity   ,:}));
               D.data.sea_water_pressure     = str2num(char(D.rawdata{D.index.sea_water_pressure    ,:}));
               D.data.sea_water_temperature  = str2num(char(D.rawdata{D.index.sea_water_temperature ,:}));
               D.data.sea_water_salinity     = str2num(char(D.rawdata{D.index.sea_water_salinity    ,:}));
               D.data.sea_water_fluorescence = str2num(char(D.rawdata{D.index.sea_water_fluorescence,:}));
               D.data.LOCAL_CDI_ID           =              {D.rawdata{D.index.LOCAL_CDI_ID ,:}};
               D.data.EDMO_code              =              {D.rawdata{D.index.EDMO_code    ,:}};
               
            end

         %catch
         % 
         %   if nargout==1
         %      error(['Error reading file: ',D.file.name])
         %   else
         %      iostat = -3;
         %   end      
         %
         %end % try
         
         fclose(fid);
         
      end %  if fid <0
      
   end % if length(tmp)==0
   
%% Get extraction info: 1 value per cast (and check for uniqueness: i.e. are there time-consuming, sidewards-drifting casts?)
   [D.cruise      ,ind]   = unique(D.data.cruise      );if length(ind) > 1;error('no unique value: cruise      ');end
   [D.station     ,ind]   = unique(D.data.station     );if length(ind) > 1;error('no unique value: station     ');end
   [D.type        ,ind]   = unique(D.data.type        );if length(ind) > 1;error('no unique value: type        ');end
   [D.datenum     ,ind]   = unique(D.data.datenum     );if length(ind) > 1;error('no unique value: datenum     ');end
   [D.latitude    ,ind]   = unique(D.data.latitude    );if length(ind) > 1;error('no unique value: latitude    ');end
   [D.longitude   ,ind]   = unique(D.data.longitude   );if length(ind) > 1;error('no unique value: longitude   ');end
   [D.bot_depth   ,ind]   = unique(D.data.bot_depth   );if length(ind) > 1;error('no unique value: bot_depth   ');end
   [D.LOCAL_CDI_ID,ind]   = unique(D.data.LOCAL_CDI_ID);if length(ind) > 1;error('no unique value: LOCAL_CDI_ID');end
   [D.EDMO_code   ,ind]   = unique(D.data.EDMO_code   );if length(ind) > 1;error('no unique value: EDMO_code   ');end
    D.file.name             = char(D.file.name   );		      
    D.cruise                = char(D.cruise      );		      
    D.station               = char(D.station     );		      
    D.type                  = char(D.type        );		      
    D.LOCAL_CDI_ID          = char(D.LOCAL_CDI_ID);		      
    D.EDMO_code             = char(D.EDMO_code   );		      
   
%% Output

   D.read.with   = '$Id$';
   D.read.at     = datestr(now);
   D.read.status = iostat;

   if nargout==1
      varargout  = {D};
   elseif nargout==2
      varargout  = {D,iostat};
   end

% EOF
