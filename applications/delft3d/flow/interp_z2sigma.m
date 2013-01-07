function smatrix = interp_z2sigma(z, zmatrix, sigma, eta, depth, varargin)
%INTERP_Z2SIGMA interpolate z layer values to sigma layers
%
%   smatrix = INTERP_Z2SIGMA(z, zmatrix, sigma, eta, depth)
%
% where z[m] is positive UP, sigma [-1 ..0] is positive UP,
% eta [m] is the waterlevel positive UP, depth is the 
% depth positive UP, and zmatrix is a vector or matrix
% where the LAST dimension matches length(z). smatrix
% is a vector or matrix where the LAST dimension matches length(sigma).
% eta and depth can either be a scaler (constant) or 
% vector or matrix with the same size as sz(1:end-1) when
% sz = size(zmatrix) or sz = size(smatrix).
%
% The interpolation method can also be supplied as <keyword,value>
% pairs (not as direct arguments interp1) and are passed to INTERP1.
% By default method is 'linear' in the z-range, and 'nearest' outside
% the z-range, meaning that linear interpolation with "saturate" at the values
% at the extremes of the z-domain (NB an combination not available in interp1).
%
%   smatrix = INTERP_Z2SIGMA(z, zmatrix, sigma, eta, 'method',method,'extrap',extrap)
%
% Example: a waterlevel of 0m (MSL) at a 20m deep location.
%          We have z-data of salinity [34 32 31] at 3 levels: [0 20 40] m 
%          (beause the deepest z-model location is 40 m deep) and want to 
%          interpolate to 30 sigma layers.
%
%          zmax = 40;
%          interp_z2sigma([0 20 40]-zmax,[34 32 31],linspace(0,1,30),0,-20)
%
%See also: interp1, d3d_sigma, d3d_z

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

OPT.method = 'linear';
OPT.extrap = 'nearest';

OPT = setproperty(OPT,varargin);

sz0 = size(zmatrix);sz0 = sz0(1:end-1);
if  isvector(zmatrix)
    zmatrix = reshape(zmatrix,[1 1 length(zmatrix)]);
elseif  ndims(zmatrix)==2
    zmatrix = reshape(zmatrix,[1 size(zmatrix)]);
elseif ndims(zmatrix)>3
    error('ndims(zmatrix)>3 not implemented')
end
sz = size(zmatrix);

if isscalar(eta)
    eta = repmat(eta,sz(1:2));
end

if isscalar(depth)
    depth = repmat(depth,sz(1:2));
end

smatrix = repmat(0,[sz(1:2) length(sigma)]);

if strcmpi(OPT.extrap,'nearest')
   OPT.extrap = 'extrap';
   nearest    = 1;
   else
   nearest    = 0;
end

for m=1:sz(1)
   for n=1:sz(2)
   
      sigma_z_values = sigma.*(eta(m,n) - depth(m,n)) + depth(m,n);
      
      smatrix(m,n,:) = interp1(z,permute(zmatrix(m,n,:),[3 2 1]),sigma_z_values,OPT.method,OPT.extrap);
      
      % chop upper and lower layer to neraest values where sigma exceeds z-domain
      if nearest
         zmask = find(sigma_z_values > z(end));smatrix(m,n,zmask) = zmatrix(m,n,end);
         zmask = find(sigma_z_values < z(  1));smatrix(m,n,zmask) = zmatrix(m,n,1  );
      end
   
   end
end

smatrix = reshape(smatrix,[sz0(:)' length(sigma)]);
