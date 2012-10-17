function varargout=delft3d_io_crs(cmd,varargin),
%DELFT3D_IO_CRS   read/write cross sections (*.crs) <<beta version!>>
%
%  DATA=delft3d_io_crs('read' ,filename);
%
%       delft3d_io_crs('write',filename,DATA);
%       delft3d_io_crs('write',filename,DATA,<keyword,value>);
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, d3d_attrib

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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
   error(['AT least 2 input arguments required: d3d_io_...(''read''/''write'',filename)'])
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
% --READ------------------------------
% ------------------------------------

function STRUCT=Local_read(varargin),

STRUCT.filename = varargin{1};

fid          = fopen(STRUCT.filename,'r');
if fid==-1
   STRUCT.iostat   = fid;
else
   STRUCT.iostat   = -1;
   i            = 0;
   
   while ~feof(fid)

      i = i + 1;

   %try

    %  [STRUCT.namst,...
    %   STRUCT.mn1  ,...
    %   STRUCT.mn2  ,...
    %   STRUCT.mn3  ,...
    %   STRUCT.mn4  ]=textread(STRUCT.filename,'%20c%d%d%d%d');
       
       STRUCT.DATA(i).name         = fscanf(fid,'%20c',1); 
       STRUCT.DATA(i).mn           = fscanf(fid,'%i'  ,4);

       STRUCT.NTables = length(STRUCT.DATA);
   
      % turn the endpoint-description along gridlines into vectors

      [STRUCT.DATA(i).m,...
       STRUCT.DATA(i).n]=meshgrid(STRUCT.DATA(i).mn(1):STRUCT.DATA(i).mn(3),...
                                  STRUCT.DATA(i).mn(2):STRUCT.DATA(i).mn(4));
   
      fgetl(fid); % read rest of line

   end
   
   STRUCT.iostat  = 1;
   STRUCT.NTables  = i;

   for i=1:STRUCT.NTables
      STRUCT.m(i,:) = [STRUCT.DATA(i).mn(1) STRUCT.DATA(i).mn(3)];
      STRUCT.n(i,:) = [STRUCT.DATA(i).mn(2) STRUCT.DATA(i).mn(4)];
   end

end   
   %catch
   %   STRUCT.iostat  = -1;
   %end

if nargout==1
   varargout = {STRUCT};   
else
   varargout = {STRUCT,STRUCT.iostat};   
end

% ------------------------------------
% --WRITE-----------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows'; % or 'unix'

error('not tested')
for i=1:length(STRUCT.m)

   fprintf(fid,STRUCT.namst(i));
   fprintf(fid,STRUCT.m    (i));
   fprintf(fid,STRUCT.n    (i));

   if     strcmp(lower(OS(1)),'u')
      fprintf(fid,'\n');
   elseif strcmp(lower(OS(1)),'w')
      fprintf(fid,'\r\n');
   end
   
end


fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

