function indices = vs_trih_station_index(trih,varargin)
%VS_TRIH_STATION_INDEX   Read index of history station (obs point)
%
%   index = vs_trih_station_index(trih,stationname)
%
% returns the index of a station called stationname.
%
% trih can be a struct as loaded by vs_use(...) or a
% NEFIS history file name to be loaded by vs_use internally.
%
% Leading and trailing blanks of the station name are ignored,
% both in the specified names, as in the names as present
% in the history file.
%
% When the specified name is not found, an empty value
% (0x0 or 0x1) is returned.
%
% VS_TRIH_STATION_INDEX(trih,stationname,method)
% to choose a method:
% - 'strcmp'   gives only the 1st exact match.
% - 'strmatch' gives all matches in which the string pattern
%              stationname is present (default).
%
% VS_TRIH_STATION_INDEX(trih) prints a list with all
% station names and indices on screen with 7 columns:
% index,name,m,n,angle,x,y.
%
% S = vs_get_trih_station_index(trih) returns a struct S.
%
% Vectorized over 1st dimension of stationname.
%
% See also: vs_trih2nc, dflowfm.indexHis, adcp_plot
%           VS_USE, VS_LET, STATION, VS_TRIH_STATION, VS_TRIH_CROSSSECTION_INDEX

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% 2009 sep 28: added implementation of WAQ hda files [Yann Friocourt]

if ~isstruct(trih)
   if strcmpi(fileext(trih),'.nc')
   ncfile = trih;
   trih.SubType   = 'netCDF';
   ST.Description = 'DFLOW monitoring point (*.obs) time serie.';
   error('This is a netCDD file: use dflow.indexHis instead')
   else
   trih = vs_use(trih);
   end
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

%% Do we work with a FLOW or WAQ file?

   if strcmp(trih.SubType,'Delft3D-trih')
       OPT.GrpName    = 'his-const';
       OPT.ElmName    = 'NAMST';
       ST.Description = 'Delft3d-FLOW monitoring point (*.obs) time serie.';
   elseif strcmp(trih.SubType,'Delft3D-waq-history')
       OPT.GrpName    = 'DELWAQ_PARAMS';
       OPT.ElmName    = 'LOCATION_NAMES';
       ST.Description = 'Delft3d-WAQ monitoring point (*.obs) time serie.';
   end

%% Load all station names

   namst = squeeze(vs_let(trih(1),OPT.GrpName,OPT.ElmName));
   
   nstat = size(namst,1);

%% Cycle all stations and quit immediatlety
%  when a match has been found

switch method

case 'list' %this one should be first in case

    if strcmp(trih.SubType,'Delft3D-trih')

        mn  = squeeze(vs_let(trih(1),OPT.GrpName,'MNSTAT'));
        xy  = squeeze(vs_let(trih(1),OPT.GrpName,'XYSTAT'));
        ang = squeeze(vs_let(trih(1),OPT.GrpName,'ALFAS'));

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

    end

case 'strcmp'

   indices = [];

   for i=1:size(stationname,1)

      for istat=1:nstat

         if strcmp(strtrim(stationname(i,:)),...
                   strtrim(namst(istat,:)))

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

%% EOF