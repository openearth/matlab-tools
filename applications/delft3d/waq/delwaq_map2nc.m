function varargout = delwaq_map2nc(varargin)
%DELWAQ_MAP2NC  convert delwaq map file layer to netCDF file
%
%   DELWAQ_MAP2NC(<keyword,value>);
%
% saves one layer from one variable in a delwaq map file to netCDF file.
%
% Example: extract bed shear stresses (only present in last layer)
%
%   workdir = 'F:\delft3d\project007\'
%
%   OPT.grdfile       = [workdir,filesep,'MyWaqSimulation.lga'];
%   OPT.mapfile       = [workdir,filesep,'MyWaqSimulation.map'];
%   OPT.ncfile        = [workdir,filesep,'MyWaqSimulation_Tau_kmax.nc'];
%   OPT.SubsName      = 'Tau';
%   OPT.standard_name = 'magnitude_of_surface_downward_stress'; % seehttp://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/20/cf-standard-name-table.html: 
%   OPT.long_name     = '|bed shear stress|';
%   OPT.units         = 'N/m2'; % Pa
%   OPT.k             = Inf; % use integer or Inf for last layer index: kmax
%   OPT.epsg          = 28992;
%
%   delwaq_map2nc(OPT)
%
%See also: delwaq, L2BIN2NC, WAQ, VS_TRIM2NC

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.grdfile       = 'MyWaqSimulation.lga';
   OPT.mapfile       = 'MyWaqSimulation.map';
   OPT.ncfile        = 'MyWaqSimulation_Tau_kmax.nc';
   OPT.SubsName      = 'Tau';
   OPT.standard_name = 'magnitude_of_surface_downward_stress'; % seehttp://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/20/cf-standard-name-table.html: 
   OPT.long_name     = '|bed shear stress|';
   OPT.units         = 'N/m2'; % Pa
   OPT.k             = Inf; % Inf is replaced with last layer index
   OPT.epsg          = 28992;

   OPT = setproperty(OPT,varargin);
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% read meta-data

   G = delwaq('open',OPT.grdfile); % needs both lga and cco
   D = delwaq('open',OPT.mapfile); % needs both lga and cco
   T = delwaq_time(D);
   
  [G.cor.lon,G.cor.lat] = convertCoordinates(G.X(1:end-1,1:end-1),G.Y(1:end-1,1:end-1),'CS1.code',OPT.epsg,'CS2.code',4326);
   G.cen.lon  = corner2center(G.cor.lon);
   G.cen.lat  = corner2center(G.cor.lat);
   G.cen.mask = ~isnan(G.cen.lon);
   
%% create netCDF file (no data yet, only meta-data)

   L2bin2nc(OPT.ncfile,...
             'lon',G.cen.lon,...
             'lat',G.cen.lat,...
            'mask',G.cen.mask,...
       'lonbounds',G.cor.lon,...
       'latbounds',G.cor.lat,...
            'time',T.datenum,...
            'epsg',4326,...
            'Name',OPT.SubsName,...
   'standard_name',OPT.standard_name,...
       'long_name',OPT.long_name,...
           'units',OPT.units);

   fid = fopen(strrep(OPT.ncfile,'.nc','.cdl'),'w');
   nc_dump(OPT.ncfile,fid);
   fclose(fid);
                          
%% fill netCDF file (add data)
%  per time slice, to avoid memory issues.
   
   if isinf(OPT.k)
      OPT.k=G.MNK(3);
   end
   
   for it=1:D.NTimes
       disp([num2str(it,'%0.4d'),'/',num2str(D.NTimes,'%0.4d'),'=',num2str(100*it/D.NTimes,'%05.1f'),'%'])
       
      [t,vector] = delwaq('read',D,OPT.SubsName,0,it);
      
       matrix = waq2flow3d(vector,G.Index,'center');
       
       ncwrite(OPT.ncfile,OPT.SubsName,permute(matrix(:,:,OPT.k),[2 1 3]),[1 1 it]); % 1-based indices       
        
   end
