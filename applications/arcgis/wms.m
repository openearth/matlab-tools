function varargout = wms(varargin)
%WMS construct and validate OGC WMS request from Web Mapping Service server
%
%  [url,OPT,lims] = wms_validate(<keyword,value>)
%
% constructs wms url from user-keywords and getcapabilities 
% meta-data. Validates the user-paramaters and fills empty 
% keywords in with first valid value from getcapabilities
% or throws pop-up neu with available options.
% Retruns list with available options. Returns valid url and
% valid parameters. OPT contains the vectors x and y to be used
% for georeferencing the WMS image with the requested bounding box.
%
% layers= 1 / n / ''  get 1st / nth layer from server / show drop-down menu
% format= 1 / n / ''  get 1st / nth layer from server / show drop-down menu
% style = 1 / n / ''  get 1st / nth style from server / show drop-down menu
% axis  = []          get overall axis from server [minlon minlat maxlon maxlat] (not always ame as bbox)
%
% Example:
%
%   [url,OPT] = wms_validate('server','http://opendap.deltares.nl/thredds/wms/opendap/test/vaklodingenKB121_2120wms.nc?');
%   urlwrite(url,['tmp',OPT.ext]);
%   [A,map,alpha] = imread(['tmp',OPT.ext]);
%  %[A,map,OPT] = imread(url); or read direct from www, but better keep local cache
%   image(OPT.x,OPT.y,A)
%   colormap(map)
%   tickmap('ll');grid on;
%   set(gca,'ydir','normal')
%
% Note: some WMS servers swap [lat,lon] in the bbox @ version 1.3.0 & crs=epsg:4326
%
%See also: WMS_IMAGE_PLOT, arcgis, netcdf, opendap, postgresql
%          KMLimage (wrap WMS in KML)
%          http://publicwiki.deltares.nl/display/OET/WMS+primer
%          https://pypi.python.org/pypi/OWSLib
%          http://nbviewer.ipython.org/urls/raw.github.com/Unidata/tds-python-workshop/master/wms_sample.ipynb

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares - gerben.deboer@deltares.nl
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

url = '';

% standard
OPT.server          = 'http://www.dummy.yz';
OPT.service         = 'WMS';
OPT.version         = '1.3.0';
OPT.request         = 'GetMap';
OPT.layers          = '';            % from getCapabilities
OPT.axis            = [];            % check for bounds from getCapabilities
OPT.bbox            = '';            % check order for lat-lon vs. lon-lat
OPT.format          = 'image/png';   % default; from getCapabilities
OPT.crs             = 'EPSG%3A4326'; % http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/
OPT.width           = 800;           % default, check for max from getCapabilities
OPT.height          = 600;           % default, check for max from getCapabilities
OPT.styles          = '';            % from getCapabilities
OPT.transparent     = 'true';        % needs format image/png, note char format, as num2str(true)=1 and not 'true'
OPT.time            = '';            % from getCapabilities

OPT.disp            = 0;             % write screen logs
OPT.cachedir        = [tempdir,'matlab.wms',filesep]; % store cache of xml (and later png)

% non-standard
OPT.colorscalerange = [];

if nargin==0
    varargout = {[OPT]};
    return
end

OPT = setproperty(OPT,varargin);

%% get_capabilities

   ind0 = strfind(OPT.server,'//'); % remove http:// or https://
   ind1 = strfind(OPT.server,'?'); % cleanup
   url0  = [OPT.server(1:ind1),'service=WMS&version=1.3.0&request=GetCapabilities']; % http://wms.agiv.be/ogc/wms/omkl? crashes on twice occurcne of service=wms
   if ~exist(OPT.cachedir);mkdir(OPT.cachedir);end
   OPT.cachename = [OPT.cachedir,filesep,mkvar(OPT.server(ind0+2:ind1-1))]; % remove ?
   xmlname = [OPT.cachename,'.xml'];
   if ~exist(xmlname)
      urlwrite(url0,xmlname);
      urlfile_write([OPT.cachename,'.url'],url0,now);   
   else
      if OPT.disp;disp(['used WMS cache:',xmlname]);end % load last access time too
   end
   xml   = xml_read(xmlname,struct('Str2Num',0)); % prevent parsing of 1.1.1 or 1.3.0 to numbers

%% check available WMS version

   if strcmpi(xml.ATTRIBUTE.version,'1.3.0')
      OPT.version = '1.3.0';
   elseif strcmpi(xml.ATTRIBUTE.version,'1.1.1')
      OPT.version = '1.1.1';
   else
       error('WMS not 1.1.1 or 1.3.0')
   end

