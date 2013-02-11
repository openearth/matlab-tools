function vs_trih2thalweg(vsfile,varargin)
%vs_trih2thalweg x-sigma plane (cross-section, thalweg) from delft3 history file
%
%  vs_trih2thalweg(vsfile, <keyword,valu,e>)
%
%See also: pcolorcorcen_sigma, vs_use

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id$
%  $Date$
%  $Author$
%  $Revision$
%  $HeadURL$
%  $Keywords: $

OPT.epsg      = 28992; % epsg projection to do interpolation in and plot distances in
OPT.ind       = 28:766; % indices (from *.obs) to interpolate from
OPT.wscale    = 100;   % exageration of vertical velocities in plot
OPT.pause     = 0;
OPT.kml       = 'Thalweg.kml'; % endvertices of thalweg drawn in google earth
OPT.nkml      = 20; % number of subdivisions between kml endvertices
OPT.txtleft   = 'Den Helder';
OPT.txtright  = 'Texel';
OPT.txtebb    = 'EBB to North Sea';
OPT.txtflood  = 'FLOOD to Wadden Sea';
OPT.ulegendx  = 500;
OPT.ulegendz  = -25;
OPT.pngsubdir = 'teso'; % subdir of dir of vsfile
OPT.grd       = 'GRID18102012_1030.grd';

OPT = setproperty(OPT,varargin);

%% get data

   h = vs_use(vsfile);

