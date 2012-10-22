function varargout = readMap(ncfile,varargin)
%readMap   Reads solution data on a D-Flow FM unstructured net.
%
%     D = dflowfm.readMap(ncfile,<it>) 
%     D = dflowfm.readMap(G     ,<it>) 
%
%   reads flow circumcenter(cen) data from an D-Flow FM NetCDF file. 
%   By default is the LAST timestep is read (it=last).
%
%   For plotting also use G = dflowfm.readNet(ncfile)
%
% See also: dflowfm, delft3d

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
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

%   $Id$

% TO DO make D a true object with methods etc.
% TO DO read only data in OPT.axis box

%% input

   OPT.face      = 0; % whether to load face data 
   OPT.zwl       = 1; % whether to load data 
   OPT.sal       = 0; % whether to load data 
   OPT.vel       = 0; % whether to load data 

   if nargin==0
      varargout = {OPT};
      return
   end

   if isstruct(ncfile)
      G      = ncfile;
      ncfile = G.file.name
   else
      G      = dflowfm.readNet(ncfile);
   end
   
   if odd(nargin)
      tmp     = nc_getvarinfo(ncfile,'s1');
      it      = tmp.Size(1);
      cen.n   = tmp.Size(2);
      nextarg = 1;
   else
      it      = varargin{1};
      nextarg = 2;
   end

   if nargin==0
      varargout = {OPT};
      return
   else
      OPT = setproperty(OPT,varargin{nextarg:end});
   end

%% read time data

   D.datenum = nc_cf_time(ncfile, 'time');
   D.datenum = D.datenum(it);
   D.datestr = datestr(D.datenum,31);

%% read cen data

   cen.mask = G.cen.n; % not an index array yet as nc_varget can only handle one range

   if OPT.zwl & nc_isvar (ncfile, 's1');
   D.cen.zwl  = nc_varget(ncfile, 's1' ,[it-1 0],[1 cen.mask]); % Waterlevel
   end
   
   if OPT.sal & nc_isvar (ncfile, 'sal');
   D.cen.sal  = nc_varget(ncfile, 'sal',[it-1 0],[1 cen.mask]); % Salinity
   end
   
   if OPT.vel & nc_isvar (ncfile, 'ucx');
   D.cen.u    = nc_varget(ncfile, 'ucx',[it-1 0],[1 cen.mask]); % x velocity at cell center
   end

   if OPT.vel & nc_isvar (ncfile, 'ucy');
   D.cen.v    = nc_varget(ncfile, 'ucy',[it-1 0],[1 cen.mask]); % y velocity at cell center
   end

%% < read face data >

%   face.mask = cen.n; % not an index array yet as nc_varget cna only handle one range
%   
%   if OPT.vel & nc_isvar (ncfile, 'unorm');
%   D.face.un  = nc_varget(ncfile, 'unorm',[it-1 0],[1 face.mask]);
%   end

varargout = {D};
