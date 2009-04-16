function varargout=delft3d_io_thd(cmd,varargin),
%DELFT3D_IO_THD   read/write thin dams <<beta version!>>
%
%  DATA=delft3d_io_thd('read' ,filename);
%
%       delft3d_io_thd('write',filename,DATA);
%
% To plot thin dams use the example below:
%
% >>   for ithd = 1:THD.NTables
% >>   
% >>      m = THD.DATA(ithd).m;
% >>      n = THD.DATA(ithd).n;
% >>      
% >>      if length(m)==1
% >>         m = [m m];
% >>         n = [n n];
% >>      end
% >>   
% >>      if     strcmpi(THD.DATA(ithd).direction,'u')
% >>      plot([G.cor.x(n(1)-1,m(1)  ) G.cor.x(n(end)  ,m(end)  )]./OPT.scale,...
% >>           [G.cor.y(n(1)-1,m(1)  ) G.cor.y(n(end)  ,m(end)  )]./OPT.scale,'k','linewidth',2,'color',[.8 .8 .8])
% >>      elseif strcmpi(THD.DATA(ithd).direction,'v')
% >>      plot([G.cor.x(n(1)  ,m(1)-1) G.cor.x(n(end)  ,m(end)  )]./OPT.scale,...
% >>           [G.cor.y(n(1)  ,m(1)-1) G.cor.y(n(end)  ,m(end)  )]./OPT.scale,'k','linewidth',2,'color',[.8 .8 .8])
% >>      end
% >>           
% >>      hold on
% >>      
% >>   end
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 

% Nov 2007: put smallest index first in m and n fields.


%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@citg.tudelft.nl	
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

%     mmax = Inf;
%     nmax = Inf;
%  if nargin==3 
%     mmax = varargin{2};
%     nmax = varargin{3};
%  elseif nargin==4 
%     mmax = varargin{3};
%     nmax = varargin{4};
%  end   

fid          = fopen(STRUCT.filename,'r');
if fid==-1
   STRUCT.iostat   = fid;
else
   STRUCT.iostat   = -1;
   i            = 0;
   
   while ~feof(fid)
   
      i = i + 1;
   
      STRUCT.DATA(i).mn           = fscanf(fid,'%i'  ,4);
      
      %  if STRUCT.DATA(i).mn(1)==mmax+1
      %     STRUCT.DATA(i).mn(1)= mmax;
      %  end
      %  if STRUCT.DATA(i).mn(2)==nmax+1
      %     STRUCT.DATA(i).mn(2)= nmax;
      %  end
      %  if STRUCT.DATA(i).mn(3)==mmax+1
      %     STRUCT.DATA(i).mn(3)= mmax;
      %  end
      %  if STRUCT.DATA(i).mn(4)==nmax+1
      %     STRUCT.DATA(i).mn(4)= nmax;
      %  end
      
      STRUCT.DATA(i).direction = fscanf(fid,'%s',1);
      
      % turn the endpoint-description along gridlines into vectors
      % and make sure smallest index is first

      [STRUCT.DATA(i).m,...
       STRUCT.DATA(i).n]=meshgrid(min(STRUCT.DATA(i).mn([1,3])):max(STRUCT.DATA(i).mn([1,3])),...
                                  min(STRUCT.DATA(i).mn([2,4])):max(STRUCT.DATA(i).mn([2,4])));

      fgetl(fid); % read rest of line
      
   end   
   
   STRUCT.iostat   = 1;
   STRUCT.NTables  = i;
   
   for i=1:STRUCT.NTables
      STRUCT.m(i,:) = [STRUCT.DATA(i).mn(1) STRUCT.DATA(i).mn(3)];
      STRUCT.n(i,:) = [STRUCT.DATA(i).mn(2) STRUCT.DATA(i).mn(4)];
   end
   
end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

for i=1:length(STRUCT.DATA)

   % fprintfstringpad(fid,20,STRUCT.DATA(i).name,' ');

   fprintf(fid,'%1c',' ');
   % fprintf automatically adds one space between all printed variables
   % within one call
   fprintf(fid,'%5i %5i %5i %5i %1c',...
           STRUCT.DATA(i).mn(1)   ,...
           STRUCT.DATA(i).mn(2)   ,...
           STRUCT.DATA(i).mn(3)   ,...
           STRUCT.DATA(i).mn(4)   ,...
           STRUCT.DATA(i).direction    );

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

