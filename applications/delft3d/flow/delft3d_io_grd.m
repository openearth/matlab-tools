function varargout = delft3d_io_grd(varargin)
%DELFT3D_IO_GRD   wrapper for WLGRID to deal with ambiguous dummy rows. <<beta version!>>
%
%   G = delft3d_io_grd('read' ,filename)
%
% reads coordinates of corner and center points and of
% center points where the dummy rows are filled by mirroring.
%
%   G.cor  represents corner points without dummy row/col:           1:nmax-1 x 1:mmax-1
%   G.cen  represents center points without dummy row/col:           2:nmax-1 x 2:mmax-1
%   G.cend represents center points with extrapolated dummy row/col: 1:nmax   x 1:mmax
%
%   for xy2mn: use the G.cend output
%
% Note that n is the first dimension, to be compatible 
% with the vs_ functionality.
%
%   G = delft3d_io_grd('read' ,filename,<keyword,value>)
%
% The following keywords have been implemented:
%
% * nodatavalue : nodatavalue of data in grid file    (default 0)
% * missingvalue: nodatavalue of data in the G struct (default NaN)
% * epsg;        [lat,lon] WGS84 are calculated when epsg code is supplied (default [])
%
%       delft3d_io_grd('write',filename,cor.x,cor.y)
%       delft3d_io_grd('write',filename,STRUC)
%
% where struct has fields cor.x,cor.y.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, xy2mn, wlgrd

%   --------------------------------------------------------------------
%   Copyright (C) 2005-7 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA or 
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

delft3d_io_grd_version = '1.0beta';

if nargin ==1
   error(['At least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
end

   cmd   = varargin{1};
   fname = varargin{2};
   
%% Add file info

   G.projection          = '';
   G.ellipsoid           = '';
   
   OPT.nodatavalue       = 0;   % of file
   OPT.missingvalue      = NaN; % in struct
   OPT.epsg              = [];

%% Read

   if strcmp(cmd,'read')

      OPT = setproperty(OPT,varargin{3:end});
       
      tmp               = dir(fname);
         if length(tmp)==0
            error(['Grid file ''',fname,''' does not exist.'])
         end
      G.files.grd.name  = tmp.name ;
      G.files.grd.date  = tmp.date ;
      G.files.grd.bytes = tmp.bytes;

      TMP               = wlgrid('read',fname);
      
      TMP.MissingValue  = OPT.nodatavalue; % overrule default value of 0
      G.nodatavalue     = OPT.missingvalue;
      
      fields2copy       = {'Enclosure',... %'FileName',...
                           'CoordinateSystem',...
                           'Type'}; %,...'Enc'};
                     
      for ifld=1:length(fields2copy)
         field2copy = char(fields2copy{ifld});
         try
         G.(field2copy) = TMP.(field2copy);
         end
      end
      
      TMP.X(TMP.X==TMP.MissingValue) = G.nodatavalue;
      TMP.Y(TMP.Y==TMP.MissingValue) = G.nodatavalue;

   %% Calculate

      G.mmax         = size(TMP.X,1)+1;% GJ de Boer, swapped 2009 apr 22, swapped back 2010 mar 16 for use with $Id$
      G.nmax         = size(TMP.X,2)+1;% GJ de Boer, swapped 2009 apr 22, swapped back 2010 mar 16 for use with $Id$
      
      %% make sure n is first dimension, just like vs_ functionality.
      G.cor.x        = TMP.X';
      G.cor.y        = TMP.Y';
      G.cor.x_units  = '';
      G.cor.y_units  = '';
      
      G.cor.comment  = 'corner points without dummy rows/columns (1:nmax-1) x (1:mmax-1)';
      
      if ~isempty(OPT.epsg)
      [G.cor.lon,G.cor.lat,OPT]=convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      end

      G.cen.x        = corner2centernan(G.cor.x);
      G.cen.y        = corner2centernan(G.cor.y);
      G.cen.x_units  = '';
      G.cen.y_units  = '';
       
      G.cen.comment  = 'center points without dummy rows/columns (2:nmax-1) x (2:mmax-1)';
      
      G.u.comment    = 'ksi-velocity faces without dummy rows/columns (2:nmax-1) x (1:mmax-1)';
      G.v.comment    = 'eta-velocity faces without dummy rows/columns (1:nmax-1) x (2:mmax-1)';

      G.cend.x       = addrowcol(corner2centernan(G.cor.x),[-1 1],[-1 1],nan);
      G.cend.y       = addrowcol(corner2centernan(G.cor.y),[-1 1],[-1 1],nan);
      
      [G.cor.encx,G.cor.ency] = enclosure('coordinates',G.cor.x,G.cor.y);

      G.cend.comment = {'center points WITH dummy rows/columns (1:nmax  ) x (1:mmax  )',...
                        'values filled with mirroring',...
                        'location of scalar boundary conditions',...
                        'extra d stand for <d>ummy or <d>elft3d'};
                     
      %% add to allow delft3d_io_dep to update this structure
      G.cen.dep         = [];
      G.cen.dep_comment = '';
      G.cor.dep         = [];
      G.cor.dep_comment = '';
      G.dpsopt          = '';
      G.location        = '';
      
%-% disp('NOTE')
%-% disp('still to be implemented: nan seperated external and internal enxclosures')
%-% disp('seperation when both m and n index differ between successive elements')
%-%      
%-%      G.encm = G.Enclosure(:,1);
%-%      G.encn = G.Enclosure(:,2);
%-%
%-%      try
%-%     [G.encx,...
%-%      G.ency] = get_gridline(G.xcenbnd,...
%-%      		        G.ycenbnd,...
%-%      		        G.encm  ,...
%-%			        G.encn);      
%-%      
%-%      end

      varargout = {G};
      OK = 1;

   else strcmp(cmd,'write');
       
      if  isnumeric(varargin{3}) & isnumeric(varargin{4})
      OPT = setproperty(OPT,varargin{5:end});
      else
      OPT = setproperty(OPT,varargin{3:end});
      end
   
   disp('!!!!! write function under construction')
   
   [fileexist,action]=filecheck(fname);
   if strcmpi(action,'o')
      mkpath(filepathstr(fname))
   end
   
      if nargin==3
      G         = varargin{3};
      else
      G.cor.x   = varargin{3};
      G.cor.y   = varargin{4};
      end
      
      if action=='o'
      OK   = wlgrid(cmd,fname,G.cor.x,G.cor.y);
      else
      OK = 0;
      end

  %    %% Read and write again to write also enclosure
  %    
  %    
  %    Gtmp = wlgrid('read' ,filename);
  %   %OK   = wlgrid('write',filename,Gtmp);% the new wlgrid does not write the enclosure automatically from the struct
  %       if ~isempty(Gtmp.Enclosure)
  %    OK   = wlgrid('write',filename,Gtmp.X,Gtmp.Y,Gtmp.Enclosure); % read with same filename as grid
  %    elseif ~isempty(Gtmp.Enc)
  %    OK   = wlgrid('write',filename,Gtmp.X,Gtmp.Y,Gtmp.Enc); % newly calculated
  %    else
  %       warning('no enclosure written');
  %    end
  
     varargout = {1};
   
   end
         
STRUCT.GrdFileName = varargin{2};
STRUCT.iostat      = OK;
