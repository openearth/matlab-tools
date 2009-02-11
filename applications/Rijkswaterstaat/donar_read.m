function varargout = donar_read(fnames,varargin)
%DONAR_READ   Read ASCII text file from www.waterbase.nl
%
%   DAT = donar_read(fname)
%   DAT = donar_read(fname,<keyword,value>)
%
%   reads ONE txt file (as downloaded from www.waterbase.nl) of just 
%   ONE parameter at MULTIPLE locations to ONE structure DAT
%       or
%   reads MULTIPLE txt files (as downloaded from www.waterbase.nl) of just 
%   ONE parameter at ONE location to ONE structure DAT.
%
%   Implemented <keyword,value> pairs are:
%
%   * 'headerlines' = 'auto'  (default) finds automatically 1st line starting with:
%                             start_last_header_line which is by default 
%                             "locatie;waarnemingssoort;datum;tijd"
%                             This option also reads the headerlines into DAT.
%                      number 7, or 5 or 4 for older files
%                             where the EPSG names of the coordinates 
%                             were not yet added.
%
%   * 'start_last_header_line': "locatie;waarnemingssoort;datum;tijd"
%
%   * 'locationcode': obtain locationcode from waterbase filename
%                     (only in case with ONE location per file)
%
%   * 'fieldname' = character
%      is the fieldname of the parameter to be read, by
%      default 'waarde' (as in DONAR file).
%
%   * 'fieldnamescale' = real value (default 1), fields is DIVIDED by fieldnamescale.
%
%   * 'scale','xscale','yscale' = real value
%     The x and y fields can optionally be divided by 100 so they are 
%     in SI units (meters etc.). (default all scales 1).
%
%   * 'method' = 'textread' (default) or 'fgetl'
%     donar_read uses textread by default, which is OK for small files
%     (up to tens of Mb's). But NOTE that loading a 150 MB txt 
%     file with textread requires ~ 1.3 Gb of memory!!, whereas method 
%     fgetl uses no more memory then needed. Use preallocate with fgetl to 
%     speed up. textread reads a number of meta-data, where fgetl only 
%     reads 5 fields:: datenum,waarde,x,y,epsg. With fgetl only one
%     location per file is allowed.
%
%   * 'preallocate' = integer value (only for method = 'fgetl')
%     The method fgetl is not vectorized, and is therefore exceptionally slow 
%     for large data sets. But, it requires significantly less memory than 
%     textread. If you set fgetl to Inf, DONAR_READ, first scrolls the entire 
%     file to count the number of lines, and then reads the file again with 
%     just a little bit over-preallocation with the # of header lines (default).
%
%   * ntmax, default Inf for method=fgetl
%
%     preallocate is the maximum number of timesteps per location. Setting 
%     this equal to or larger than the number of timesteps, considerably 
%     speeds up. Any excessive number of  allocated times is removed at the 
%     end. When a too small number is passed, the arrays are dynamically
%     adjusted every line. This is SLOW. Idea: to preallocate 
%     an 11-year 10-minute time series you need: 11*366*24*6 = 579744.
%
% LIMITATIONS: DONAR_READ cannot handle lines with ampty values as:
%
%    Lauwersoog;Debiet in m3/s in oppervlaktewater;;;;Geen data beschikbaar/No data available;;9;9;9;9;9;9;9;9;9;9;9,9,9
%    Maasmond;Debiet in m3/s in oppervlaktewater;;;;Geen data beschikbaar/No data available;;9;9;9;9;9;9;9;9;9;9;9,9,9
%
% LOACTIONS:
%
%    On <a href="http://www.waterbase.nl/metis">waterbase.nl/metis</a> there is a table where the locations including coordinates 
%    can be found. The following <a href="http://www.epsg.org/guides/">epsg</a> codes are used:
%    
%    * 4230 ED50  (lon,lat) [degrees, minutes, seconds and tenths of seconds] (longitude (Ol.),latitude (Nb.))
%    * 4326 WGS84 (lon,lat) [degrees, minutes, seconds and tenths of seconds] (longitude (Ol.),latitude (Nb.))
%    * 7415 RD    (x  ,y  ) [cm] (East, North) 
%
%   © G.J. de Boer, Feb 2006 - 2009 (TU Delft)
%
%   See web : <a href="http://www.epsg.org/guides/">www.epsg.org</a>, <a href="http://www.waterbase.nl"    >www.waterbase.nl</a>
%   See also: LOAD, XLSREAD

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

% uses: time2datenum
%       ctransdv (optionally)

%% Defaults
%% ----------------------

   OPT.xscale                 = 1;
   OPT.yscale                 = 1;
   OPT.valuescale             = 1;
   
   OPT.value                  = 'waarde';
   OPT.method                 = 'textread';
   OPT.preallocate            = Inf; %11*366*24*6; % 11 years every 10 minute for method = 'fgetl'
   OPT.headerlines            = 'auto'; %changed from 4 to 5 after inclusion of EPSG names of coordinates and is 7 on 2007 june 27th
   OPT.start_last_header_line = 'locatie;waarnemingssoort;datum;tijd';
   OPT.display                = 1;
   OPT.displayskip            = 1000;
   OPT.ntmax                  = -1;
   OPT.locationcode           = 1;
   OPT.ctransdv               = exist('ctransdv')==2; % only required for parijs RD coordiantes

%% Key words
%% ----------------------

   i = 1;
   %% remaining number of arguments is always even now
   while i<=nargin-1,
       switch lower ( varargin{i  })
       % all keywords lower case
       case 'xscale';                 i=i+1;OPT.xscale                 = varargin{i};
       case 'yscale';                 i=i+1;OPT.yscale                 = varargin{i};
       case 'scale';                  i=i+1;OPT.xscale                 = varargin{i};
                                            OPT.yscale                 = varargin{i};
       case 'fieldnamescale';         i=i+1;OPT.valuescale             = varargin{i};
       case 'fieldname';              i=i+1;OPT.value                  = varargin{i};

       case 'method';                 i=i+1;OPT.method                 = varargin{i};
       case 'preallocate';            i=i+1;OPT.preallocate            = varargin{i};
       case 'headerlines';            i=i+1;OPT.headerlines            = varargin{i};
       case 'start_last_header_line'; i=i+1;OPT.start_last_header_line = varargin{i};
       case 'display';                i=i+1;OPT.display                = varargin{i};
       case 'displayskip';            i=i+1;OPT.displayskip            = varargin{i};
       case 'ntmax';                  i=i+1;OPT.ntmax                  = varargin{i};
       case 'locationcode';           i=i+1;OPT.locationcode           = varargin{i};
       case 'ctransdv';               i=i+1;OPT.ctransdv               = varargin{i};
       otherwise
         error(sprintf('Invalid string argument (caps?): "%s".',...
         varargin{i}));
       end
       i=i+1;
   end
   
fnames = cellstr(fnames);

for ifile=1:length(fnames)

   fname = char(fnames{ifile});

   %% Original file info
   %% ----------------------------------------

      D = dir(fname);
      
      if isempty(D)
         error([fname,' not found'])
      end
   
   %% Automatic header line detection
   %% ----------------------------------------
   
   if ischar(OPT.headerlines)
      if strcmpi(OPT.headerlines,'auto')

         fid           = fopen(fname,'r');
	 record        = fgetl(fid); % read one record
	 n_headerlines = 0;
	 finished      = 0;
	 
	 if length(record) >= length(OPT.start_last_header_line)
	    if strcmpi(record(1:length(OPT.start_last_header_line)),...
	                               OPT.start_last_header_line)
	       finished = 1;
	    end
	 end
	 
	 while ~(finished)

	    n_headerlines           = n_headerlines + 1;
	    D.header{n_headerlines} = record;

	    record = fgetl(fid); % read one record
	    
	    if length(record) >= length(OPT.start_last_header_line)
	    if strcmpi(record(1:length(OPT.start_last_header_line)),...
	                               OPT.start_last_header_line)
	       finished                = 1;
	       n_headerlines           = n_headerlines + 1;
	       D.header{n_headerlines} = record;
	    end
	    end

	 end
	 
         fclose(fid);
	 
      end

      OPT.headerlines = n_headerlines;

   end

   %% ----------------------------------------
   %% locatie;waarnemingssoort;datum;tijd;bepalingsgrenscode;waarde;eenheid;hoedanigheid;anamet;ogi;vat;bemhgt;refvlk;x;y;orgaan;biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam)
   %% Noordwijk meetpost;Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater;1982-09-02;19:30;;-36;cm t.o.v. NAP;T.o.v. Normaal Amsterdams Peil;Rek. gem. waterhoogte over vorige 10 min. (MSW);Nationaal;Stappenbaak - type Marine 300;NVT;NVT;4174600;52162600;NVT;NVT,NVT,Niet van toepassing
   %% ----------------------------------------
   %%  1    locatie                                                               Noordwijk meetpost
   %%  2    waarnemingssoort							  Waterhoogte in cm t.o.v. normaal amsterdams peil in oppervlaktewater
   %%  3    datum								  1982-09-02
   %%  4    tijd								  19:30
   %%  5    bepalingsgrenscode
   %%  6    waarde								  -36
   %%  7    eenheid								  cm t.o.v. NAP
   %%  8    hoedanigheid							  T.o.v. Normaal Amsterdams Peil
   %%  9    anamet								  Rek. gem. waterhoogte over vorige 10 min. (MSW)
   %% 10    ogi									  Nationaal
   %% 11    vat									  Stappenbaak - type Marine 300
   %% 12    bemhgt								  NVT
   %% 13    refvlk								  NVT
   %% 14/   epsg								  7415
   %% 15/14 x									  4174600
   %% 16/15 y									  52162600
   %% 17/16 orgaan								  NVT
   %% 18/17 biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam) NVT,NVT,Niet van toepassing
   % new/old
   %% ----------------------------------------
   
   %% ----------------------------------------
   
   if strcmp(OPT.method,'textread')
   
      if OPT.headerlines==4
      %% Old file type, no extra headerline, AND extra column with EPSG number
      %% ----------------------------------------
      [location          ,...
       waarnemingssoort  ,...
       datestring        ,...
       timestring        ,...
       bepalingsgrenscode,...
       waarde            ,...
       eenheid           ,...
       hoedanigheid      ,...
       anamet            ,...
       ogi               ,...
       vat               ,...
       bemhgt            ,...
       refvlk            ,...
       x                 ,...
       y                 ,...
       orgaan            ,...
       biotaxon] = textread(fname,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s',OPT.ntmax,...
                           'headerlines',OPT.headerlines,...
                           'delimiter'  ,';');
       else
      %% Extra headerline, AND extra column with EPSG number
      %% ----------------------------------------
      [location          ,...
       waarnemingssoort  ,...
       datestring        ,...
       timestring        ,...
       bepalingsgrenscode,...
       waardestring      ,...
       eenheid           ,...
       hoedanigheid      ,...
       anamet            ,...
       ogi               ,...
       vat               ,...
       bemhgt            ,...
       refvlk            ,...
       epsg              ,...
       x                 ,...
       y                 ,...
       orgaan            ,...
       biotaxon] = textread(fname,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s',...
                           'headerlines',OPT.headerlines,...
                           'delimiter'  ,';');    
       end
       
       datenumbers = time2datenum(datestring,timestring);
       
       disp(['donar_read: read raw data: ',fname])
       
       % Method below (%n) cannot deal with Not Available data as in:
       % Maassluis;Temperatuur in oC in oppervlaktewater;1994-08-03;07:14;;25;graden Celsius;NVT;Onbekend;Nationaal;;-100;T.o.v. Waterspiegel;7415;77500;436100;NVT;NVT,NVT,Niet van toepassing
       % Maassluis;Temperatuur in oC in oppervlaktewater;1994-08-17;05:53;;N.A.;graden Celsius;NVT;Onbekend;Nationaal;;-100;T.o.v. Waterspiegel;7415;77500;436100;NVT;NVT,NVT,Niet van toepassing
       %    biotaxon] = textread(fname,'%s%s%s%s%s%n%s%s%s%s%s%s%s%s%s%s%s',...
       %                        'headerlines',OPT.headerlines,...
       %                        'delimiter'  ,';');
       
       %% Replace N.A. with NaNs
       %% ----------------------
       
       %%waardestring = char(waardestring);
       %%
       %%%whos waarde
       %%%108311x39
       %%
       %%nodatavalues = {'N.A.',...                                  % OPP WATER TEMP (DONAR)
       %%                'Geen data beschikbaar/No data available'}; % Debiet
       %%                
       %%for ii = 1:length(nodatavalues)
       %%   mask   = strmatch(char(nodatavalues{ii}),waarde,'exact');
       %%   for ii=1:length(mask)
       %%      waarde(mask(ii),:)=pad('NaN',size(waarde,2));
       %%   end
       %%end
       %%
       %%[waarde,OK]=str2num(waardestring);
       %%   if OK==0
       %%      error('conversion data to numeric values, probaly due to Geen data beschikbaar/No data available text in data.')
       %%   end
   
       waardestring = cellstr(waardestring);
       waarde       = str2double(waardestring); % returns NaN where waardestring is not 
   
       %error('waarde also per station')
   
       %% Make into table
       %% ----------------------
   
       %% TO DO: Sort per station into seperate struct fields
       
       D.locations = unique(location);
       
       for istat=1:length(D.locations)
       
          disp(['donar_read: transforming to struct: ',num2str(istat),'/',num2str(length(D.locations))]);
       
          mask = strmatch(D.locations{istat},location);
   
          D.data(istat).location           = char(location         (mask(1),:)); % unique by definition of using strmatch above
          D.data(istat).waarnemingssoort   = char(waarnemingssoort (mask(1),:)); % that's all what DONAR hands out.
         %D.data(istat).datum              = 
         %D.data(istat).tijd               = 
         %D.data(istat).bepalingsgrenscode = 
         %D.data(istat).waarde             = 
          D.data(istat).units              = char(eenheid          (mask(1),:)); % assumed
          D.data(istat).hoedanigheid       = hoedanigheid          (mask,:); 
          D.data(istat).anamet             = anamet                (mask,:);
          D.data(istat).ogi                = ogi                   (mask,:);
          D.data(istat).vat                = vat                   (mask,:);
         %D.data(istat).bemhgt             = 
         %D.data(istat).refvlk             = 
         
          D.data(istat).epsg               = str2num(char(epsg{mask,:})); % tested to be not unique
          D.data(istat).x                  = str2num(char(   x{mask,:})); % tested to be not unique
          D.data(istat).y                  = str2num(char(   y{mask,:})); % tested to be not unique
         %D.data(istat).orgaan             = 
         %D.data(istat).biotaxon           = 
         
          D.data(istat).(OPT.value)        = waarde(mask);
          D.data(istat).datenum            = datenumbers(mask);

          %% Get uniform co-ordinates (lat,lon)
          %% ------------------------
          
             D.data(istat).lon = repmat(nan,size(D.data(istat).x));
             D.data(istat).lat = repmat(nan,size(D.data(istat).x));
          
                               geomask.ed50   =         D.data(istat).epsg==4230;
             D.data(istat).lon(geomask.ed50)  =         D.data(istat).x(geomask.ed50);
             D.data(istat).lat(geomask.ed50)  =         D.data(istat).y(geomask.ed50);

                               geomask.ll     =         D.data(istat).epsg==4326;
             D.data(istat).lon(geomask.ll )   =         D.data(istat).x(geomask.ll );
             D.data(istat).lat(geomask.ll )   =         D.data(istat).y(geomask.ll );

          if OPT.ctransdv 
                               geomask.par    =         D.data(istat).epsg==7415;
            [D.data(istat).lon(geomask.par),...
             D.data(istat).lat(geomask.par)]  =ctransdv(D.data(istat).x(geomask.par),...
                                                        D.data(istat).y(geomask.par),'par','ll');

                               geomask.unknow = ~(geomask.ed50 | geomask.par | geomask.ll);
          else
             % try different mapping toolbox, m_map, or matlab mapping toolbox or upcoming supertrans
          end
          
          
       end
   
   elseif strcmp(OPT.method,'fgetl')
   
      if OPT.ntmax  == -1
         OPT.ntmax = Inf;
      end
   
      % warning('method fgetl does not work for multiple stations, neither for missing data data ''N.A.''')
   
      %% Fast scan file one time to count number of lines
      %% ----------------------------------------
      
      if isinf(OPT.preallocate) %%%-%%% & 0
         fid = fopen(fname,'r');
         nt  = 0;
         disp('Fast scanning file  to check number of lines')
         while 1
            tline = fgetl(fid);
            nt    = nt+1;
            if ~ischar(tline), break, end
            if mod(nt,1000)==0
               disp([num2str(nt)])
            end
         end
         fclose(fid);      
         disp(['Slow scanning file to read data on # ',num2str(nt),' lines is.'])
      else
         nt = OPT.preallocate;
      end
      
      %%%-%%% nt=10;
      
      %% Pre-allocate arrays
      %% ----------------------------------------

      D.readme           = ['Except the for five fields datenum,',OPT.value,',x,y,epsg the fields contain only the first record !!!'];
      D.data.datenum     = repmat(nan,[1 nt]); % 1
      D.data.(OPT.value) = repmat(nan,[1 nt]); % 2
      D.data.x           = repmat(nan,[1 nt]); % 3
      D.data.y           = repmat(nan,[1 nt]); % 4
      D.data.lon         = repmat(nan,[1 nt]); % 5
      D.data.lat         = repmat(nan,[1 nt]); % 6
      D.data.epsg        = repmat(nan,[1 nt]); % 7
      % pre-allocate any extra vector !!!

      nt              = 0; % number of time per location
      nloc            = 1;
      first           = 1;
      currentlocation = '';
      
      %% Read data from file
      %% ----------------------------------------

      fid = fopen(fname,'r');
   
      for ii=1:OPT.headerlines
         D.header{ii} = fgetl(fid); % read one record
      end
   
      while 1
      
          rec = fgetl(fid); % read one record
          if ~ischar(rec) | isempty(rec) %%%-%%% | nt==10
             break
          else
          
             %Waarnemingssoort: Debiet in m3/s in oppervlaktewater
             %Alle tijdsaanduidingen zijn in GMT+1 (MET)
             %Coordinaatweergave is x,y in EPSG 7415 (RD) en als lat/long in EPSG 4230 (ED50)
             %De afkorting NVT betekent: "Niet van toepassing"
             %locatie        ;waarnemingssoort                  ;datum     ;tijd ;bepalingsgrenscode;waarde;eenheid;hoedanigheid;anamet                                        ;ogi      ;vat;bemhgt;refvlk;EPSG;x/lat ;y/long;orgaan;biotaxon (cijfercode,biotaxon omschrijving,biotaxon Nederlandse naam)
             %Hagestein boven;Debiet in m3/s in oppervlaktewater;1989-01-01;00:00;                  ;567   ;m3/s   ;NVT         ;Debiet uit afvoerkromme (Q/H- of Q/HH-relatie);Nationaal;NVT;NVT   ;NVT   ;7415;137740;444640;NVT   ;NVT,NVT,Niet van toepassing
             %Hagestein boven;Debiet in m3/s in oppervlaktewater;1989-01-02;00:00;                  ;530   ;m3/s   ;NVT         ;Debiet uit afvoerkromme (Q/H- of Q/HH-relatie);Nationaal;NVT;NVT   ;NVT   ;7415;137740;444640;NVT   ;NVT,NVT,Niet van toepassing       
             %...
             
             nt  = nt + 1;
             
             if nt > OPT.ntmax
                break
             else
                if OPT.display && (mod(nt,OPT.displayskip)==0)
                   disp(num2str(nt,'%0.10d'));
                end
             end
             
             dlm = strfind(rec,';');
             
             if nt==1
             D(nloc).meta1.location               =         rec(1        :dlm( 1)-1);
             D(nloc).meta1.waarnemingssoort       =         rec(dlm( 1)+1:dlm( 2)-1);
             D(nloc).meta1.datum                  =         rec(dlm( 2)+1:dlm( 3)-1);
             D(nloc).meta1.tijd                   =         rec(dlm( 3)+1:dlm( 4)-1);
             D(nloc).meta1.bepalingsgrenscode     =         rec(dlm( 4)+1:dlm( 5)-1);
             D(nloc).meta1.waarde                 =         rec(dlm( 5)+1:dlm( 6)-1);
             D(nloc).meta1.units                  =         rec(dlm( 6)+1:dlm( 7)-1);
             D(nloc).meta1.what                   =         rec(dlm( 7)+1:dlm( 8)-1);
             D(nloc).meta1.anamet                 =         rec(dlm( 8)+1:dlm( 9)-1);
             D(nloc).meta1.ogi                    =         rec(dlm( 9)+1:dlm(10)-1);
             D(nloc).meta1.vat                    =         rec(dlm(10)+1:dlm(11)-1);
             D(nloc).meta1.bemhgt                 =         rec(dlm(11)+1:dlm(12)-1);
             D(nloc).meta1.refvlk                 =         rec(dlm(12)+1:dlm(13)-1);
             else
                location                          =         rec(1        :dlm( 1)-1);
                if ~strcmpi(D(nloc).meta1.location,location)
                   error('More than one location in file, only one is allowed with method fgetl')
                end
             end         
   
             D(nloc).data.epsg               (nt) = str2num(rec(dlm(13)+1:dlm(14)-1)); % 7
             D(nloc).data.x                  (nt) = str2num(rec(dlm(14)+1:dlm(15)-1)); % 3
             D(nloc).data.y                  (nt) = str2num(rec(dlm(15)+1:dlm(16)-1)); % 4
   
             if nt==1
             D(nloc).meta1.orgaan                 =         rec(dlm(16)+1:dlm(17)-1);
             D(nloc).meta1.biotaxon               =         rec(dlm(17)+1:end      );
             end
             
             D(nloc).data.(OPT.value)(nt) = str2double(rec(dlm(5)+1:dlm(6)-1)); % 2
             
             datestring          = rec(dlm(2)+1:dlm(3)-1);
             timestring          = rec(dlm(3)+1:dlm(4)-1);
              
             yyyy                = str2double(datestring( 1: 4));
             mm                  = str2double(datestring( 6: 7));
             dd                  = str2double(datestring( 9:10));
             HH                  = str2double(timestring( 1: 2));
             MI                  = str2double(timestring( 4: 5));
             
             D(nloc).data.datenum(nt) = datenum(yyyy,mm,dd,HH,MI,0); % 1
   
          end
          
      end % while
      
             
      %% Get uniform co-ordinates (lat,lon)
      %% ------------------------

         D(nloc).data.lon = repmat(nan,size(D(nloc).data.x)); % 5
         D(nloc).data.lat = repmat(nan,size(D(nloc).data.x)); % 6
      
                          geomask.ed50   =         D(nloc).data.epsg==4230;
         D(nloc).data.lon(geomask.ed50)  =         D(nloc).data.x(geomask.ed50);
         D(nloc).data.lat(geomask.ed50)  =         D(nloc).data.y(geomask.ed50);

                          geomask.ll     =         D(nloc).data.epsg==4326;
         D(nloc).data.lon(geomask.ll )   =         D(nloc).data.x(geomask.ll );
         D(nloc).data.lat(geomask.ll )   =         D(nloc).data.y(geomask.ll );

      if OPT.ctransdv
      
                          geomask.par    =         D(nloc).data.epsg==7415;
        [D(nloc).data.lon(geomask.par),...
         D(nloc).data.lat(geomask.par)]  =ctransdv(D(nloc).data.x(geomask.par),...
                                                   D(nloc).data.y(geomask.par),'par','ll');

                          geomask.unknow = ~(geomask.ed50 | geomask.par | geomask.ll);
      else
         % try different mapping toolbox, m_map, or matlab mapping toolbox or upcoming supertrans
      end      
      
      %% Remove too much pre-allocated data,
      %% even when OPT.preallocate, because
      %% the fast scanning also counted the number of header lines.
      %% ----------------------------------
      
      D.data.datenum     = D.data.datenum    (1:nt); % 1
      D.data.(OPT.value) = D.data.(OPT.value)(1:nt); % 2
      D.data.x           = D.data.x          (1:nt); % 3
      D.data.y           = D.data.y          (1:nt); % 4
      D.data.epsg        = D.data.epsg       (1:nt); % 5
      D.data.lon         = D.data.epsg       (1:nt); % 6
      D.data.lat         = D.data.epsg       (1:nt); % 7
      
      D.locations{1} = D(nloc).meta1.location;
   
      fclose(fid);
      
   else
      error(['method unknown, only fgetl and textread allowed: ',OPT.method])
   end % OPT.method

   %% apply scales to get rid of STUPID non-SI units of Rijkswaterstaat
   %% ------------------
   
   for idat = 1:length(D.data)
      D.data(idat).(OPT.value) = D.data(idat).(OPT.value)./OPT.valuescale;
   end
   
   if isfield(D,'x')
   %  D.data.x = str2double(char(D.data.x))./OPT.xscale;
      D.data.x = D.data.x./OPT.xscale;
   end   
   
   if isfield(D,'y')
   %  D.data.y = str2double(char(D.data.y))./OPT.yscale;
      D.data.y = D.data.y./OPT.yscale;
   end   
   
   %% In case of more files, copy to multiple-file structure
   %% ------------------

   if length(D.locations)==1
   
      %if ~(length(D.locations)==1)
      %   error('With MULTIPLE file names only ONE station per file is allowed.')
      %end
   
         %% Extract meta-information
         %% -----------------
         DS.name     {ifile} = D.name ;
         DS.date     {ifile} = D.date ;
         DS.bytes    (ifile) = D.bytes;
         DS.isdir    (ifile) = D.isdir;
         DS.datenum  {ifile} = D.data.datenum;
         DS.locations{ifile} = D.locations{1}; %D.data.location;
         
         %% Copy location code (as obtained from file name)
         %% -----------------
         if OPT.locationcode
         
            index            = strfind(fname,'-');
            locationcode     = lower(fname([index(1)+1]:[index(2)-1]));
         
            if length(D.locations)==1
            D.data.location          = D.locations{1};
            D.data.locationcode      = locationcode;
            DS.locationcodes{ifile}  = locationcode;
            else
               error('With MULTIPLE file names only ONE station per file is allowed.')
            end
         end

         %% Copy data
         %% -----------------
         DS.data(ifile) = D.data;
         
      disp(['donar_read: read file ',num2str(ifile),' of ',num2str(length(fnames))])
   
   end % D.locations==1
   
end % for ifile=1:length(fnames)

%% Output
%% -----------------

   if length(fnames) >1
      varargout = {DS};
   else      
      varargout = {D};
   end
   
%% EOF