%% check valid layers and get layer index into getcapabilities

   lim.layers = {};
   for i=1:length(xml.Capability.Layer.Layer)
      if isfield(xml.Capability.Layer.Layer(i),'Layer')
         for j=1:length(xml.Capability.Layer.Layer(i).Layer)
         lim.layers{end+1} = xml.Capability.Layer.Layer(i).Layer(j).Name;
         end
      else
         lim.layers{end+1} = xml.Capability.Layer.Layer(i).Name;
      end
   end

   [OPT.layers] = matchset('layers',OPT.layers,lim.layers,OPT);
   for ilayer=1:length(xml.Capability.Layer.Layer)
      if isfield(xml.Capability.Layer.Layer(i),'Layer')       
         for jlayer=1:length(xml.Capability.Layer.Layer(ilayer).Layer)
            if strcmpi(OPT.layers,xml.Capability.Layer.Layer(ilayer).Layer(jlayer).Name)
               Layer = xml.Capability.Layer.Layer(ilayer).Layer(jlayer);
               Layer.index = [ilayer,jlayer];
               continue
            end
         end
      else
         if strcmpi(OPT.layers,xml.Capability.Layer.Layer(ilayer).Name)
            Layer = xml.Capability.Layer.Layer(ilayer);
            Layer.index = [ilayer];
            continue
         end
      end
   end

% check valid format

   lim.format = xml.Capability.Request.GetMap.Format;
   OPT.format = matchset('format',OPT.format,lim.format,OPT);
   i = strfind(OPT.format,'/');OPT.ext = ['.',OPT.format(i+1:end)];

% check valid crs: handle symbol ":" inside
% server + layer crs
% DO NOT USE urlencode, as it will double-encode the % from an already encoded url

   if     isfield(xml.Capability.Layer,'CRS')
      OPT.crsname = 'CRS';
   elseif isfield(xml.Capability.Layer,'SRS')
      OPT.crsname = 'SRS';
   end

   crs0 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(xml.Capability.Layer.(OPT.crsname)),'UniformOutput',0);
   if isfield(Layer,OPT.crsname)
   crs1 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(               Layer.(OPT.crsname)),'UniformOutput',0);
   else
   crs1 = {};
   end
   lim.crs = {crs0{:},crs1{:}};
   
   OPT.crs = matchset('crs',strrep(OPT.crs,':','%3A'),lim.crs,OPT);
   
% check valid axis (not yet bbox):

   if isempty(OPT.bbox)
       if isfield(Layer,'EX_GeographicBoundingBox') & strcmpi(OPT.version,'1.3.0') % 1.3.0
          disp([OPT.version,' ', OPT.crs,' ','EX_GeographicBoundingBox']);
           OPT.axis(1) = str2num(Layer.EX_GeographicBoundingBox.westBoundLongitude);
           OPT.axis(2) = str2num(Layer.EX_GeographicBoundingBox.southBoundLatitude);
           OPT.axis(3) = str2num(Layer.EX_GeographicBoundingBox.eastBoundLongitude);
           OPT.axis(4) = str2num(Layer.EX_GeographicBoundingBox.northBoundLatitude);
       elseif isfield(Layer,'LatLonBoundingBox') & strcmpi(OPT.version,'1.1.1') % 1.1.1
          disp([OPT.version,' ', OPT.crs,' ','LatLonBoundingBox']);
           OPT.axis(1) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.minx);
           OPT.axis(2) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.miny);
           OPT.axis(3) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxx);
           OPT.axis(4) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxy);
       elseif isfield(Layer,'BoundingBox')
         for ibox=1:length(Layer.BoundingBox)
           if strcmpi(Layer.BoundingBox(ibox).ATTRIBUTE.(OPT.crsname),'EPSG:4326')
               OPT.axis(1) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.minx); % x0
               OPT.axis(2) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.miny); % y0
               OPT.axis(3) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxx); % x1
               OPT.axis(4) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxy); % y1
           elseif strcmpi(Layer.BoundingBox(ibox).ATTRIBUTE.(OPT.crsname),'CRS:84')
               OPT.axis(1) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.minx); % x0
               OPT.axis(2) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.miny); % y0
               OPT.axis(3) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxx); % x1
               OPT.axis(4) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxy); % y1
           end % if        
         end % for
       end
   end

