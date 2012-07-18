function R = matroos_opendap_maps2series2mn(varargin)
%MATROOS_OPENDAP_MAPS2SERIES2MN  extract series from OPeNDAP maps using meta-data cache (TEST!!!)
%
%   data = matroos_opendap_maps2series2('datenum',<...>,'source',<...>,'m',<...>,'n',<...>)
%
%
% where data contains the data, time and coordinates requested from the OPeNDAP server.
%
% MATROOS_OPENDAP_MAPS2SERIES2MN requests data along grid line with constant m or n 
% from opendap server and save as one continuous polygon with ascii time series at 
% nodes in NOOS of Dflow-FM format.
%
% m and n should be cells, with overlapping end indices, where f can used to 
% indicate that one segmentline has to be treated as reverse, e.g
%   ...,'m',{[4:109],[      4],[4:70]},...
%       'n',{[  122],[122:545],[ 545]},...
%       'f', [-1    , 1       ,    1],..
% will generate a continous polygon connecting the 4 corners
% points at indices (109,122),(4,122),(4,545),(70,545) and all 
% intermediate grid points. The 597 data points can be extracted with
% 3 2D array requests only, therefore MATROOS_OPENDAP_MAPS2SERIES2MN
% is order of magnitude fatser than calling MATROOS_OPENDAP_MAPS2SERIES2
% to extract those data points as 597 1D arrays.
%
% This client side function has similar functionality as the server side
% matroos.deltares.nl/direct/get_map2series.php? functionality. This client
% side function is slower the 1st time because it needs to gather meta-data,
% but it is be much faster any subsequent time because it caches the [m,n] mapping.
%
% For small segments keep on using MATROOS_OPENDAP_MAPS2SERIES2.
%
%See also: MATROOS_OPENDAP_MAPS2SERIES1, MATROOS_OPENDAP_MAPS2SERIES2, nc_harvest, 
%          matroos_get_series, matroos.deltares.nl/direct/get_map2series.php?
%          dflowfm

warning('very preliminary test version')
warning('TO DO: let m and n be only small arrays with corner points indices, and figure out segment-reversion in code')

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
   OPT.datenum  = datenum([2009 2009],[12 12],[1 2]);
   OPT.m        = {[4:109],[      4],[4:70]}; % to main land
   OPT.n        = {[  122],[122:545],[ 545]};
   OPT.f        = [-1,1,1];
   OPT.var      = 'SEP';
   OPT.debug    = 0;
   OPT.path     = '';
   OPT.timrelpath = 'tim';
   OPT.RefDate    = datenum(2009,12,1); % if not 'NOOS' or datenum(), else ISO8601 'yyyy-mm-dd HH:MM:SS'
   OPT.nc         = 1;% store 2D array before splitting into ascii files
   
   OPT = setproperty(OPT,varargin);

%% load cached meta-data from matroos_opendap_maps2series1

   if ~(exist([OPT.source,'.mat'],'file')==2)
      matroos_opendap_maps2series1('source',OPT.source,'basePath',OPT.basePath);
   else
      D = load(OPT.source);
   end

%% process temporal OPeNDAP slice indices

   OPT.t = find(D.datenum >= OPT.datenum(1) & D.datenum <= OPT.datenum(end)); % approximate
   
   if OPT.t(  1) > 1                ;OPT.t = [(OPT.t(1)-1);   OPT.t];end
   if OPT.t(end) < length(D.urlPath);OPT.t = [OPT.t; (OPT.t(end)+1)];end

%% process spatial OPeNDAP slice indices

   R.source   = OPT.source;
   R.basePath = OPT.basePath;

   sz.data = cellfun(@(x,y) max(length(x),length(y)),OPT.m,OPT.n);
   sz.d0   = [0 cumsum(cellfun(@(x,y) max(length(x),length(y)),OPT.m,OPT.n))]+1;sz.d0 = sz.d0(1:end-1);
   sz.d1   = [  cumsum(cellfun(@(x,y) max(length(x),length(y)),OPT.m,OPT.n))];
   R.x     = repmat(nan,[1 sum(sz.data)]);
   R.y     = repmat(nan,[1 sum(sz.data)]);
   R.m     = repmat(nan,[1 sum(sz.data)]);
   R.n     = repmat(nan,[1 sum(sz.data)]);
   R.ind   = repmat(nan,[1 sum(sz.data)]);
   clc
   for j=1:length(OPT.m)
        dx = [];dm = [];
        dy = [];dn = [];
      for jj=1:sz.data(j)
        nr = (sz.d0(j)+jj-1);
        if length(OPT.m{j})==1
           m = OPT.m{j}( 1);n = OPT.n{j}(jj);
        else
           m = OPT.m{j}(jj);n = OPT.n{j}( 1);
        end
        %disp(num2str([nr m n]))
        dx = [dx D.x(m,n)];
        dy = [dy D.y(m,n)];
        dm = [dm m];
        dn = [dn n];
      end
      if OPT.f(j)==-1; 
          dx = dx(end:-1:1);dm = dm(end:-1:1);
          dy = dy(end:-1:1);dn = dn(end:-1:1);
      end
      R.m  (sz.d0(j):sz.d1(j)) = dm;
      R.n  (sz.d0(j):sz.d1(j)) = dn;
      R.x  (sz.d0(j):sz.d1(j)) = dx;
      R.y  (sz.d0(j):sz.d1(j)) = dy;
      R.ind(sz.d0(j):sz.d1(j)) = j;
      
   end

   time = [];
   data = [];
   
