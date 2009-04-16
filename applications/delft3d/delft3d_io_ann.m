function varargout = delft3d_io_ann(cmd,varargin)
%DELFT3D_IO_ANN   Read annotation files in a nan-separated list struct (*.ann)  (BETA VERSION)
%
%    DELFT3D_IO_ANN reads all lines from an *.ann annotation file
%    into a nan separated list struct (vector map).
%
%    ANN = DELFT3D_IO_ANN('read',filename) returns the x and y
%    (or lat and lon) vertices in the struct fields
%    DAT.x and DAT.y respectively. The texts are returned
%    in DAT.txt
%
%    [x,y,<annotation>] = DELFT3D_IO_ANN('read',filename);
%
%    ANN = DELFT3D_IO_ANN('read',filename,scale) 
%    multiplies x and y with scale
%
%    ANN= DELFT3D_IO_ANN('read',filename,xscale,yscale) 
%    multiplies x and y with xscale and yscale
%    respectively.
%
%    iostat = DELFT3D_IO_ANN('write',filename,ANN.DATA) 
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
%           LANDBOUNDARY

% 2005 Jan 01
% 2008 Jul 21: made read a sub-function
% 2008 Jul 22: added write option
% 2009 feb 13: made also [x,y,text] output

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2008 Delft University of Technology
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

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_ann(''read''/''write'',filename)'])
end

switch lower(cmd),

case 'read',
   [STRUCT,iostat]=Local_read(varargin{:});
  if nargout==1
     varargout = {STRUCT};
  elseif nargout ==2
     varargout = {STRUCT.DATA.x,STRUCT.DATA.y};
  elseif nargout ==3
     varargout = {STRUCT.DATA.x,STRUCT.DATA.y,STRUCT.DATA.txt};
  elseif nargout ==4
    error('too much output parameters: [1..3]')
  end
  if STRUCT.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;

case 'write',
  iostat=Local_write(varargin{:});
  if nargout==1
     varargout = {iostat};
  elseif nargout >1
    error('too much output parameters: [0..1]')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function [DAT,iostat]=Local_read(varargin)

   fname = varargin{1};
   
   tmp               = dir(fname);
   if length(tmp)==0
      error(['Annotation file ''',fname,''' does not exist.'])
   end
   DAT.name  = tmp.name ;
   DAT.date  = tmp.date ;
   DAT.bytes = tmp.bytes;   
   
   if nargin>2
       xscale = varargin{2};
       yscale = varargin{2};
   elseif nargin >3
       xscale = varargin{2};
       yscale = varargin{3};
   else
       xscale = 1;
       yscale = 1;
   end

   RAWDATA = tekal('open',fname);
   
   if strcmp(RAWDATA.Check,'OK')
      for i=1:length(RAWDATA.Field)
         SUBSET           = tekal('read',RAWDATA,i);
         DAT.DATA(i).x    = SUBSET{1}(:,1).*xscale;
         DAT.DATA(i).y    = SUBSET{1}(:,2).*yscale;
         DAT.DATA(i).txt  = SUBSET{2};
      end
      DAT.iostat   = 1;
   else
      DAT.DATA.x   = [];
      DAT.DATA.y   = [];
      DAT.DATA.txt = [];
      DAT.iostat   = 0;
   end
   
   iostat = DAT.iostat;
   
% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(varargin)   

filename     = varargin{1};
STRUCT       = varargin{2};

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

%% Header
%% -------------------------

fprintf  (fid,'%s',['* File created on ',datestr(now),' with matlab function delft3d_io_ann.m']);
fprinteol(fid,OS);

fprintf  (fid,'%s',['BLOCK01']);
fprinteol(fid,OS);

fprintf  (fid,'%d ',length(STRUCT.x));
fprintf  (fid,'%d ',3             );
fprinteol(fid,OS);

%% Table 
%% -------------------------

for istat=1:length(STRUCT.x)

   fprintf  (fid,'%f ',STRUCT.x  (istat));
   fprintf  (fid,'%f ',STRUCT.y  (istat));
   fprintf  (fid,'%s ',STRUCT.txt{istat});
   fprinteol(fid,OS);
   
end   

iostat = fclose(fid);

%% EOF