% check valid bbox (handle lon-lat vs. lat-lon:
% http://viswaug.wordpress.com/2009/03/15/reversed-co-ordinate-axis-order-for-epsg4326-vs-crs84-when-requesting-wms-130-images/
% http://www.resc.rdg.ac.uk/trac/ncWMS/wiki/FrequentlyAskedQuestions#MyWMSclientuseslatitude-longitudeaxisorder
%
% Spec for 1.3.0:
% SRS=CRS:84&BBOX=min_lon,min_lat,max_lon,max_lat
% or
% SRS=EPSG:4326&=min_lat,min_lon,max_lat,max_lon <<<<<<<<<<<<<<<< THREDDS ncWMS DOES NOT DO THIS
% Spec for 1.1.1:
% SRS=EPSG:4326&BBOX=min_lon,min_lat,max_lon,max_lat 

% THREDDS DOES NOT OBEY THIS FOR 4326 !!!

   if     strcmpi(OPT.version,'1.3.0') & strcmpi(strrep(OPT.crs,':','%3A'),'EPSG%3A4326')
       % [min_lat,min_lon,max_lat,max_lon]  % reversed
       OPT.bbox  = nums2str(OPT.axis([2,1,4,3]),',');
       warning('crs=CRS:84 to be used instead of crs=EPSG:4326 to prevent mixing-up lat-lon in THREDDS')
   else
       % [min_lon,min_lat,max_lon,max_lat]
       % [minx   ,miny   ,maxx   ,maxy   ]
       OPT.bbox  = nums2str(OPT.axis,',');       
   end   

% check valid width, height

   if isfield(xml.Service,'MaxWidth'); OPT.width  = min(OPT.width ,str2num(xml.Service.MaxWidth ));end
   if isfield(xml.Service,'MaxHeight');OPT.height = min(OPT.height,str2num(xml.Service.MaxHeight));end

% server + layer styles

   styles0 = {};styles1 = {};
   if isfield(xml.Capability.Layer,'Style');styles0 = {xml.Capability.Layer.Style.Name};end
   if isfield(               Layer,'Style');styles1 = {               Layer.Style.Name};end
   lim.styles = {styles0{:},styles1{:}};   
   OPT.styles = matchset('styles',OPT.styles,lim.styles,OPT);
   
% dimensions: time (optional)

   if isfield(Layer,'Dimension')
      for idim=1:length(Layer.Dimension)
      if     strcmpi(Layer.Dimension(idim).ATTRIBUTE.name,'elevation')
      lim.elevation = Layer.Dimension(idim).CONTENT;
      elseif strcmpi(Layer.Dimension(idim).ATTRIBUTE.name,'time')
      
      lim.time = Layer.Dimension(idim).CONTENT;
      
      % OPT.time = matchset(OPT.time)

      %% case list
      % <Dimension name="time" units="ISO8601" multipleValues="true" current="true" default="2012-01-01T00:00:00.000Z">
      % 1926-01-01T00:00:00.000Z,1948-01-01T00:00:00.000Z,1971-01-01T00:00:00.000Z,1981-01-01T00:00:00.000Z,1986-01-01T00:00:00.000Z,1987-01-01T00:00:00.000Z,1990-01-01T00:00:00.000Z,1991-01-01T00:00:00.000Z,1994-01-01T00:00:00.000Z,1997-01-01T00:00:00.000Z,1999-01-01T00:00:00.000Z,2001-01-01T00:00:00.000Z,2006-01-01T00:00:00.000Z,2009-01-01T00:00:00.000Z,2012-01-01T00:00:00.000Z
      % </Dimension>
      %% case extent
      % <Dimension name="time" units="ISO8601"/>
      % <Extent name="time" default="2013-10-31T17:40:00Z" multipleValues="1" nearestValue="0">2012-12-07T00:00:00Z/2013-10-31T17:40:00Z/PT5M</Extent>

      end
      end
   
   end

% make center pixels

  OPT.x = linspace(OPT.axis(1),OPT.axis(3),OPT.width);
  OPT.y = linspace(OPT.axis(4),OPT.axis(2),OPT.height); % images are generally upside down: pixel(1,1) is upper left corner

% check valid time

%% construct url: standard keywords

   url = [OPT.server,'&service=wms',...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&bbox='       ,         OPT.bbox,...
   '&layers='     ,         OPT.layers,...
   '&format='     ,         OPT.format,...
   '&',OPT.crsname,'=',         OPT.crs,... % some require crs, KNMI: srs
   '&width='      , num2str(OPT.width),...
   '&height='     , num2str(OPT.height),...
   '&transparent=',         OPT.transparent,...
   '&styles='     , OPT.styles];

%% construct url: standard options or non-standard extensions

   if ~isempty(OPT.colorscalerange)
   url = [url, '&colorscalerange=',num2str(OPT.colorscalerange(1)),',',num2str(OPT.colorscalerange(2))];
   end

   if ~isempty(OPT.time)
   url = [url, '&time=',datestr(OPT.time,'YYYY-MM-DDTHH:MM:SS')];
   end
   
   varargout = {url,OPT,lim};
   
function c = ensure_cell(c)

   if ischar(c);c = cellstr(c);end

function [val,i] = matchset(txt,val,set,OPT)
%MATCHSET validate choice against set, make (menu) choice from valid set

   if ischar(set)
       set = cellstr(set);
   end
           
   if isnumeric(val)
      i = min(val,length(set));
      val  = set{i};
      if OPT.disp;disp(['wms:selected:  ',txt,'(',num2str(i),')="',val,'"']);end
   elseif isempty(val)
       
       
       if     isempty(set)  ;i = [];val = [];
       elseif length(set)==1;i =  1;val = set{1};
       else
      [i, ok] = listdlg('ListString', set, .....
                     'SelectionMode', 'single', ...
                      'PromptString',['Select a ',txt,':'], ....
                              'Name',OPT.server,...
                          'ListSize', [500, 300]);
       val = set{i};
       end
   else
      i = strmatch(lower(val),lower(set),'exact');
      if isempty(i)
          warning(['wms:not valid: ',txt,'="',val,'"'])
          % throw menu to show options that are available
          [val,i] = matchset(txt,'',set,OPT);
      else       
          if OPT.disp;disp(['wms:validated: ',txt,'="',val,'"']);end
      end    
   end
     