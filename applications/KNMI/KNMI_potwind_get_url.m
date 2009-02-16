function KNMI_potwind_get_url(basepath)
%KNMI_POTWIND_GET_URL   gets all potwind data from KNMI website
%
%   KNMI_POTWIND_GET_URL(basepath)
%
% downloads all potwind data from KNMI website and stores relative to 'basepath' in:
%
%   .\OpenEarthRawData\KNMI\potwind\cache\
%   .\OpenEarthRawData\KNMI\potwind\raw\
%
%See also: KNMI_POTWIND, KNMI_ETMGEG, KNMI_ETMGEG_GET_URL

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
      error('syntax: KNMI_potwind_get_url(basepath)')
   end

%% Settings
%% --------------------

   DIR.url      =  'http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/'; %datafiles/
   DIR.cache    = [basepath,'\OpenEarthRawData\KNMI\potwind\cache\'];
   DIR.raw      = [basepath,'\OpenEarthRawData\KNMI\potwind\raw\'];
   
   if ~(exist(DIR.cache)==7)
      disp('The following target path ')
      disp(DIR.cache)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkpath(DIR.cache)
   end   
   
   if ~(exist(DIR.raw)==7)
      disp('The following target path ')
      disp(DIR.cache)
      disp('does not exist, create? Press <CTRL> + <C> to quit, <enter> to continue.')
      pause
      mkpath(DIR.raw)
   end   
   
   OPT.download = 1;
   OPT.unzip    = 1;

%% Load website
%% --------------------

   website   = urlread ('http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/');

   
               urlwrite('http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/',...
                        [DIR.cache,'download.html']);

%% Extract names of files to be downloaded from webpage
%% --------------------

   indices   = strfind(website,'"potwind_');
   
   nfile     = 0;
   for index=indices
   
      dindex = strfind(website(index:end),'"')-1;
      
      nfile  = nfile +1;
      
      %% remove "" brackets
      OPT.files{nfile} = website(index+1:index+dindex(2)-1);
   
   end

   nfile = length(OPT.files);
   
%% Download *.zip files
%% --------------------

   if OPT.download
      for ifile=1:nfile
      
         disp(['Downloading: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         
         mkpath([DIR.cache,'/',filepathstr(OPT.files{ifile})])
         
         urlwrite([DIR.url  ,'/',OPT.files{ifile}],... % *.zip
                  [DIR.cache,'/',OPT.files{ifile}]); 
         
      end   
   end

%% Extract *.zip files
%% --------------------

   if OPT.unzip
      
      for ifile=1:nfile
      
         disp(['Unzipping: ',num2str(ifile),'/',num2str(nfile),': ',OPT.files{ifile}]);
         
         unzip   ([DIR.cache,'/',OPT.files{ifile}],... % *.zip
                  [DIR.raw                       ]);
         
      end   
   end

%% EOF
