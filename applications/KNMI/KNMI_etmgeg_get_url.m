function varargout = knmi_etmgeg_get_url(basepath,varargin)
%KNMI_ETMGEG_GET_URL   gets all etmgeg data from KNMI website
%
%   KNMI_ETMGEG_GET_URL(basepath)
%
% downloads all etmgeg data from KNMI website and stores relative to 'basepath' in:
%
%   .\OpenEarthRawData\KNMI\potwind\cache\
%   .\OpenEarthRawData\KNMI\potwind\raw\
%
%   code long_name             starttime   endtime
%   210  Valkenburg            1951 01 01  present
%   235  De Kooy               1906 01 01  present
%   240  Schiphol              1951 01 01  present
%   242  Vlieland              1985 01 01  present
%   249  Berkhout              1999 03 12  present
%   251  Hoorn (Terschelling)  1994 05 26  present
%   257  Wijk aan Zee          2001 04 30  present
%   260  De Bilt               1901 01 01  present
%   265  Soesterberg           1951 09 10  2008 11 18
%   267  Stavoren              1990 06 18  present
%   269  Lelystad              1990 01 17  present
%   270  Leeuwarden            1951 01 01  present
%   273  Marknesse             1989 01 01  present
%   275  Deelen                1951 01 01  present
%   277  Lauwersoog            1991 03 18  present
%   278  Heino                 1991 01 01  present
%   279  Hoogeveen             1989 09 26  present
%   280  Eelde                 1906 01 01  present
%   283  Hupsel                1989 10 16  present
%   286  Nieuw Beerta          1990 01 17  present
%   290  Twenthe               1951 01 01  present
%   310  Vlissingen            1906 01 01  present
%   319  Westdorpe             1991 06 25  present
%   323  Wilhelminadorp        1989 11 05  present
%   330  Hoek van Holland      1971 01 01  present
%   340  Woensdrecht           1993 04 01  present
%   344  Rotterdam             1956 10 01  present
%   348  Cabauw                1986 03 01  present
%   350  Gilze-Rijen           1951 01 03  present
%   356  Herwijnen             1989 09 26  present
%   370  Eindhoven             1951 01 01  present
%   375  Volkel                1951 03 01  present
%   377  Ell                   1999 05 01  present
%   380  Maastricht            1906 01 01  present
%   391  Arcen                 1990 06 18  present
%
% Implemented <keyword,value> pairs are:
% * download : switch whether to download from url (default 1)
% * unzip    : switch whether to unzip downloaded data (default 1)
% * nc       : switch whether to make netCDF from unzipped data (default 0)
% * opendap  : switch whether to put netCDF files on OPeNDAP server (default 0)
% * url      : base url from where to download (default 
%              http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/)
%
%See also: KNMI_POTWIND, KNMI_ETMGEG, KNMI_POTWIND_GET_URL

% old
%          Station 235 Den Helder (De Kooy)
%          1906 - 1910  1911 - 1920  1921 - 1930  1931 - 1940
%          1941 - 1950  1951 - 1960  1961 - 1970  1971 - 1980
%          1981 - 1990  1991 - 2000  2001 - 2008   
%          Station 240 Amsterdam (Schiphol)
%          1951 - 1960  1961 - 1970  1971 - 1980  1981 - 1990
%          1991 - 2000  2001 - 2008      
%          Station 260 De Bilt
%          1901 - 1910  1911 - 1920  1921 - 1930  1931 - 1940
%          1941 - 1950  1951 - 1960  1961 - 1970  1971 - 1980
%          1981 - 1990  1991 - 2000  2001 - 2008   
%          Station 270 Leeuwarden
%          1951 - 1960  1961 - 1970  1971 - 1980  1981 - 1990
%          1991 - 2000  2001 - 2008      
%          Station 280 Groningen (Eelde)
%          1906 - 1910  1911 - 1920  1921 - 1930  1931 - 1940
%          1941 - 1950  1951 - 1960  1961 - 1970  1971 - 1980
%          1981 - 1990  1991 - 2000  2001 - 2008   
%          Station 290 Twenthe
%          1951 - 1960  1961 - 1970  1971 - 1980  1981 - 1990
%          1991 - 2000  2001 - 2008      
%          Station 310 Vlissingen
%          1906 - 1910  1911 - 1920  1921 - 1930  1931 - 1940
%          1941 - 1950  1951 - 1960  1961 - 1970  1971 - 1980
%          1981 - 1990  1991 - 2000  2001 - 2008   
%          Station 344 Rotterdam
%          1956 - 1960  1961 - 1970  1971 - 1980  1981 - 1990
%          1991 - 2000  2001 - 2008      
%          Station 370 Eindhoven
%          1951 - 1960  1961 - 1970  1971 - 1980  1981 - 1990
%          1991 - 2000  2001 - 2008      
%          Station 380 Maastricht (Beek)
%          1906 - 1910  1911 - 1920  1921 - 1930  1931 - 1940
%          1941 - 1950  1951 - 1960  1961 - 1970  1971 - 1980
%          1981 - 1990  1991 - 2000  2001 - 2008
%
%          Station 235 Den Helder (De Kooy)
%          Station 240 Amsterdam (Schiphol)
%          Station 260 De Bilt
%          Station 270 Leeuwarden
%          Station 280 Groningen (Eelde)
%          Station 290 Twenthe
%          Station 310 Vlissingen
%          Station 344 Rotterdam
%          Station 370 Eindhoven
%          Station 380 Maastricht (Beek)

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G (Gerben).J. de Boer
%
%       gerben.deboer@deltares.nl 
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   if nargin < 1
      error('syntax: KNMI_etmgeg_get_url(basepath)')
   end