%% get data
   
   coordinates = permute(vs_let(h,'his-const','COORDINATES'      ,'quiet'),[2 3 1]);
   if any(strfind(lower(coordinates),'cart'))
   D.x    = permute(vs_let(h,'his-const' ,'XYSTAT',{1 OPT.ind}),[3 2 1]);
   D.y    = permute(vs_let(h,'his-const' ,'XYSTAT',{2 OPT.ind}),[3 2 1]);
   [D.lon,D.lat] = convertCoordinates(D.x,D.y,'CS1.code',OPT.epsg,'CS2.code',4326);
   else
   D.lon  = permute(vs_let(h,'his-const' ,'XYSTAT',{1 OPT.ind}),[3 2 1]);
   D.lat  = permute(vs_let(h,'his-const' ,'XYSTAT',{2 OPT.ind}),[3 2 1]);
   [D.x,D.y] = convertCoordinates(D.lon,D.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
   end
   D.thick = vs_let(h,'his-const' ,'THICK');
   D.kmax  = vs_let(h,'his-const' ,'KMAX');
   T.datenum = vs_time(h,0,1);
   
   D.zwl   = permute(vs_let(h,'his-series','ZWL'  ,{OPT.ind}  ),[2 1]);
   D.depth = permute(vs_let(h,'his-const' ,'DPS'  ,{OPT.ind}  ),[2 1]);
   
   D.u     = permute(vs_let(h,'his-series','ZCURU',{OPT.ind 0}),[2 1 3]);
   D.v     = permute(vs_let(h,'his-series','ZCURV',{OPT.ind 0}),[2 1 3]);
   D.w     = permute(vs_let(h,'his-series','ZCURW',{OPT.ind 0}),[2 1 3]);
   
   tmp = vs_get_constituent_index(h);fields = {'u','v','w'};units = {'m/s','m/s','m/s'};legend = {'along channel velocity','cross channel velocity','vertical velocity'};
   if isfield(tmp,'salinity')
   D.salinity     = permute(vs_let(h,'his-series','GRO',{OPT.ind 0 tmp.salinity.index   }),[2 1 3]);
   fields{end+1} = 'salinity';units{end+1} = 'salinity';legend{end+1} = 'psu';
   end
   if isfield(tmp,'temperature')
   D.temperature  = permute(vs_let(h,'his-series','GRO',{OPT.ind 0 tmp.temperature.index}),[2 1 3]);
   fields{end+1} = 'temperature';units{end+1} = 'temperature';legend{end+1} = '\circC';
   end

%% interpolate to ship track, drawn as kml in google earth
%  (idea: use arbcross after connecting dots into small matrix?)

   %L = nc2struct('d:\opendap.deltares.nl\thredds\dodsC\opendap\deltares\landboundaries\northsea.nc','include',{'lon','lat'})
   [T.lat,T.lon] = KML2Coordinates(OPT.kml);   
   
   [T.x,T.y] = convertCoordinates(T.lon,T.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
   [D.PI,D.RI,D.WI] = griddata_near1(D.x,D.y,        T.x,T.y,2);
   T.zwl            = griddata_near2(D.x,D.y,D.zwl  ,T.x,T.y,D.PI,D.WI);
   T.depth          = griddata_near2(D.x,D.y,D.depth,T.x,T.y,D.PI,D.WI);
   for ifld=1:length(fields)
       fld = fields{ifld};
       T.(fld) = repmat(T.zwl.*nan,[D.kmax 1 1 1]);
       for k=1:D.kmax
       T.(fld)(k,:,:) = griddata_near2(D.lon,D.lat,D.(fld)(:,:,k),T.lon,T.lat,D.PI,D.WI);
       end
   end
   [T.sigma,T.sigma_bounds] = d3d_sigma(D.thick);
   T.sigma        = T.sigma-1;
   T.sigma_bounds = T.sigma_bounds-1;
   T.track = distance(T.x,T.y);

%% rotate to cross/along polygon

   fprintf(2,'ERROR: VELOCITIES NEED TO BE ROTATED TO PLAN OF TRACK\n')

%% thalweg plot
   close
   AX = subplot_meshgrid(2,1,.05,.05,[nan .05],nan);axes(AX(1))
   plot(T.track,-T.depth,'linewidth',3,'color',[.6 .3 0]);
   hold on
   colormap(clrmap([1 0 0;.95 .95 .95;0 0 1],18))
   clim([-1.5 1.5])
   xlim([0 T.track(end)])
   ylim([-27 2])
   colorbarwithvtext([OPT.txtebb,' - along channel velocity -',OPT.txtflood],'position',get(AX(2),'position'))
   delete(AX(2))
   tickmap('x','format','%0.1f')
   for it=100:size(T.u,3)
      h1 = pcolorcorcen_sigma(T.track,T.sigma,T.zwl(1,:,it),T.depth, T.u(:,:,it));
      T.S = get(h1,'XData');
      T.Z = get(h1,'YData');
      [~,h2] = contour2(T.S,T.Z,T.v(:,:,it),[-1 -.5 -.2 0 .2 .5 1],'k');
      h3 = plot(T.track,T.zwl(:,:,it),'k');
      h4 = arrow2(T.S,T.Z,T.v(:,:,it),OPT.wscale*T.w(:,:,it),2);
      
      h5 = arrow2(OPT.ulegendx,OPT.ulegendz,1,OPT.wscale*0,2);
      h6 = arrow2(OPT.ulegendx,OPT.ulegendz,0,OPT.wscale*0.01,2);
      text       (OPT.ulegendx,OPT.ulegendz,'1 m/s' ,'vert','top','horizontalalignment','left');
      text       (OPT.ulegendx,OPT.ulegendz,'1 cm/s','vert','top','horizontalalignment','left','verticalalignment','bot','rotation',90);

      text(xlim1(1),ylim1(1),[' \uparrow '  ,OPT.txtleft] ,'rotation',90,'verticalalignment','top')
      text(xlim1(2),ylim1(1),[' \downarrow ',OPT.txtright],'rotation',90,'verticalalignment','bottom')
      grid on
      title(datestr(T.datenum(it),'yyyy-mmm-dd HH:MM'))
      print2screensizeoverwrite([fileparts(vsfile),filesep,OPT.pngsubdir,filesep,filename(vsfile),'_',datestr(T.datenum(it),'yyyy-mmm-dd_HHMM')])
      if OPT.pause
      pausedisp
      end
      delete(h1,h2, h3,h4.head, h4.shaft, h5.head, h5.shaft, h6.head, h6.shaft)
     
   end
      