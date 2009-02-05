function varargout = knmi_etmgeg(varargin)
%KNMI_ETMGEG   Reads KNMI ASCII climate time series
%
% W = knmi_etmgeg(filename) 
%
% reads a wind file from
%    <http://www.knmi.nl/klimatologie/daggegevens/download.cgi>
% into a struct W with the following fields:
%
%   FIELD     LONG_NAME                                        UNITS
%   -------   ----------------------------------------------   ------------------------
%   datenum = matlab datenumber
%   STN     = WMO-number       .                               (235=De Kooy,240=Schiphol,260=De Bilt,270=Leeuwarden,280=Eelde,290=Twenthe,310=Vlissingen,344=Rotterdam,370=Eindhoven,380=Maastricht)
%   DDVEC   = prevailing wind direction in degrees             (360=North, 180=South, 270=West, 0=calm/variable)
%   FG      = daily mean windspeed                             [m/s] (let op! inhomogene reeks door meethoogte wijzigingen /
%   FHX     = maximum hourly mean windspeed                    [m/s]
%   FX      = maximum wind gust                                [m/s]
%   TG      = daily mean temperature                           [deg Celsius]
%   TN      = minimum temperature                              [deg Celsius]
%   TX      = maximum temperature                              [deg Celsius]
%   SQ      = sunshine duration                                [hour] (NaN for <0.05 hour)
%   SP      = percentage of maximum possible sunshine duration [%]
%   DR      = precipitation duration                           [hour]
%   RH      = daily precipitation amount                       [mm]   (NaN for <0,05 mm)
%   PG      = daily mean surface air pressure                  [0,1 hPa]
%   VVN     = minimum visibility                               (0=less than 100m, 1=100-200m, 2=200-300m,..., 49=4900-500m, 50=5-6km, 56=6-7km, 57=7-8km,..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=more than 70km)
%   NG      = cloud cover                                      [octants] (9=sky invisible)
%   UG      = daily mean relative atmospheric humidity         [%]
%
% [W,iostat] = knmi_etmgeg(filename) 
%
% returns error status in iostat
%
% OK/cancel/file not found/
%
% W = knmi_etmgeg(filename,<keyword,value>) 
%
% where the following optional <keyword,value> pairs are implemented:
% (see: http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
% * debug    : debug or not (default 0
%
% Missing data are fuilled in with NaN.
%
% NOTE THAT THE VALUES FROM THE FILE HAVE BEEN MULTIPLIED WITH A FACTOR TO GET SI-UNITS.
%
% See also: KNMI_POTWIND

% uses <sortfieldnames>   (optional)

mfile_version = 0.0;

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
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

   %% 0 - command line file name or 
   %%     Launch file open GUI
   %% ------------------------------------------

   %% No file name specified if even number of arguments
   %% i.e. 2 or 4 input parameters
   % -----------------------------
   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'etmgeg*.*' ,'KNMI climate time series (etmgeg*.*)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'KNMI climate time series (etmgeg*.*)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         W.filename     = [];
         iostat         = 0;
      else
         W.filename     = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(W.filename)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

   %% No file name specified if odd number of arguments
   % -----------------------------
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      W.filename   = varargin{1};
      iostat       = 1;
   end
   
   %% Keywords
   %% -----------------

      OPT.debug         = 0;
      OPT.header.n      = 27;
      OPT.header.offset = 6;

      if nargin>2
         if isstruct(varargin{2})
            H = mergestructs(H,varargin{2});
         else
            iargin = 2;
            %% remaining number of arguments is always even now
            while iargin<=nargin-1,
                switch lower ( varargin{iargin})
                % all keywords lower case
                case 'debug'    ;iargin=iargin+1;OPT.debug     = varargin{iargin};
                otherwise
                  error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
                end
                iargin=iargin+1;
            end
         end  
      end
   
   
   %% I - Check if file exists (actually redundant after file GUI)
   %% ------------------------------------------

   tmp = dir(W.filename);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',W.filename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      W.filedate     = tmp.date;
      W.filebytes    = tmp.bytes;

      %% Read header
      %% ----------------------------
         fid             = fopen(W.filename);
         for iline = 1:(OPT.header.n)
            W.comments{iline} = fgetl(fid);
         end
      
      %% Extract meta-info from header
      %% ----------------------------
      
         W.parameter_names          = {'STN','YYYYMMDD','DDVEC','FG','FHX','FX','TG','TN','TX','SQ','SP','DR','RH','PG','VVN','NG','UG'};
         W.parameter_names          = {'STN','YYYYMMDD','DDVEC','FG','FHX','FX','TG','TN','TX','SQ','SP','DR','RH','PG','VVN','NG','UG'};
         
         W.parameter_long_name { 1} =  'STN      = WMO-number';
         W.parameter_long_name { 2} =  'YYYYMMDD = date';
         W.parameter_long_name { 3} =  'DDVEC    = revailing wind direction in degrees';
         W.parameter_long_name { 4} =  'FG       = daily mean windspeed';
         W.parameter_long_name { 5} =  'FHX      = maximum hourly mean windspeed';
         W.parameter_long_name { 6} =  'FX       = maximum wind gust';
         W.parameter_long_name { 7} =  'TG       = daily mean temperature';
         W.parameter_long_name { 8} =  'TN       = minimum temperature';
         W.parameter_long_name { 9} =  'TX       = maximum temperature';
         W.parameter_long_name {10} =  'SQ       = sunshine duration in hour';
         W.parameter_long_name {11} =  'SP       = percentage of maximum possible sunshine duration';
         W.parameter_long_name {12} =  'DR       = precipitation duration';
         W.parameter_long_name {13} =  'RH       = daily precipitation amount in ';
         W.parameter_long_name {14} =  'PG       = daily mean surface air pressure';
         W.parameter_long_name {15} =  'VVN      = minimum visibility';
         W.parameter_long_name {16} =  'NG       = cloud cover in octants';
         W.parameter_long_name {17} =  'UG       = daily mean relative atmospheric humidity';
         
         W.parameter_lange_naam{ 1} =  'STN      = stationsnummer';
         W.parameter_lange_naam{ 2} =  'YYYYMMDD = datum';
         W.parameter_lange_naam{ 3} =  'DDVEC    = overheersende windrichting';
         W.parameter_lange_naam{ 4} =  'FG       = etmaalgemiddelde windsnelheid';
         W.parameter_lange_naam{ 5} =  'FHX      = hoogste uurgemiddelde windsnelheid';
         W.parameter_lange_naam{ 6} =  'FX       = hoogste windstoot';
         W.parameter_lange_naam{ 7} =  'TG       = etmaalgemiddelde temperatuur';
         W.parameter_lange_naam{ 8} =  'TN       = minimum temperatuur';
         W.parameter_lange_naam{ 9} =  'TX       = maximum temperatuur';
         W.parameter_lange_naam{10} =  'SQ       = zonneschijnduur';
         W.parameter_lange_naam{11} =  'SP       = percentage van de langst mogelijke zonneschijnduur';
         W.parameter_lange_naam{12} =  'DR       = duur van de neerslag';
         W.parameter_lange_naam{13} =  'RH       = etmaalsom van de neerslag';
         W.parameter_lange_naam{14} =  'PG       = etmaalgemiddelde luchtdruk';
         W.parameter_lange_naam{15} =  'VVN      = minimum opgetreden zicht';
         W.parameter_lange_naam{16} =  'NG       = bedekkingsgraad van de bovenlucht';
         W.parameter_lange_naam{17} =  'UG       = etmaalgemiddelde relatieve vochtigheid';

         %-% for icol=1:length(W.parameter_names)
         %-% 
         %-%    index =                strfind(W.comments{icol+OPT.header.offset},'=');
         %-%    W.parameter_long_names{icol} = W.comments{icol+OPT.header.offset}(index+1:1:end);
         %-%    
         %-% end
         
      %% Read legend
      %% ----------------------------

        %W.DD_longname      = 'WIND DIRECTION IN DEGREES NORTH';

         
      %% Read data
      %% ----------------------------
      
%    1        2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17
%  ------------------------------------------------------------------------------------------------------
%  STN,YYYYMMDD,DDVEC,   FG,  FHX,   FX,   TG,   TN,   TX,   SQ,   SP,   DR,   RH,   PG,  VVN,   NG,   UG
%
%  235,20010101,  177,   88,  110,  170,   40,    9,   76,    0,    0,   71,   88, 9944,   22,    8,   93
%  ------------------------------------------------------------------------------------------------------
         
         RAW = textscan(fid,'%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n','delimiter',',');
         
         for icol=1:length(W.parameter_names)
         
            %% use netcdf-CF names here !!!
            
            fldname = W.parameter_names{icol};
            
            W.data.(fldname) = [RAW{icol}];
            
         end
      
         W.data.datenum           = time2datenum(W.data.YYYYMMDD);
         W.data.datenum_units     = 'days since 0 jan 0000 00:00';
         W.data.datenum_long_name = 'day';
         
      
         W.data.STN      = W.data.STN       ; W.parameter_units{ 1} =  '#';
         W.data.YYYYMMDD = W.data.YYYYMMDD  ; W.parameter_units{ 2} =  'YYYYMMDD';
         W.data.DDVEC    = W.data.DDVEC     ; W.parameter_units{ 3} =  'deg';
         W.data.FG       = W.data.FG ./10   ; W.parameter_units{ 4} =  'm/s';
         W.data.FHX      = W.data.FHX./10   ; W.parameter_units{ 5} =  'm/s';
         W.data.FX       = W.data.FX ./10   ; W.parameter_units{ 6} =  'm/s';
         W.data.TG       = W.data.TG ./10   ; W.parameter_units{ 7} =  'deg C';
         W.data.TN       = W.data.TN ./10   ; W.parameter_units{ 8} =  'deg C';
         W.data.TX       = W.data.TX ./10   ; W.parameter_units{ 9} =  'deg C';
         W.data.SQ(W.data.SQ==-1) = nan;
         W.data.SQ       = W.data.SQ ./10   ; W.parameter_units{10} =  'hour';
         W.data.SP       = W.data.SP        ; W.parameter_units{11} =  '%';
         W.data.DR       = W.data.DR ./10   ; W.parameter_units{12} =  'hour';
         W.data.RH(W.data.RH==-1) = nan;
         W.data.RH       = W.data.RH ./10   ; W.parameter_units{13} =  'mm';
         W.data.PG       = W.data.PG        ; W.parameter_units{14} =  '0,1 hPa';
         W.data.VVN      = W.data.VVN       ; W.parameter_units{15} =  '#';
         W.data.NG       = W.data.NG        ; W.parameter_units{16} =  'octants';
         W.data.UG       = W.data.UG        ; W.parameter_units{17} =  '%';
         
         %% Copy explanation to data substruct
         %% -----------------------------
         
         for icol=1:length(W.parameter_names)
         
            %% use netcdf-CF names here !!!
            
            fldname = W.parameter_names{icol};
            
            W.data.([fldname,'_units'    ]) = W.parameter_units    {icol};
            
            index                   = strfind(W.parameter_long_name{icol},'=');
            W.data.([fldname,'_long_name']) = W.parameter_long_name{icol}(index(1)+1:end);
            
         end      
         
         if exist('sortfieldnames')==2
         W.data = sortfieldnames(W.data);
         end

         fclose(fid);
         
   end % if length(tmp)==0
   
   W.iomethod = ['© knmi_etmgeg.m  by G.J. de Boer (Deltares), gerben.deboer@Deltares.nl,',mfile_version]; 
   W.read_at  = datestr(now);
   W.iostatus = iostat;
   
   %% Function output
   %% -----------------------------

   if nargout    < 2
      varargout= {W};
   elseif nargout==2
      varargout= {W, iostat};
   end

%% EOF