function varargout=delft3d_io_dry(cmd,varargin),
%DELFT3D_IO_DRY   Read/write dry cell file <<beta version!>>
%
%  D        = delft3d_io_dry('read',filename);
% [G,<D>]   = delft3d_io_dry('read',filename,G); where G comes from delft3d_io_grd
%
%  adds to struct G the fields 
%    G.cen.dry  with 0/1   for wet/dry points
%    G.cen.mask with 1/nan for wet/dry points, for multiplicative use on
%    center arrays as in G.cen.* or returned by vs_let_scalar
%  returns a struct D with fields 
%    * m0, n0, m1, n1:  start end end indices of dry grid line (as in *.dry file)
%                       E.g. 4 5 4 10
%    * mdry, ndry    :  cell with all indices per dry grid lines (filled between 0 and 1)
%                       E.g. 4 4 4 4 4  4
%                            5 6 7 8 9 10
%    * m,n           :  all individual dry points
%    
%  <iostat> = delft3d_io_dry('write',filename,m0  ,n0  ,m1,n1,<OS>);
%  <iostat> = delft3d_io_dry('write',filename,mdry,ndry      ,<OS>);
%  <iostat> = delft3d_io_dry('write',filename,m   ,n         ,<OS>);
%
% where OS is 'u<nix>','l<inux>','d<os>' or 'w<indows>' which determines 
% the end of line character of ASCII files.
%
% Example of automatic read:
%    mdf   = delft3d_io_mdf('read',['ub40.mdf']);
%    G     = delft3d_io_grd('read',[mdf.keywords.filcco]);
%    G     = delft3d_io_dep('read',[mdf.keywords.fildep],G,'dpsopt',mdf.keywords.dpsopt);
%    G     = delft3d_io_dry('read',[mdf.keywords.fildry],G);
%    G.cen.dep = G.cen.dep.*G.cen.mask;
%    pcolorcorcen(G.cor.x,G.cor.y,G.cen.dep)
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, d3d_attrib

% Nov 2007: put smallest index first in m and n fields.
% Nov 2007: added in and output of G
% Feb 2008: changed output to accept only [m,n] or [m0,n0,m1,n1] or [mdry,ndry], improved documentation

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
  [D,iostat] = Local_read(varargin{:});
  if nargout ==1
     varargout = {D};
  elseif nargout >1
     error('too much output parameters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output parameters: 0 or 1')
  end
  if iostat<0,
     error(['Error opening file: ',varargin{1}])
  end;
end;

% ------------------------------------

function varargout = Local_read(varargin),
             
    if exist(fname,'file') & ~exist(fname,'dir')
        
      tmp         = dir(fname);
    
      D.filename        = fname;

      MNDRY = load(D.filename);
      D.m0  = min(MNDRY(:,1),MNDRY(:,3));
      D.n0  = min(MNDRY(:,2),MNDRY(:,4));
      D.m1  = max(MNDRY(:,1),MNDRY(:,3));
      D.n1  = max(MNDRY(:,2),MNDRY(:,4));
      
      for idry=1:length(D.n1)
         % mline
         if     D.m0(idry)  == D.m1(idry)
                D.ndry{idry} = D.n0(idry):D.n1(idry);
                D.mdry{idry} = D.m0(idry) + zeros(size(D.ndry{idry})); 
         % nline
         elseif D.n0(idry)  == D.n1(idry)
                D.mdry{idry} = D.m0(idry):D.m1(idry);
                D.ndry{idry} = D.n0(idry) + zeros(size(D.mdry{idry}));
         % line at 45 deg
         else
                D.mdry{idry} = D.m0(idry):D.m1(idry); 
                D.ndry{idry} = D.n0(idry):D.n1(idry);
         end
      end
   
      D.m = [];
      D.n = [];
      for idry=1:length(D.n1)
         D.m = [D.m D.mdry{idry}];
         D.n = [D.n D.ndry{idry}];
      end

      D.iostat  = 1;
      
    else
      %disp(['Dry points file ''',fname,''' does not exist.']);
      D.m  = [];
      D.n  = [];
      D.m  = [];
      D.n  = [];       
      tmp.name  = [];
      tmp.date  = [];
      tmp.bytes = [];
      D.iostat = 0;
      
    end

D.readme = 'Note: the m and n indices refer to center points in the full Delft3D matrix including the first and last dummy rows and columns for the water level points.';

if nargin==2
   
   G = varargin{2};
   
   G.files.dry.name  = tmp.name ;
   G.files.dry.date  = tmp.date ;
   G.files.dry.bytes = tmp.bytes;   
   
   G.cen.dry = zeros(size(G.cen.x));

   for ip = 1:length(D.m)
   
      %% remove one index, because the cen array does not contain dummy row
      G.cen.dry(D.n(ip)-1,D.m(ip)-1) = 1;
   
   end
   
   G.cen.mask = G.cen.dry;
   G.cen.mask(G.cen.mask==1)=NaN;
   G.cen.mask(G.cen.mask==0)=1;
    
   if nargout==2
   varargout = {G,D.iostat};   
   elseif nargout==3
   varargout = {G,D,D.iostat};   
   end

else

   varargout = {D,D.iostat};   

end


% ------------------------------------

function iostat=Local_write(fname,varargin),

%% Initialize

   iostat       = 1;
   fid          = fopen(fname,'w');

%% OS

   if nargin==4
      OS = varargin{3};
   elseif nargin==6
      OS = varargin{5};
   else
      OS = 'windows'; % or 'unix'
   end

%% Read m,n data, in one of three formats

   if nargin==5 | nargin==6
      D.m0 = varargin{1};
      D.n0 = varargin{2};
      D.m1 = varargin{3};
      D.n1 = varargin{4};
   elseif nargin==3 | nargin==4
      if iscell(varargin{1})
         D.mdry = varargin{1};
         D.ndry = varargin{2};
         D.m0 = [];
         D.n0 = [];
         for idry=1:length(D.mdry)
         idry
            D.m0 = [D.m0 D.mdry{idry}];
            D.n0 = [D.n0 D.ndry{idry}];
         end   
      else
         D.m0   = varargin{1};
         D.n0   = varargin{2};
      end
      D.m1   = D.m0;
      D.n1   = D.n0;
   end
   
   nobs  = length(D.m0);
   MNDRY = zeros([nobs 4]);

%% Write

   for iobs=1:nobs
   
      MNDRY(:,1) = D.m0(:);
      MNDRY(:,2) = D.n0(:);
      MNDRY(:,3) = D.m1(:);
      MNDRY(:,4) = D.n1(:);
      
      fprintf(fid,'%d ',MNDRY(iobs,:));
      fprinteol(fid,OS)
      
   end

%% Close

   fclose(fid);
   iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

