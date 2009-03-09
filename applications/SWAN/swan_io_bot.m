function varargout = swan_io_bot(cmd,fname,varargin)
%SWAN_IO_BOT    read/write SWAN ASCII bottom file   (BETA VERSION)
%
% dep = swan_io_bot('read' ,fname,[mcx myc],<IDLA>)
% dep = swan_io_bot('read' ,fname,struct ,<IDLA>)
%
% dep = swan_io_bot('load' ,fname,[mcx myc],<IDLA>)
% dep = swan_io_bot('load' ,fname,struct ,<IDLA>)
%
% dep = swan_io_bot('write',fname,dep    ,<IDLA>)
%
%    where struc has fields 'mcx','myc'
%    which can be obtained by reading the associated *.swn input 
%    file with swan_input.
%    NOTE 1. mxc and myc are number of meshes, which are one 
%     less then the number of nodes in the file !!
%    NOTE 2. mxc and myc are 2 smaller
%     than mmax and nmax mentioned in the Delft3d-FLOW mdf file, as
%     the Delft3d-FLOW adds one dummy row and column of nodes.
%
%    dep does not contain any nodatavlues as all
%    values are filled with nearest interpolation.
%    
%    IDLA determiens how the dep array is swapped
%    before writing or after reading, default IDLA=4.
%    Currently implemented are:
%    * read : IDLA=3,4
%    * write: IDLA=4 with an end of line after eveyr 4 numbers
%             becauase only 120 characters are allowed per line.
%    
%    % valid for IDLA  = 3
%    % ---------------------------
%    % (1,1   )  (2,1)   (mmax,1)
%    % (1,2   )  (2,2)   (mmax,2)
%    % (1,nmax)          (mmax,1)   
%    
%    % valid for IDLA  = 4, same as 3, but no new lines required.
%    % ---------------------------
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

   nodatavalue = -.999000E+03;
   IDLA        = 4;
   
if     strcmp(cmd,'read') | ...
       strcmp(cmd,'load')
       
   %% Input
   %% ------------------------------

   if isstruct(varargin{1})
      cgrid = varargin{1};
      mxc   = cgrid.mxc ;
      myc   = cgrid.myc ;
      if nargin>3
       IDLA = varargin{2};
      end
   else
      mxc   = varargin{1}(1);
      myc   = varargin{1}(2);
      if nargin>4
       IDLA = varargin{2};
      end
   end

   mmax = mxc + 1; % mxc is number of meshes, we want number of nodes mmax
   nmax = myc + 1; % mxc is number of meshes, we want number of nodes nmax
   
   if nargin>5
      error('syntax: dep = swan_io_bot(''read'',filename,mnmax,<IDLA>');
   end
   
   %% Read and open file
   %% ------------------
   
   fid = fopen(fname);
   dat = fscanf(fid,'%g',mmax*nmax);
   fclose(fid); %dat = load(fname); % does not work when not all lines have same number of elements
   dat(dat ==nodatavalue)=nan;
   dep = reshape(dat',[mmax nmax]);
   
   varargout = {dep};

elseif strcmp(cmd,'write')

   %% Input
   %% ------------------

   if nargin>2
      dep  = varargin{1};
   end
   
   if nargin>3
      IDLA = varargin{2};
   end
   
   if nargin>4
      error('syntax: dep = swan_io_bot(''write'',filename,mnmax,<IDLA>');
   end
   
   dep(isnan(dep)) = nodatavalue;

   if IDLA==4
      
    %  %% only works when all lines are full
    %  leng = prod(size(dep))./4;
    %  dep  = reshape(dep,[4 leng])';
    %  %% check whether the maximum lenght of file lines =  120 characters?
    %  save(fname,'dep','-ascii')
      
      fid = fopen(fname,'w');
      
      npoints         = length(dep(:));
      
      %nlines          = floor(npoints./4);
      %pointslastline  = 1:(npoints - 4*nlines);
      %format          = '%8.6E %8.6e %8.6e %8.6e\n';
      
      pointsperline   = 4;
      nlines          = floor(npoints./pointsperline);
      pointslastline  = 1:(npoints - pointsperline*nlines);
      format          = [repmat('%8.6E ',[1 pointsperline      ]),'\n'];
      if ~isempty(pointslastline)
      formatlastline  = [repmat('%8.6E ',[1 pointslastline(end)]),'\n'];
      end
      
      for iline=1:nlines
         fprintf(fid,format,dep((iline-1).*pointsperline + [1:pointsperline]));
      end
         
      if ~isempty(pointslastline)
         fprintf(fid,formatlastline,dep((iline).*pointsperline + pointslastline));
      end
         
      fclose(fid);
      
   end

   varargout = {1};

end   

%% EOF