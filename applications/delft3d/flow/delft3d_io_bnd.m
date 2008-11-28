function varargout=delft3d_io_bnd(cmd,varargin),
%DELFT3D_IO_BND   read/write open boundaries (*.bnd) <<beta version!>>
%
%  DATA=delft3d_io_bnd('read' ,filename);
%  DATA=delft3d_io_bnd('read' ,filename,mmax,nmax);
%
%       delft3d_io_bnd('write',filename,DATA);
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd,
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva,
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf,
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src,
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd,
%           bct2bca

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

% 2008 Nov 28: * corrected test for 3d-profile (missing dash) [Yann Friocourt]
%
% 2008 Jul 11: * made it work when Labels have length < 11 [Anton de Fockert]
%              * removed useless threeD keyword [Anton de Fockert]

if nargin ==1
   error(['At least 2 input arguments required: delft3d_io_bnd(''read''/''write'',filename)'])
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

%if nargin==2 | nargin==4
%   threeD    = varargin{2};
%else
%   threeD    = 0;
%end

   mmax = Inf;
   nmax = Inf;
if nargin==3
   mmax = varargin{2};
   nmax = varargin{3};
elseif nargin==4
   mmax = varargin{3};
   nmax = varargin{4};
end

fid          = fopen(STRUCT.filename,'r');
if fid==-1
   STRUCT.iostat   = fid;
else
   STRUCT.iostat   = -1;
   i            = 0;

   while ~feof(fid)

      i = i + 1;

      STRUCT.DATA(i).name         = fscanf(fid,'%20c',1);
      STRUCT.DATA(i).bndtype      = fscanf(fid,'%1s' ,1);
      STRUCT.DATA(i).datatype     = fscanf(fid,'%1s' ,1);
      STRUCT.DATA(i).mn           = fscanf(fid,'%i'  ,4);

      % turn the endpoint-description along gridlines into vectors

      [STRUCT.DATA(i).m,...
       STRUCT.DATA(i).n]=meshgrid(STRUCT.DATA(i).mn(1):STRUCT.DATA(i).mn(3),...
                                  STRUCT.DATA(i).mn(2):STRUCT.DATA(i).mn(4));

      if STRUCT.DATA(i).mn(1)==mmax+1
         STRUCT.DATA(i).mn(1)= mmax;
      end
      if STRUCT.DATA(i).mn(2)==nmax+1
         STRUCT.DATA(i).mn(2)= nmax;
      end
      if STRUCT.DATA(i).mn(3)==mmax+1
         STRUCT.DATA(i).mn(3)= mmax;
      end
      if STRUCT.DATA(i).mn(4)==nmax+1
         STRUCT.DATA(i).mn(4)= nmax;
      end

      STRUCT.DATA(i).alfa         = fscanf(fid,'%f'  ,1);

      rec = fgetl(fid);

      %if threeD
      if strcmpi('C',STRUCT.DATA(i).bndtype) | ...
         strcmpi('Q',STRUCT.DATA(i).bndtype) | ...
         strcmpi('T',STRUCT.DATA(i).bndtype) | ...
         strcmpi('R',STRUCT.DATA(i).bndtype)

     [STRUCT.DATA(i).vert_profile,rec] = strtok(rec); %,fscanf(fid,'%20c',1);

        if strcmpi(STRUCT.DATA(i).vert_profile,'3D')

        [dummy,rec] = strtok(rec); %,fscanf(fid,'%20c',1);

         STRUCT.DATA(i).vert_profile = '3d-profile';

        end

        if ~(strcmpi(STRUCT.DATA(i).vert_profile,'uniform')     | ...
             strcmpi(STRUCT.DATA(i).vert_profile,'Logarithmic') | ...
             strcmpi(STRUCT.DATA(i).vert_profile,'3d-profile'))

           error(['Not a valid profile: ''',STRUCT.DATA(i).vert_profile])

        end

      end
      %end

      if strcmp('A',STRUCT.DATA(i).datatype)


         [STRUCT.DATA(i).labelA,rec]  = strtok(rec); %[letter,fscanf(fid,'%11c',1)];
          STRUCT.DATA(i).labelB       = strtok(rec); %[letter,fscanf(fid,'%11c',1)];

      end

   end

   STRUCT.iostat   = 1;
   STRUCT.NTables  = i;

   %% (m,n) coordinates as used for D3D matrices with dummy rows and columns
   %% ---------------------------

   for i=1:STRUCT.NTables
      STRUCT.m(i,:) = [STRUCT.DATA(i).mn(1) STRUCT.DATA(i).mn(3)];
      STRUCT.n(i,:) = [STRUCT.DATA(i).mn(2) STRUCT.DATA(i).mn(4)];
   end

   STRUCT.m(i,:) = [STRUCT.DATA(i).mn(1) STRUCT.DATA(i).mn(3)];
   STRUCT.n(i,:) = [STRUCT.DATA(i).mn(2) STRUCT.DATA(i).mn(4)];

   %% (m,n) coordinates as used for matrices without dummy rows
   %% boundaries defined at faces (so each segment is spanned between two corners)
   %% ---------------------------

   fclose(fid);
   iostat=1;

end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat       = 1;
fid          = fopen(filename,'w');
OS           = 'windows';

for i=1:length(STRUCT.DATA)

   fprintfstringpad(fid,20,STRUCT.DATA(i).name,' ');

   fprintf(fid,'%1c',' ');
   % fprintf automatically adds one space between all printed variables
   % within one call
   fprintf(fid,'%1c %1c %5i %5i %5i %5i %f',...
           STRUCT.DATA(i).bndtype ,...
           STRUCT.DATA(i).datatype,...
           STRUCT.DATA(i).mn(1)   ,...
           STRUCT.DATA(i).mn(2)   ,...
           STRUCT.DATA(i).mn(3)   ,...
           STRUCT.DATA(i).mn(4)   ,...
           STRUCT.DATA(i).alfa    );

   if STRUCT.DATA(i).threeD
   if strcmp('C',STRUCT.DATA(i).bndtype) | ...
      strcmp('Q',STRUCT.DATA(i).bndtype) | ...
      strcmp('T',STRUCT.DATA(i).bndtype) | ...
      strcmp('R',STRUCT.DATA(i).bndtype)

      if ~isfield(STRUCT.DATA(i),'vert_profile')
         % DEFAULT
         vert_profile = 'Uniform';
         %vert_profile = 'Logarithmic';
      else
         vert_profile = STRUCT.DATA(i).vert_profile;
      end
      fprintf(fid,'%1c',' ');
      fprintfstringpad(fid,20,vert_profile,' ');

   end
   end

   if strcmp('A',STRUCT.DATA(i).datatype)
   % print only labels for *.bca file if present
   if isfield(STRUCT.DATA(i),'labelA')
   fprintf(fid,'%12s %12s',...
           STRUCT.DATA(i).labelA,...
           STRUCT.DATA(i).labelB);
   end
   end

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

