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

   OPT.ncfile      = 'awad2d_net.nc';
   OPT.out         = 'awad2d_vaklodingen_net.nc';

   OPT.bathy       = opendap_catalog('F:\opendap\thredds\rijkswaterstaat\vaklodingen_remapped\');
   OPT.xname       = 'x'; % search for projection_x_coordinate, or longitude, or ...
   OPT.yname       = 'y'; % search for projection_x_coordinate, or latitude , or ...
   OPT.varname     = 'z'; % search for altitude, or ...

   OPT.poly        = '';
   OPT.method      = 'linear'; % only for 1st step, second step is nearest
   OPT.datenum     = datenum(2010,7,1); % get from mdu
   OPT.ddatenummax = datenum(10,1,1); % temporal search window in years (for direction see 'order')
   OPT.order       = ''; % RWS: Specifieke Operator Laatste/Dichtsbij/Prioriteit

   OPT.debug       = 0;
   
   OPT = setproperty(OPT,varargin{:});
   
%% Load grid

   G             = dflowfm.readNet(OPT.ncfile);
   G.cor.z       = G.cor.z.*nan; % G.cor.z       = nc_varget(OPT.ncfile,'NetNode_z')';
   G.cor.datenum = G.cor.z.*nan; % G.cor.datenum = nc_varget(OPT.ncfile,'NetNode_t')';
   
   if ~isempty(OPT.poly)
      [P.x,P.y]         = landboundary('read',OPT.poly);
      polygon_selection = inpolygon(G.cor.x,G.cor.y,P.x,P.y);
   else
      polygon_selection = ones(size(G.cor.x));
   end

%% data   
   if ischar(OPT.bathy)
   list = opendap_catalog(OPT.bathy);
   end
   
   OPT2 = OPT;
   OPT2 = rmfield(OPT2,'ncfile');
   OPT2 = rmfield(OPT2,'out');

   %% fill holes with samples of nearest/latest/first in time
   [zi,ti,fi,fi_legend]=nc_cf_gridset_getData(G.cor.x,G.cor.y,   OPT2);
   
   G.cor.z       = zi;
   G.cor.datenum = ti;
   G.cor.files   = fi;
   
   % internal interpolation ? 

   OPT.method           = 'nearest';
   [zi,ti,fi,fi_legend] =nc_cf_gridset_getData(G.cor.x,G.cor.y,zi,OPT2);
   extra = isnan(G.cor.z) & ~isnan(zi);
   G.cor.z(extra)       = zi(extra);
   G.cor.datenum(extra) = nan;
   G.cor.files(extra)   = 0;
       
%% save

   copyfile(OPT.ncfile,OPT.out)

   nc_varput(OPT.out,'NetNode_z',G.cor.z);
   
%% add date of sample points to ncfile (not in unstruc output)
   
   clear nc
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

%% add data source to ncfile (not in unstruc output)

   clear nc
   nc.Name      = 'NetNode_file';
   nc.Nctype    = 'int';
   nc.Dimension = { 'nNetNode' };
   nc.Attribute(1).Name  = 'files';
   nc.Attribute(1).Value = [num2str([1:length(fi_legend)]') addrowcol(addrowcol(char(fi_legend),0,-1,' = '),0,1,';')]';
   %nc.Attribute(1).Name  = 'flag_values';    % TO DO
   %nc.Attribute(1).Value = @unique(fi);      % TO DO
   %nc.Attribute(2).Name  = 'flag_masks';     % TO DO
   %nc.Attribute(2).Value = @fi_legend;       % TO DO
   %nc.Attribute(3).Name  = 'flag_meanings';  % TO DO
   %nc.Attribute(3).Value = @fi_legend;       % TO DO
   nc_addvar(OPT.out,nc);  
  
   nc_varput(OPT.out,'NetNode_file',int8(G.cor.files));
   
