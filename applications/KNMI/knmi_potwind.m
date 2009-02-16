function varargout = knmi_potwind(varargin)
%KNMI_POTWIND   Reads ASCII wind file from KNMI website
%
% W = knmi_potwind(filename) 
%
% reads a wind file from
%    <http://www.knmi.nl/samenw/hydra>
%    <http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/>
% into a struct W with the following fields:
%
%    DD      = wind direction in degrees north
%    QQD     = quality code dd
%    UP      = potential wind speed in m/s
%    QUP     = quality code up
%    DATENUM = matlab datenumber
%
% [W,iostat] = knmi_potwind(filename) 
%
% returns error status in iostat
%
% OK/cancel/file not found/
%
% W = knmi_potwind(filename,<keyword,value>) 
%
% where the following optional <keyword,value> pairs are implemented:
% (see: http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
% * calms    : value of direction when wind speed is approx. 0          (default NaN);
% * variables: value of direction when wind direction is higly variable (default NaN);
%
% * pol2cart:  adds also u and v wind components to speed UP and direction DD
%
% (C) G.J. de Boer, TU Delft, 2005-8
%
% See also: CART2POL, POL2CART, DEGN2DEGUC, DEGUC2DEGN, HMCZ_WIND_READ
%           KNMI_ETMGEG, KNMI_POTWIND_MULTI

% uses <ctransdv>   (optional)
%      time2datenum (OET)
%      deg2rad      (matlab)

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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
%   -------------------------------------------------------------------

mfile_version = ' 28 oct 2008';

      %
      % >   N-360  >
      %    /     \
      % W-270     E-90
      %    \     /
      % <   S-180  <
      %      

% 1 'POTENTIAL WIND STATION  xxx    xxxxxxxxxxxxxxxxxx',                    
% 2 'MOST RECENT COORDINATES  X :     xxxxxx; Y :     xxxxxx',              
% 3 'MEASURED AT xxxxxx METER HEIGHT',                                      
% 4
% 5 'POTENTIAL WIND MEANS: CORRECTED TO THE WIND SPEED AT 10 M HEIGHT OVER',
% 6 'OPEN xxxxx WITH ROUGHNESS LENGTH  xxxx METER',                         
% 7 '',
% 8 'CONSULT THE REPORTS AT THE SITE: http://www.knmi.nl/samenw/hydra',
% 9 'FOR BACKGROUND INFORMATION',
%10 'THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED:',
%11 'ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE',
%12 'KONINKLIJK NEDERLANDS METEOROLOGISCH INSTITUUT',
%13 '',
%14 'VERSION JANUARY 2003',
%15 '',
%16 'TIME IN GMT',
%17 'DD  = WIND DIRECTION IN DEGREES NORTH',
%18 'QQD = QUALITY CODE DD',
%19 'UP  = POTENTIAL WIND SPEED IN M/S',
%20 'QUP = QUALITY CODE UP'
%21 ''
%22 '  DATE,TIME, DD,QDD, UP,QUP'};  % edited UP comment to 1 m/s


   %% 0 - command line file name or 
   %%     Launch file open GUI
   %% ------------------------------------------

   %% No file name specified if even number of arguments
   %% i.e. 2 or 4 input parameters
   % -----------------------------
   if mod(nargin,2)     == 0 
     [shortfilename, pathname, filterindex] = uigetfile( ...
        {'potwind*.*' ,'KNMI wind time-series file (potwind*.*)'; ...
         '*.*'   ,'All Files (*.*)'}, ...
         'KNMI wind time-series file (potwind*.*)');
      
      if ~ischar(shortfilename) % uigetfile cancelled
         w.filename     = [];
         iostat         = 0;
      else
         w.filename     = [pathname, shortfilename];
         iostat         = 1;
      end
      
      if isempty(w.filename)
         iostat = 0;
         varargout= {[], iostat};
         return
      end

   %% No file name specified if odd number of arguments
   % -----------------------------
   
   elseif mod(nargin,2) == 1 % i.e. 3 or 5 input parameters
      w.filename   = varargin{1};
      iostat       = 1;
   end
   
   %% Keywords
   %% -----------------

      H.calms     = nan;
      H.variables = Inf;
      H.pol2cart  = 0;

      if nargin>2
         if isstruct(varargin{2})
            H = mergestructs(H,varargin{2});
         else
            iargin = 2;
            %% remaining number of arguments is always even now
            while iargin<=nargin-1,
                switch lower ( varargin{iargin})
                % all keywords lower case
                case 'calms'    ;iargin=iargin+1;H.calms     = varargin{iargin};
                case 'variables';iargin=iargin+1;H.variables = varargin{iargin};
                case 'pol2cart' ;iargin=iargin+1;H.pol2cart  = varargin{iargin};
                otherwise
                  error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
                end
                iargin=iargin+1;
            end
         end  
      end
   
   
   %% I - Check if file exists (actually redundant after file GUI)
   %% ------------------------------------------

   tmp = dir(w.filename);

   if length(tmp)==0
      
      if nargout==1
         error(['Error finding file: ',w.filename])
      else
         iostat = -1;
      end      
      
   elseif length(tmp)>0

      w.filedate     = tmp.date;
      w.filebytes    = tmp.bytes;

      %% Read header
      %% ----------------------------
         fid             = fopen(w.filename);
         w.comments{1}   = fgetl(fid);
         if isempty(strfind(w.comments{1},'POTENTIAL WIND'))
            error(['incorrect file type: 1st line does not start with ''POTENTIAL WIND'' but with ''',w.comments{1},''''])
         end

         for iline = 2:22
            w.comments{iline} = fgetl(fid);
         end
         fclose(fid);
         
      
      %% Extract meta-info from header
      %% ----------------------------
      
         % POTENTIAL WIND STATION  242    Vlieland          
         % MOST RECENT COORDINATES  X :     123800; Y :     583850
         
         % POTENTIAL WIND STATION  235    De Kooy           
         % MOST RECENT COORDINATES  X :     114254; Y :     549042

         w.stationnumber = strtrim (w.comments{1}(24:28));
         w.stationname   = strtrim (w.comments{1}(29:end));
         
         semicolon       = strfind (w.comments{2},':');
         delimiter       = strfind (w.comments{2},';');
         w.xpar          = str2num (w.comments{2}(semicolon(1)+1:delimiter-1));%str2num(strtrim(line2(30:40)));
         w.ypar          = str2num (w.comments{2}(semicolon(2)+1:end        ));%str2num(strtrim(line2(48:end)));
         if exist('ctransdv')==2
         [w.lon,w.lat]   = ctransdv(w.xpar,w.ypar,'par','ll');
         end
         
         char1           = strfind (w.comments{ 3},'MEASURED AT')+11;
         char2           = strfind (w.comments{ 3},'METER');
         w.height        = str2num (w.comments{3}(char1+1:char2-2));
         
         w.over          =          w.comments{ 6}(7:11);
         char1           = strfind (w.comments{ 6},'LENGTH')+6;
         char2           = strfind (w.comments{ 6},'METER');
         w.roughness     = str2num (w.comments{ 6}(char1+1:char2-2));
         
         w.version       = strtrim (w.comments{14}(10:end));
         
         w.timezone      = strtrim (w.comments{16}(9:end));
      
      %% Read legend
      %% ----------------------------
         w.DD_longname      = 'WIND DIRECTION IN DEGREES NORTH';
         w.QQD_longname     = 'QUALITY CODE DD';
         w.UP_longname      = 'POTENTIAL WIND SPEED IN M/S'; % edited UP comment from 0.1 m/s to 1 m/s
         w.QUP_longname     = 'QUALITY CODE UP';
         w.datenum_longname = 'days since 00:00 Jan 0 0000';
         if H.pol2cart
            w.UX_longname   = 'POTENTIAL WIND SPEED IN M/S WIND IN X-DIRECTION';
            w.UY_longname   = 'POTENTIAL WIND SPEED IN M/S WIND IN Y-DIRECTION';
         end
         
      %% Read data
      %% ----------------------------
         [itdate,hour,w.DD,w.QQD,w.UP,w.QUP] = textread(w.filename,'%n%n%n%n%n%n',...
           'delimiter'  ,',',...
           'emptyvalue' ,NaN,...
           'headerlines',22);
         
         w.UP            = w.UP/10; % to [m/s]
         w.datenum       = time2datenum(itdate) + hour./24; % make matlab days
         
         %% Add u,v
         %% --------------------------------------
         if H.pol2cart
           [w.UX,...
            w.UY] = pol2cart(deg2rad(degn2deguc(w.DD)),...
                                                w.UP);
         end
         
         
         w.UP_units      = 'm/s';
         w.QQD_units     = 'm/s';
         w.DD_units      = '[-1,0,2,3,6,7,100,990]';
         w.QUP_units     = '[-1,0,2,3,6,7,100,990]';      
         w.datenum_units = 'day';

         if H.pol2cart
            w.UX_units = 'm/s';
            w.UY_units = 'm/s';
         end         

      %% Apply masks
      %% ----------------------------
      
         w.UP(w.UP<0)=nan; % -0.1 occurs in station 277 year 1971
      
         w.DD(w.QQD>0)=nan;
         w.DD(w.DD==0)=nan;
         
         % http://www.knmi.nl/samenw/hydra/meta_data/quality.htm
         % Quality codes  	
         % 
         % 
         % -1		 no data	
         % 0		 valid data	
         % 2		 data taken from WIKLI-archives	
         % 3		 wind direction in degrees computed from points of the compass	
         % 6		 added data	
         % 7		 missing data	
         % 100		 suspected data         
         
         w.DD(w.DD==0  ) = H.calms    ; % stil, calm winds, windspeed ~ 0, see below
         w.DD(w.DD==990) = H.variables; % veranderlijk, standard deviation direction > 30 deg, see below
         
         % http://www.knmi.nl/samenw/hydra/meta_data/dir_codes.htm
         % Wind direction codes  	
         %
         % Wind direction is reported in units of 10 degrees, starting from 10 to 360. The wind direction is always an average over the last 10-min preceding the full hour. There are two special codes: 0 and 990.
         % Code 0 applies to calms. You may find records, however, with non-zero wind speed and direction 0 for the following reason. The wind speed at our web site is computed from the hourly averaged wind speed (FH). The wind direction, however, is averaged only over the last ten minutes preceding the full hour. If the wind speed in that period (FF) is zero, then the wind direction will be zero as well. The hourly averaged wind, however, is not necessarily zero.
         % Code 990 applies to variable wind direction. This means that the standard deviation is larger than 30 degrees.         
         
   end % if length(tmp)==0
   
   w.iomethod = ['© knmi_potwind.m  by G.J. de Boer (TU Delft), g.j.deboer@tudelft.nl,',mfile_version]; 
   w.read_at  = datestr(now);
   w.iostatus = iostat;
   
   %% Function output
   %% -----------------------------

   if nargout    < 2
      varargout= {w};
   elseif nargout==2
      varargout= {w, iostat};
   end

%% EOF