%% Set <keyword,value> pairs
% ----------------------

   OPT.debug    = 0; % load local download.html from DIR.cache
   OPT.download = 1;
   OPT.unzip    = 1;
   OPT.nc       = 1;
   OPT.opendap  = 1; 

   OPT = setproperty(OPT,varargin{:});

%% Settings
% ----------------------

   DIR.url      = '"./datafiles3/'; % unique string to recognize datafiles in html page
   DIR.preurl   = 'http://www.knmi.nl/klimatologie//daggegevens/'; % rpefix to relative link in DIR.url
   DIR.cache    = [basepath,filesep,'cache',filesep];
   DIR.raw      = [basepath,filesep,'raw',filesep];

   if ~(exist(DIR.cache)==7)
      disp('The following target path ')
      disp(DIR.cache)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkpath(DIR.cache)
   end   
   
   if ~(exist(DIR.raw)==7)
      disp('The following target path ')
      disp(DIR.raw)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkpath(DIR.raw)
   end   
   
%% Load website
% ----------------------

   if ~(OPT.debug)
   website   = urlread ('http://www.knmi.nl/klimatologie/daggegevens/download.html');
               urlwrite('http://www.knmi.nl/klimatologie/daggegevens/download.html',...
                        [DIR.cache,'download.html']);
   else
   website = urlread(['file:///',DIR.cache,filesep,'download.html']);
   end

%% Extract names of files to be downloaded from webpage
% ----------------------

   indices = strfind(website,DIR.url);
   
   % includes current running year:  jaar.txt
   % includes current running month: maand.txt
   
   nfile     = 0;
   for index=indices
   
      dindex = strfind(website(index:end),'"')-1;
      
      nfile  = nfile +1;
      
      %% mind to leave out "" brackets
      OPT.files{nfile} = [DIR.preurl,website(index+2:index+dindex(2)-1)];
   
   end
   nfile = length(OPT.files);
   
%% Download *.zip files
% ----------------------

   if OPT.download
      for ifile=1:nfile
      
         disp(['Downloading: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         
         urlwrite([OPT.files{ifile}],... % *.zip
                  [DIR.cache,filesep,filenameext(OPT.files{ifile})]); 
         
      end   
   end

%% Extract *.zip files
% ----------------------

   if OPT.unzip
      
      for ifile=1:nfile
      
         if strcmpi(OPT.files{ifile}(end-2:end),'zip')
         disp(['Unzipping: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         
         unzip   ([DIR.cache,filesep,filenameext(OPT.files{ifile})],... % *.zip
                  [DIR.raw                       ]);
         end
      end   
   end
   
%% Transform to *.nc files
% ----------------------

   if OPT.nc
   %knmi_etmgeg2nc_time_direct
   end
   
%% Copy to OPeNDAP server 
% ----------------------

   if OPT.opendap
   end
   
%% Output 
% ----------------------

   if nargout==1
      varargout = {OPT};
   end

%% EOF
