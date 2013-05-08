function varargout=delft3d_io_src(cmd,varargin),
%DELFT3D_IO_SRC   read/write open source locations file <<beta version!>>
%
%  S=delft3d_io_src('read' ,filename);
%    delft3d_io_src('write',filename,S);
%    delft3d_io_src('write',filename,S.DATA);
%
% here S.DATA has required fields 'name', 'interpolation', 'm', 'n', 'k'
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
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
  if nargout==1
     varargout = {STRUCT};
  elseif nargout >1
    error('too much output paramters: 0 or 1')
  end
  if STRUCT.iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write(varargin{:});
  if nargout==1
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

%   mmax = Inf;
%   nmax = Inf;
%if nargin==3 
%   mmax = varargin{2};
%   nmax = varargin{3};
%elseif nargin==4 
%   mmax = varargin{3};
%   nmax = varargin{4};
%end   

fid          = fopen(STRUCT.filename,'r');
if fid==-1
   STRUCT.iostat   = fid;
else
   STRUCT.iostat   = -1;
   i            = 0;
   
   while ~feof(fid)
   
      i = i + 1;
   
      STRUCT.DATA(i).name          = fscanf(fid,'%20c',1); 
      STRUCT.DATA(i).interpolation = fscanf(fid,'%1s' ,1);
      STRUCT.DATA(i).m             = fscanf(fid,'%i'  ,1);
      STRUCT.DATA(i).n             = fscanf(fid,'%i'  ,1);
      STRUCT.DATA(i).k             = fscanf(fid,'%i'  ,1);
      STRUCT.DATA(i).type          = fscanf(fid,'%i'  ,1); % new
      
     % if STRUCT.DATA(i).m==mmax+1
     %    STRUCT.DATA(i).m= mmax;
     % end
     % if STRUCT.DATA(i).n==nmax+1
     %    STRUCT.DATA(i).n= nmax;
     % end
      
      restofline = fgetl(fid); % read rest of line
      
      if ~isempty(restofline)
      end
      
   end   
   
   STRUCT.iostat   = 1;
   STRUCT.NTables  = i;

   STRUCT.m = [];
   STRUCT.n = [];
   for isrc=1:STRUCT.NTables
      STRUCT.m = [STRUCT.m STRUCT.DATA(isrc).m];
      STRUCT.n = [STRUCT.n STRUCT.DATA(isrc).n];
   end
   
end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,varargin),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

if ~isfield(varargin{1},'DATA')
    STRUCT.DATA = varargin{1};
end

for i=1:length(STRUCT.DATA)

   fprintfstringpad(fid,20,STRUCT.DATA(i).name,' ');

   fprintf(fid,'%1c',' ');
   % fprintf automatically adds one space between all printed variables
   % within one call
   fprintf(fid,'%1c %i %i %i %s',...
           STRUCT.DATA(i).interpolation,...
           STRUCT.DATA(i).m            ,...
           STRUCT.DATA(i).n            ,...
           STRUCT.DATA(i).k            ,....
           STRUCT.DATA(i).type         ); % new
   
   if     strcmp(lower(OS(1)),'u')
      fprintf(fid,'\n');
   elseif strcmp(lower(OS(1)),'w')
      fprintf(fid,'\r\n');
   end

end;
fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

