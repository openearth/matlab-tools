function varargout = vs_trih_station(trih,varargin)
%VS_TRIH_STATION   get [x,y,m,n,name] information of history stations (obs point)
%
% ST = VS_TRIH_STATION(trih,<station_id>)
%
% where trih = VS_USE(...) and ST is a struct with fields:
%    - m
%    - n
%    - x
%    - y
%    - index
%    - name
% 
% where station_id can be :
%    - the index(es) in the trih file 
%    - station name(s) as a multidimensional characters array.
%      where stations are counted in the first dimension.
%    - a cell array of station name(s)
%    - absent or empty to load all stations
% 
% Examples: 
%
%   ST = VS_TRIH_STATION(trih);
%   ST = VS_TRIH_STATION(trih,{'coast05','coast06'});
%   ST = VS_TRIH_STATION(trih,['coast05';'coast06']);
%   ST = VS_TRIH_STATION(trih,[10 11]);
%
% [ST,iostat] = vs_trih_station(trih,station_id)
% returns iostat=1 when succesfull, and iostat=-1 when failed.
% When iostat is not asked for, and it fails, error is called.
% This happens when the station name is not present.
%
% See also: VS_USE, VS_LET, STATION, VS_TRIH_STATION_INDEX

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

   iostat =  1;
   
   %% Input
   %% ------------------------------

   if nargin==1
      station_id = [];
   else
      station_id = varargin{1};
   end
   
   %% Get names from indices or vv.
   %% ------------------------------

   if iscell(station_id)
      station_id = char(station_id);
   end
   
   if ischar(station_id)
   
      ST.name  = station_id;
      ST.index = vs_trih_station_index(trih,station_id,'strcmp'); % Only one station with exact name match, with multiple stations this function fails.
      
   elseif isempty(station_id) % BEFORE isnumeric because [] is also numeric!!!
   
      ST.index = 1:vs_get_elm_size(trih,'NAMST'); % get all stations
      ST.name  = permute(vs_let(trih,'his-const','NAMST',{ST.index}),[2 3 1]);
      
   elseif isnumeric(station_id)
   
      ST.index = station_id;
      ST.name  = permute(vs_let(trih,'his-const','NAMST',{ST.index}),[2 3 1]);
      
   end
   
   if ~(length(ST.index)==size(ST.name,1))
      disp (addrowcol(station_id,0,[-1 1],''''))
      disp(['Not all of above stations have match in : ',trih.FileName]);
      iostat = -1;
   end

   %% Get data
   %% ------------------------------

   if iostat==1
   
      if ~(size(ST.index,1)==0)
      
         ST.m         = squeeze(vs_let(trih,'his-const','MNSTAT',{1,ST.index}));
         ST.n         = squeeze(vs_let(trih,'his-const','MNSTAT',{2,ST.index}));
      
         ST.x         = squeeze(vs_let(trih,'his-const','XYSTAT',{1,ST.index}));
         ST.y         = squeeze(vs_let(trih,'his-const','XYSTAT',{2,ST.index}));
         
        %ST.grdang    = squeeze(vs_let(trih,'his-const','GRDANG',{1,ST.index}));
         ST.angle     = squeeze(vs_let(trih,'his-const','ALFAS' ,{  ST.index}));
         ST.angle_explanation = 'orientation (deg) ksi-axis (u velocity) w.r.t. pos. x-axis at water level point';
         
         ST.kmax      = squeeze(vs_let(trih,'his-const','KMAX'));

      else
      
         ST.m      = [];
         ST.n      = [];
      
         ST.x      = [];
         ST.y      = [];
      
         ST.angle  = [];

      end   
      
      ST.FileName        = trih.FileName;
      ST.Description     = 'Delft3d-FLOW monitoring point (*.obs) time serie.';
      ST.extracted_at    = datestr(now,31);
      ST.extracted_with  = 'vs_trih_station.m  of G.J. de Boer (gerben.deboer@wldelft.nl)';
      
   end
   
   %% Output
   %% ------------------------------

   if     nargout==1
     if iostat==1
        varargout = {ST};
     else
        error(' ');
        varargout = {iostat};
     end
   elseif nargout==2
     varargout = {ST,iostat};
   end
   
%% EOF   