%% request 2D data slices alomg constant m or n indices

  [user,passwd]  = matroos_user_password;

tic
for it=1:length(OPT.t)

    disp(['time: ',num2str(it,'%0.4d'),' / ',num2str(length(OPT.t),'%0.4d')])
    [dtime,zone] = nc_cf_time(['https://',user,':',passwd,'@',D.urlPath{OPT.t(it)}(8:end)],'time');
    time  = [time(:)' dtime(:)'];
    ddata = repmat(nan,[sum(sz.data) length(dtime)]);

    for j=1:length(OPT.m)  
    disp(['    locs: ',num2str(j,'%0.4d'),' / ',num2str(length(OPT.m),'%0.4d')])
         m0 = OPT.m{j}(1);
         n0 = OPT.n{j}(1);
         Nm = length(OPT.m{j});
         Nn = length(OPT.n{j});
         %disp([m0 n0 Nn Nm])
         dddata = nc_varget(['https://',user,':',passwd,'@',D.urlPath{OPT.t(it)}(8:end)],OPT.var,[1 m0 n0]-1,[Inf Nm Nn])';
         if OPT.f(j)==-1
         ddata(sz.d0(j):sz.d1(j),:) =  flipud(dddata);
         else
         ddata(sz.d0(j):sz.d1(j),:) =  dddata;
         end
    end
    data = [data ddata];
toc    
end

R.datenum = time;clear time
R.data    = data;clear data

%% name for overall data and extract pivot corner indices

   if OPT.f(1)==-1; 
   mnstr = [num2str(OPT.m{1}(1)) ',' num2str(OPT.n{1}(1))];
   R.mcor = [OPT.m{1}(1)];
   R.ncor = [OPT.n{1}(1)];
   else
   mnstr = [num2str(OPT.m{1}(end)) ',' num2str(OPT.n{1}(end))];
   R.mcor = [OPT.m{1}(end)];
   R.ncor = [OPT.n{1}(end)];
   end
   for j=1:length(OPT.m) 
       if OPT.f(1)==-1; 
       mnstr = [mnstr '_' num2str(OPT.m{j}(end)) ',' num2str(OPT.n{j}(end))];
       R.mcor = [R.mcor OPT.m{j}(end)];
       R.ncor = [R.ncor OPT.n{j}(end)];
       else
       mnstr = [mnstr '_' num2str(OPT.m{j}(1)) ',' num2str(OPT.n{j}(1))];
       R.mcor = [R.mcor OPT.m{j}(1)];
       R.ncor = [R.ncor OPT.n{j}(1)];
       end
   end
   
   R.pathdistance = distance(R.x,R.y);
   
   if ~isempty(OPT.path)
      OPT.path = path2os([OPT.path,filesep]);
   end
   
   if OPT.debug
      save([OPT.path,OPT.source,'_',mnstr,'.mat'],'-struct','R')
   end
   
   if OPT.nc
      struct2nc([OPT.path,OPT.source,'_',mnstr,'.nc'],R)
   end

%% assess 2D polygon-time array

   if OPT.debug
   R = nc2struct([OPT.path,OPT.source,'_',mnstr,'.nc'])
   %%
   close
   it=':';
   pcolorcorcen(R.datenum(it),R.pathdistance,R.data(1:597,it)); %,[.5 .5 .5])
   datetick('x')
   tickmap('y')
   hline(R.pathdistance(find(diff(R.ind))),'k'); % corners
   hline(R.pathdistance(43),'k--') % interface N'Sea and W'zee 
   ylabel('distance along polygon')
   xlabel([datestr(xlim1(1),'yyyy-mmm-dd HH:MM') '  \rightarrow  ', datestr(xlim1(1),'yyyy-mmm-dd HH:MM')])
   print2screensize('matroos_opendap_maps2series3')
   end

%%%%% split 2D array into polygon (*.pli) with ascii time series at corners (*.tim)

   matroos_opendap_maps2series2mn2ascii(R,'filename',[OPT.path,OPT.source,'_',mnstr,'.pli'],...
                                              'path',OPT.path,...
                                        'timrelpath',OPT.timrelpath,...
                                           'RefDate',OPT.RefDate);