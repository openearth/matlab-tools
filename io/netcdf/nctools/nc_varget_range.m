function varargout=nc_varget_range(ncfile,var,lim,varargin)
%NC_VARGET_RANGE  get a monotonous subset based on variable value
%
% NC_VARGET_RANGE find a contigous subset in a coordinate vector
% based on two limits. This speeds up the request of a subset of a long time series.
%
%   D.datenum              = nc_varget_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%  [D.datenum,ind]         = nc_varget_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%  [D.datenum,start,count] = nc_varget_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%
%   D.eta   = nc_varget(ncfile,'eta',[0 ind(1)-1],[1 length(ind)]);
%   D.eta   = nc_varget(ncfile,'eta',[0 start   ],[1 count      ]);
%
% arguments are empty when no data are present in specified window.
%
%See also: nc_varget

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
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
% $Keywords$

OPT.lim       = lim; %[datenum(1950,1,2,2,40,0) datenum(1950,1,2,2,40,0)];
OPT.var       = var;
OPT.chunksize = 1000;
OPT.debug     = 0;

meta  = nc_getdiminfo(ncfile,'time'); % nc_getvarinfo
n1    = meta.Length;
di    = ceil(n1/OPT.chunksize);
chunk = [1:di:n1];

while di > 1
   
   t1      = nc_varget(ncfile,OPT.var,chunk(1)-1,length(chunk),di) + datenum(1970,1,1);
   if ~(all(diff(chunk)==di))
   te      = nc_varget(ncfile,OPT.var,chunk(end)-1,1) + datenum(1970,1,1);
   t1(end) = te;
   end
   if OPT.debug
   [num2str([1:length(t1)]','%0.2d.') datestr(t1)]
   end
   ind1   = find(t1 >= OPT.lim(1));
   ind2   = find(t1 <= OPT.lim(2));
   if ind2(end) <= ind1(1)
      ind = [ind2(end) ind1(1)]; %when lim is between to points
   else
      ind = intersect(ind1,ind2);
   end
   if ~(ind(1)==1)
   ind = [ind(1)-1 ind(:)']';
   end
   if ~(ind(end)==length(t1));
   ind = [ind(:)' ind(end)+1]';
   end

   n1    = range(chunk(ind));
   di    = max(min(floor(n1/OPT.chunksize),di-1),1); % always reduce di, initially n1/OPT.chunksize, finally di-1, but never < 1
   top   = chunk(ind(end));
   chunk = [chunk(ind(1)):di:top];
   if ~(chunk(end)==top)
   chunk = [chunk top];
   end
   
   if any(diff(chunk)<0)
      error([OPT.var,' is not monotonously increasing.'])
   end
   
end

t = nc_varget(ncfile,OPT.var,chunk(1)-1,length(chunk),di) + datenum(1970,1,1);

ind1   = find(t >= OPT.lim(1));
ind2   = find(t <= OPT.lim(2));
ind = intersect(ind1,ind2);

if isempty(ind)
   t     = [];
   chunk = [];
   start = [];
   count = [];
else
   t     = t(ind);
   chunk = chunk(ind);
   start = chunk(1)-1;
   count = length(chunk);
end


if     nargout==1
   varargout = {t};
elseif nargout==2
   varargout = {t,chunk};
elseif nargout==3
   varargout = {t,start,count};
end