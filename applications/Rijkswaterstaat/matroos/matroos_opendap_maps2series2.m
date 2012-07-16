function [time,value,ind] = matroos_opendap_maps2series2
%MATROOS_OPENDAP_MAPS2SERIES2  extract series from OPeNDAP maps using meta-data cache (TEST!!!)
%
%   [time,value,ind] = matroos_opendap_maps2series2('datenum',<...>,'source',<...>,'x',<...>,'y',<...>)
%
% This client side function has the same functionality as the server side
% matroos.deltares.nl/direct/get_map2series.php? functionality. This client
% side function is slower the 1st time because it needs to gather meta-data,
% but it can be much faster any subsequent time because it can cache some 
% part of the 'state' of the 'request', for instance the [m,n] mappin.
%
%See also: MATROOS_OPENDAP_MAPS2SERIES1, nc_harvest, matroos_get_series, 

warning('very preliminary test version')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012
%       Dr.ir. Gerben J. de Boer, Deltares
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% initialize

   OPT.basePath = 'http://opendap-matroos.deltares.nl/thredds/dodsC/'; % same server as catalog.xml
   OPT.source   = 'hmcn_kustfijn';
   OPT.datenum  = datenum([2010 2010],[11 11],[1 5]);
   OPT.x        = [];
   OPT.y        = [];
   OPT.debug    = 1;
   OPT.Rmax     = 1e3; % max 1 km off by default
   OPT.test     = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/waterbase/sea_surface_height/id1-TEXNZE.nc';
   OPT.test     = 'F:\opendap.deltares.nl\thredds\dodsC\opendap\rijkswaterstaat\waterbase\sea_surface_height\id1-HOEKVHLD.nc';
   
%% load cached meta-data

   if ~(exist([OPT.source,'.mat'],'file')==2)
      matroos_opendap_maps2series1('source',OPT.source,'basePath',OPT.basePath)
   else
      D = load(OPT.source);
   end

if OPT.debug
   [T,TM] = nc2struct(OPT.test);
   [~,T.zone]=udunits2datenum(TM.time.units);
   OPT.x       = T.x;
   OPT.y       = T.y;
end

%% get indices

   [ind.m,ind.n] = xy2mn(D.x,D.y,OPT.x,OPT.y,'Rmax',OPT.Rmax);
   
   if isnan(ind.m)
   error(['Requested location (',num2str(OPT.x),',',num2str(OPT.y),') outside "',OPT.source,'" domain'])
   end
   ind.t = find(D.datenum >= OPT.datenum(1) & D.datenum <= OPT.datenum(end)); % approximate

%% get data
   time  = [];
   value =  [];
  [user,passwd]  = matroos_user_password;
   for j=1:length(ind.t)
     disp([num2str(j,'%0.4d'),' / ',num2str(length(ind.t),'%0.4d')])
    [dtime,zone] = nc_cf_time(['https://',user,':',passwd,'@',D.urlPath{ind.t(j)}(8:end)]);
     time  = [time   dtime];
     value = [value  nc_varget(['https://',user,':',passwd,'@',D.urlPath{ind.t(j)}(8:end)],'SEP',[1 ind.m ind.n]-1,[Inf 1 1])];
   end
  
%% plot test data 

if OPT.debug
   figure
   plot(T.datenum - timezone_code2datenum(T.zone),T.sea_surface_height); % CET
   timeaxis(OPT.datenum)
   hold on
   plot(time  - timezone_code2datenum(zone) ,value,'r'); % GMT
   grid on
   xlabel(['time UTC ',datestr(OPT.datenum(1),'yyyy-dd-mm'),'  \leftrightarrow  ',datestr(OPT.datenum(end),'yyyy-dd-mm')])
   title(['source=',mktex(OPT.source),' x=',num2str(OPT.x),' y=',num2str(OPT.y)])
   
   print2screensize([OPT.source,'_',datestr(OPT.datenum(1),'yyyy-dd-mm'),'_',datestr(OPT.datenum(end),'yyyy-dd-mm'),'_',num2str(OPT.x),'_',num2str(OPT.y)]);
end

