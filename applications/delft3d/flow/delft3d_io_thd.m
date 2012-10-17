function varargout=delft3d_io_thd(cmd,varargin)
%DELFT3D_IO_THD   read/write thin dams <<beta version!>>
%
%  THD = delft3d_io_thd('read' ,filename);
%
%        delft3d_io_thd('write',filename,THD);
%
% where THD is a struct with fields 'm','n'
%
%  THD = delft3d_io_thd('read' ,filename,G);
%
% also returns the x and y coordinates, where G = delft3d_io_grd('read',...)
%
% To plot thin dams use the example below:
%
%   plot(THD.x,THD.y)
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, d3d_attrib

% Nov 2007: put smallest index first in m and n fields.


%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

if nargin ==0
    error(['AT least 1 input arguments required: d3d_io_...(''read''/''write'',filename)'])
elseif nargin ==1
    varargin = {cmd,varargin{:}};
    cmd = 'read';
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

function S=Local_read(varargin),

S.filename = varargin{1};

%     mmax = Inf;
%     nmax = Inf;
%  if nargin==3
%     mmax = varargin{2};
%     nmax = varargin{3};
%  elseif nargin==4
%     mmax = varargin{3};
%     nmax = varargin{4};
%  end

fid          = fopen(S.filename,'r');
if fid==-1
    S.iostat   = fid;
else
    S.iostat   = -1;
    i            = 0;
    
    while ~feof(fid)
        
        i = i + 1;
        
        S.DATA(i).mn           = fscanf(fid,'%i'  ,4);
        
        %  if S.DATA(i).mn(1)==mmax+1
        %     S.DATA(i).mn(1)= mmax;
        %  end
        %  if S.DATA(i).mn(2)==nmax+1
        %     S.DATA(i).mn(2)= nmax;
        %  end
        %  if S.DATA(i).mn(3)==mmax+1
        %     S.DATA(i).mn(3)= mmax;
        %  end
        %  if S.DATA(i).mn(4)==nmax+1
        %     S.DATA(i).mn(4)= nmax;
        %  end
        
        S.DATA(i).direction = fscanf(fid,'%s',1);
        
        % turn the endpoint-description along gridlines into vectors
        % and make sure smallest index is first
        
        [S.DATA(i).m,...
            S.DATA(i).n]=meshgrid(min(S.DATA(i).mn([1,3])):max(S.DATA(i).mn([1,3])),...
            min(S.DATA(i).mn([2,4])):max(S.DATA(i).mn([2,4])));
        
        fgetl(fid); % read rest of line
        
    end
    
    S.iostat   = 1;
    S.NTables  = i;
    
    for i=1:S.NTables
        S.m(:,i) = [S.DATA(i).mn(1) S.DATA(i).mn(3)];
        S.n(:,i) = [S.DATA(i).mn(2) S.DATA(i).mn(4)];
    end
    
    if nargin >1
        G   = varargin{2};
        S.x = nan.*S.m;
        S.y = nan.*S.m;
        
        for i=1:S.NTables
            
            m = S.m(1,i);
            n = S.n(1,i);
            
            if     strcmpi(S.DATA(i).direction,'u')
                
                S.x(:,i) = [G.cor.x(n,m  ) G.cor.x(n-1  ,m  )];
                S.y(:,i) = [G.cor.y(n,m  ) G.cor.y(n-1  ,m  )];
                
            elseif strcmpi(S.DATA(i).direction,'v')
                
                S.x(:,i) = [G.cor.x(n  ,m-1) G.cor.x(n  ,m  )];
                S.y(:,i) = [G.cor.y(n  ,m-1) G.cor.y(n  ,m  )];
                
            end
            
        end
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

