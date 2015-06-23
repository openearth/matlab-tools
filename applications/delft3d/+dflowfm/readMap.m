function varargout = readMap(ncfile,varargin)
%readMap   Reads solution data on a D-Flow FM unstructured net.
%
%     D = dflowfm.readMap(ncfile,<it>) 
%     D = dflowfm.readMap(G     ,<it>) 
%     D = dflowfm.readMap(G     [,it [,opt=val [, opt=val ...]] ]) 
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

   OPT.zwl       = 1; % whether to load data 
   OPT.sal       = 0; % whether to load data 
   OPT.vel       = 1; % whether to load data 
   OPT.spir      = 0; % whether to load data 

   if nargin==0
      varargout = {OPT};
      return
   end

   if isstruct(ncfile)
      G      = ncfile;
      ncfile = G.file.name;
   else
      G      = dflowfm.readNet(ncfile);
   end
   
   if odd(nargin)
      tmp     = nc_getvarinfo(ncfile,'s1');
      it      = tmp.Size(1);
      face.FlowElemSize   = tmp.Size(2);
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
   
%% 3D: number of layers
   L3D = false;
   if nc_isdim(ncfile, 'laydim')
       dum = nc_getdiminfo(ncfile,'laydim');
       laydim = dum.Length;
       D.laydim = laydim;
   end

%% read cen data

   face.mask = G.face.FlowElemSize; % not an index array yet as nc_varget can only handle one range

   if OPT.zwl && nc_isvar (ncfile, 's1');
      D.face.zwl  = nc_varget(ncfile, 's1' ,[it-1 0],[1 face.mask]); % Waterlevel
   end  
   if OPT.sal && nc_isvar (ncfile, 'sa1');
       info=nc_getvarinfo(ncfile,'sa1');
       NDIM=length(info.Size);
       if ( NDIM==2 )
           D.face.sal  = nc_varget(ncfile, 'sa1',[it-1 0],[1 face.mask]); % Salinity
       else
           if ( NDIM==3 )
              D.face.sal  = nc_varget(ncfile, 'sa1',[it-1 0 0],[1 face.mask laydim]); % Salinity
           end
       end
   end
   
   if OPT.vel && nc_isvar (ncfile, 'ucx')
      info=nc_getvarinfo(ncfile,'ucx');
      NDIM=length(info.Size);
      if ( NDIM==2 )
%        2D          
         D.face.u    = nc_varget(ncfile, 'ucx',[it-1 0],[1 face.mask]); % x velocity at cell center
         if nc_isvar (ncfile, 'ucy');
            D.face.v    = nc_varget(ncfile, 'ucy',[it-1 0],[1 face.mask]); % y velocity at cell center
         end
      else
         if ( NDIM==3 )
            D.face.u    = nc_varget(ncfile, 'ucx',[it-1 0 0],[1 face.mask laydim]); % x velocity at cell center
            if nc_isvar (ncfile, 'ucy');
               D.face.v    = nc_varget(ncfile, 'ucy',[it-1 0 0],[1 face.mask laydim]); % y velocity at cell center
            end
            if nc_isvar (ncfile, 'ucz');
               D.face.w    = nc_varget(ncfile, 'ucz',[it-1 0 0],[1 face.mask laydim]); % y velocity at cell center
            end            
         end
      end
   end
   if OPT.spir && nc_isvar (ncfile, 'spircrv');
      D.face.crv  = nc_varget(ncfile, 'spircrv' ,[it-1 0],[1 face.mask]); % Curvature
   end  
   if OPT.spir && nc_isvar (ncfile, 'spirint');
      D.face.I    = nc_varget(ncfile, 'spirint' ,[it-1 0],[1 face.mask]); % Secondary flow intensity
   end  

%% < read face data >

%   face.mask = cen.n; % not an index array yet as nc_varget cna only handle one range
%   
%   if OPT.vel & nc_isvar (ncfile, 'unorm');
%   D.face.un  = nc_varget(ncfile, 'unorm',[it-1 0],[1 face.mask]);
%   end



varargout = {D};
