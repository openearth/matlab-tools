function indices = vs_get_trih_station_index(trih,varargin)
%VS_GET_TRIH_STATION_INDEX
%
% index = vs_get_trih_station_index(trih,stationname)
%
% returns the index of a station called stationname.
%
% trih can be a struct as loaded by vs_use(...)
% or a NEFIS history file name to be loaded by vs_use
% internally.
%
% Leading and traling blanks of the station name are ignored,
% both in the specified names, as in the names as present
% in the history file.
%
% When the specified name is not found, an empty value 
% (0x0 or 0x1) is returned.	
%
% vs_get_trih_station_index(trih,stationname,method)
% to choose a method:
% - 'strcmp'   gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern 
%              stationname is present (default).
%
% vs_get_trih_station_index(trih) prints a list with all 
% station names and indices on screen with 7 columns:
% index,name,m,n,angle,x,y. 
%
% S = vs_get_trih_station_index(trih) returns a struct S.
%
% Vectorized over 1st dimension of stationname.
%
% See also: VS_USE, VS_LET, STATION, VS_TRIH_STATION
%           VS_TRIH_CROSSSECTION_INDEX

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
%   --------------------------------------------------------------------

if ~isstruct(trih)
   trih = vs_use(trih);
end

   method = 'strcmp';
   method = 'strmatch';

if nargin==1
   method = 'list';
end

if nargin > 1
   stationname = varargin{1};
end   

if nargin > 2
   method = varargin{2};
end   


%% Load all station names
%% ------------------------
namst = squeeze(vs_let(trih(1),'his-const','NAMST'));

nstat = size(namst,1);

%% Cycle all stations and quit immediatlety 
%% when a match has been found
%% ------------------------

switch method

case 'list' %this one should be first in case

   mn  = squeeze(vs_let(trih(1),'his-const','MNSTAT'));
   xy  = squeeze(vs_let(trih(1),'his-const','XYSTAT'));
   ang = squeeze(vs_let(trih(1),'his-const','ALFAS'));
   
   if nargout==0

      disp('+------------------------------------------------------------------------->')
      disp(['| ',trih(1).FileName])
      disp('| index         name         m    n     angle  x and y')
      disp('+-----+--------------------+-----+-----+-----+---------------------------->')
      
      for istat=1:nstat
      
         disp([' ',...
           pad(num2str(      istat  ) ,-5,' ') ,' ',...
                   pad(namst(istat,:) ,20,' ') ,' ',...
           pad(num2str(mn   (1,istat)),-5,' ') ,' ',...
           pad(num2str(mn   (2,istat)),-5,' ') ,' ',...
           pad(num2str(ang  (istat  ),'%+3.1f'),-5,' ') ,' ',...
           pad(num2str(xy   (1,istat),'%+16.6f'),-14,' '),' ',...
           pad(num2str(xy   (2,istat),'%+16.6f'),-14,' ')]);
      
      end
      
      istat = nan;
      
   elseif nargout==1
   
      indices.namst = namst;
      indices.mn    = mn   ;
      indices.mn    = mn   ;
      indices.ang   = ang  ;
      indices.xy    = xy   ;
      indices.xy    = xy   ;
      
   end


case 'strcmp'

   indices = [];
   
   for istat=1:nstat

      for i=1:size(stationname,1)
   
         if strcmp(deblank2(stationname(i,:)),...
                   deblank2(namst(istat,:)))

            indices = [indices istat];
            
         end
   
      end
   
   end


case 'strmatch'

   indices = [];
   
   for i=1:size(stationname,1)
   
      istat = strmatch(stationname(i,:),namst); % ,'exact'
      
      indices = [indices istat];
      
   end
   
end


 