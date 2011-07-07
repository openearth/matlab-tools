function varargout = fillDep(varargin)
%fillDep fill depth values from OPeNDAP data source (single grid or gridset of tiles)
%
%     <out> = dflowfm.fillDep(<keyword,value>) 
%
% where  the following keywords mean:
% * bathy   provides data sources, cellstr of files, e.g. opendap_catalog()
% * ncfile  input map nc file
% * out     input map nc file (same as ncfile with depth + timestaps added)
% * ...
%
%   See also dflowfm, delft3d, nc_cf_gridset_getData

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.ncfile      = 'F:\checkouts\mcmodels\effect-chain-waddenzee\HYDRODYNAMICA\unstruc\ducktape_n_pur\precise\precise4h_net.nc';
   OPT.out         = 'F:\checkouts\mcmodels\effect-chain-waddenzee\HYDRODYNAMICA\unstruc\ducktape_n_pur\precise\precise4h_vaklodingen_net.nc';

   OPT.bathy       = opendap_catalog('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen_remapped/catalog.xml');
   OPT.xname       = 'x'; % search for projection_x_coordinate, or longitude, or ...
   OPT.yname       = 'y'; % search for projection_x_coordinate, or latitude , or ...
   OPT.varname     = 'z'; % search for altitude, or ...

   OPT.poly        = '';
   OPT.method      = 'linear'; % only for 1st step, second step is nearest
   OPT.datenum     = datenum(1998,7,1); % get from mdu
   OPT.ddatenummax = datenum(3,1,1); % temporal search window in years (for direction see 'order')
   OPT.order       = ''; % RWS: Specifieke Operator Laatste/Dichtsbij/Prioriteit

   OPT.debug       = 0;
   
   OPT = setProperty(OPT,varargin{:});
   
%% Load grid

   G             = delft3dfm.readNet(OPT.ncfile);
   G.cor.z       = G.cor.z.*nan; % G.cor.z       = nc_varget(OPT.ncfile,'NetNode_z')';
   G.cor.datenum = G.cor.z.*nan; % G.cor.datenum = nc_varget(OPT.ncfile,'NetNode_t')';
   
   if ~isempty(OPT.poly)
      [P.x,P.y]         = landboundary('read',OPT.poly);
      polygon_selection = inpolygon(G.cor.x,G.cor.y,P.x,P.y);
   else
      polygon_selection = ones(size(G.cor.x));
   end

%% data   
   
   list = opendap_catalog(OPT.bathy);
   
%% fill holes with samples of nearest/latest/first in time

   [zi,ti,fi,fi_legend]=nc_cf_gridset_getData(G.cor.x,G.cor.y,   OPT);
   
   % internal interpolation ? 

   OPT.method          = 'nearest';
   [zi,ti,fi,fi_legend]=nc_cf_gridset_getData(G.cor.x,G.cor.y,zi,OPT);
       
%% save

   copyfile(OPT.ncfile,OPT.out)

   nc_varput(OPT.out,'NetNode_z',G.cor.z);
   
%% add date of sample points to ncfile (not in unstruc output)
   
   nc.Name      = 'NetNode_t';
   nc.Nctype    = 'double';
   nc.Dimension = { 'nNetNode' };
   nc.Attribute(1).Name  = 'units';
   nc.Attribute(1).Value = 'days since 1970-01-01 00:00:00';
   nc.Attribute(2).Name  = 'standard_name';
   nc.Attribute(2).Value = 'time';
   nc.Attribute(3).Name  = 'long_name';
   nc.Attribute(3).Value = 'recording time of depth sounding';
   nc_addvar(OPT.out,nc);  
  
   nc_varput(OPT.out,'NetNode_t',G.cor.datenum - datenum(1970,1,1));

   nc.Name      = 'NetNode_file';
   nc.Nctype    = 'int';
   nc.Dimension = { 'nNetNode' };
   nc.Attribute(1).Name  = 'flag_value';
   nc.Attribute(1).Value = @unique(fi);
   nc.Attribute(2).Name  = 'flag_name';
   nc.Attribute(2).Value = @fi_legend;
   nc_addvar(OPT.out,nc);  
  
   nc_varput(OPT.out,'NetNode_t',fi);
   
