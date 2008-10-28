function varargout=delft3d_io_obs(cmd,varargin),
%DELFT3D_IO_OBS   read/write observations points file (*.obs) <<beta version!>>
%
%  DATA = delft3d_io_obs('read' ,filename);
%
%         delft3d_io_obs('write',filename,DATA);
%
% where OBS is a struct with fields 'm','n','namst'
% where namst is read as a 2C char array, but can also be a cellstr.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 
%           XY2MN

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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


if nargin ==1
   error(['AT least 2 input arguments required: delft3d_io_obs(''read''/''write'',filename)'])
end

switch lower(cmd),
case 'read',
  STRUCT=Local_read(varargin{:});
  if nargout ==1
     varargout = {STRUCT};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if STRUCT.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output paramters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function STRUCT=Local_read(varargin),

STRUCT.filename = varargin{1};

   try

   [STRUCT.namst,...
    STRUCT.m    ,...
    STRUCT.n    ]=textread(STRUCT.filename,'%20c%d%d');

   STRUCT.NTables = length(STRUCT.m);
   STRUCT.m=STRUCT.m';
   STRUCT.n=STRUCT.n';
   
      STRUCT.iostat  = 1;
   catch
      STRUCT.iostat  = -1;
   end

if nargout==1
   varargout = {STRUCT};   
else
   varargout = {STRUCT,STRUCT.iostat};   
end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT,varargin),

   iostat       = 1;
   fid          = fopen(filename,'w');
   
   if nargin==3
   OS = varargin{1};
   else
   OS           = 'windows'; % or 'unix'
   end
   
   if ~isfield(STRUCT,'namst')
      STRUCT.namst = [];
      for iobs=1:length(STRUCT.m)
         STRUCT.namst = strvcat(STRUCT.namst,['(',num2str(STRUCT.m(iobs)),...
                                              ',',...
                                                  num2str(STRUCT.n(iobs)),...
                                              ')']);
      end
   end
   
   STRUCT.namst = cellstr(STRUCT.namst);
   
   for iobs=1:length(STRUCT.m)
   
      fprintfstringpad(fid,20,STRUCT.namst{iobs});
      
      fprintf(fid,' %7d',STRUCT.m    (iobs  ));
      fprintf(fid,' %7d',STRUCT.n    (iobs  ));
      fprinteol(fid,OS)
      
   end

fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

