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
% bbox  = []          get overall bbox from server
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
%See also: arcgis, netcdf, opendap, postgresql
%          http://publicwiki.deltares.nl/display/OET/WMS+primer

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
OPT.bbox            = [];            % check for bounds from getCapabilities
OPT.format          = 'image/png';   % default; from getCapabilities
OPT.crs             = 'EPSG%3A4326'; % OR CRS:84
OPT.width           = 800;           % default, check for max from getCapabilities
OPT.height          = 600;           % default, check for max from getCapabilities
OPT.styles          = '';            % from getCapabilities
OPT.transparent     = 'true';        % needs format image/png, note char format, as num2str(true)=1 and not 'true'
OPT.time            = '';            % from getCapabilities
OPT.swap            = 1;             % has to do with SRS vs. CRS
OPT.flip            = 1;             % has to do with SRS vs. CRS
OPT.cachedir        = 'd:\opendap.deltares.nl\wms\'; % store cache of xml (and later png)

warning('Work In Progress')
warning('Deal with CRS:84 vs EPSG:4326: swapping of lot-lat, lat-lon for now captured in keywors swap and flip')

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
   OPT.cachename = [OPT.cachedir,filesep,mkvar(OPT.server(ind0+2:ind1-1))]; % remove ?
   xmlname = [OPT.cachename,'.xml']
   if ~exist(xmlname)
      urlwrite(url0,xmlname);
      urlfile_write([OPT.cachename,'.url'],url0,now);   
   else
      disp(['used WMS cache:',xmlname]); % load last access time too
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
   
   [OPT.layers] = matchset('layers',OPT.layers,lim.layers,OPT.server);
   for ilayer=1:length(xml.Capability.Layer.Layer)
      if isfield(xml.Capability.Layer.Layer(i),'Layer')       
         for jlayer=1:length(xml.Capability.Layer.Layer(ilayer).Layer)
            if strcmp(OPT.layers,xml.Capability.Layer.Layer(ilayer).Layer(jlayer).Name)
               Layer = xml.Capability.Layer.Layer(ilayer).Layer(jlayer);
               Layer.index = [ilayer,jlayer];
               continue
            end
         end
      else
         Layer = xml.Capability.Layer.Layer(ilayer);
         Layer.index = [ilayer];
         continue
      end
   end

% check valid format

   lim.format = xml.Capability.Request.GetMap.Format;
   OPT.format = matchset('format',OPT.format,lim.format,OPT.server);
   i = strfind(OPT.format,'/');OPT.ext = ['.',OPT.format(i+1:end)];

% check valid crs: handle symbol ":" inside
% server + layer crs
% DO NOT USE urlencode, as it will double-encode the % from an already encoded url

   if     isfield(xml.Capability.Layer,'CRS')
      crsname = 'CRS';
   elseif isfield(xml.Capability.Layer,'SRS')
      crsname = 'SRS';
   end

   crs0 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(xml.Capability.Layer.(crsname)),'UniformOutput',0);
   if isfield(Layer,crsname)
   crs1 = cellfun(@(x)strrep(x,':','%3A'),ensure_cell(               Layer.(crsname)),'UniformOutput',0);
   else
   crs1 = {};
   end
   lim.crs = {crs0{:},crs1{:}};
   
   OPT.crs = matchset('crs',strrep(OPT.crs,':','%3A'),lim.crs,OPT.server);
   
% check valid bbox:

   if isempty(OPT.bbox)
       
       if isfield(Layer,'EX_GeographicBoundingBox')
       OPT.bbox(2) = str2num(Layer.EX_GeographicBoundingBox.southBoundLatitude); % y0
       OPT.bbox(1) = str2num(Layer.EX_GeographicBoundingBox.westBoundLongitude); % x0
       OPT.bbox(4) = str2num(Layer.EX_GeographicBoundingBox.northBoundLatitude); % y1
       OPT.bbox(3) = str2num(Layer.EX_GeographicBoundingBox.eastBoundLongitude); % x1
       elseif isfield(Layer,'LatLonBoundingBox')
       OPT.bbox(2) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.miny); % y0
       OPT.bbox(1) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.minx); % x0
       OPT.bbox(4) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxy); % y1
       OPT.bbox(3) = str2num(Layer.LatLonBoundingBox.ATTRIBUTE.maxx); % x1
       elseif isfield(Layer,'BoundingBox')

       for ibox=1:length(Layer.BoundingBox) % 1.1.1
       if strcmp(Layer.BoundingBox(ibox).ATTRIBUTE.(crsname),'EPSG:4326')
       OPT.bbox(1) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.minx); % x0
       OPT.bbox(2) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.miny); % y0
       OPT.bbox(3) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxx); % x1
       OPT.bbox(4) = str2num(Layer.BoundingBox(ibox).ATTRIBUTE.maxy); % y1
       end % if        
       end % for
       end

       if OPT.swap
          OPT.bbox = OPT.bbox([2 1 4 3]);
       end
   else
       
   end

% check valid width, height

   if isfield(xml.Service,'MaxWidth'); OPT.width  = min(OPT.width ,str2num(xml.Service.MaxWidth ));end
   if isfield(xml.Service,'MaxHeight');OPT.height = min(OPT.height,str2num(xml.Service.MaxHeight));end

% server + layer styles

   styles0 = {};styles1 = {};
   if isfield(xml.Capability.Layer,'Style');styles0 = {xml.Capability.Layer.Style.Name};end
   if isfield(               Layer,'Style');styles1 = {               Layer.Style.Name};end
   lim.styles = {styles0{:},styles1{:}};   
   OPT.styles = matchset('styles',OPT.styles,lim.styles,OPT.server);
   
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

   if OPT.flip   
   OPT.x = linspace(OPT.bbox(1),OPT.bbox(3),OPT.width);
   OPT.y = linspace(OPT.bbox(4),OPT.bbox(2),OPT.height); % images are generally upside down: pixel(1,1) is upper left corner
   else
   OPT.x = linspace(OPT.bbox(2),OPT.bbox(4),OPT.width);
   OPT.y = linspace(OPT.bbox(3),OPT.bbox(1),OPT.height); % images are generally upside down: pixel(1,1) is upper left corner
   end

% check valid time

%% construct url: standard keywords

   url = [OPT.server,'&service=wms',...
   '&version='    ,         OPT.version,...
   '&request='    ,         OPT.request,...
   '&bbox='       ,nums2str(OPT.bbox,','),...
   '&layers='     ,         OPT.layers,...
   '&format='     ,         OPT.format,...
   '&',crsname,'=',         OPT.crs,... % some require crs, KNMI: srs
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

function [val,i] = matchset(txt,val,set,title)
%MATCHSET validate choice against set, make (menu) choice from valid set

   if ischar(set)
       set = cellstr(set);
   end
           
   if isnumeric(val)
      i = min(val,length(set));
      val  = set{i};
      disp(['wms:selected:  ',txt,'(',num2str(i),')="',val,'"'])
   elseif isempty(val)
       if     isempty(set)  ;i = [];val = [];
       elseif length(set)==1;i =  1;val = set{1};
       else
      [i, ok] = listdlg('ListString', set, .....
                     'SelectionMode', 'single', ...
                      'PromptString',['Select a ',txt,':'], ....
                              'Name',title,...
                          'ListSize', [500, 300]);
       val = set{i};
       end
   else
      i = strmatch(val,set,'exact');
      if isempty(i)
          disp(['wms:not valid: ',txt,'="',val,'"'])
          % throw menu to show options that are available
          [val,i] = matchset(txt,'',set,title);
      else       
          disp(['wms:validated: ',txt,'="',val,'"'])
      end    
   end