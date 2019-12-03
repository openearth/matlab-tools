function varargout = Dispersion_Relations_shell_read(fname)
%DISPERSION_RELATIONS_SHELL_READ   reads output of DOS executable
%
% Struct_out = DISPERSION_RELATIONS_SHELL_READ(fname)
%
% where fname is the filename. 
%
% Note that the returned wave numbers are complex.
%
%See also: GADE_1958, WAVEDISPERSION, DISPERSION_RELATIONS_SHELL

%% TO DO: make *.dll with individual Dispersion_Relations functions

% Uses:
% * fgetl_no_comment_line

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl / gerben.deboer@deltares.nl	
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

%% Read output file
%------------------------

tmp = dir(fname);

if length(tmp)==0

   disp(['Error finding file ',fname])
   
   iostat = -1;
   S      = [];
   
else

   fid    = fopen(fname,'r');
   
   if fid==-1

      disp(['Error opening file ',fname])
      iostat = -2;
      S      = [];

   else
   
      disp(['Reading file ',fname,', please wait ...'])

      record      = fgetl_no_comment_line(fid,'%');
      
      sz          = str2num(record); % length columns dims dimensions
      sz0         = sz(4:end);
      ndim        = sz(3);
      sz          = sz(1:2);
      
      S.T         = repmat(nan,[1 sz(1)]);
      S.Omega     = repmat(nan,[1 sz(1)]);
      S.hw        = repmat(nan,[1 sz(1)]);
      S.hm        = repmat(nan,[1 sz(1)]);
      S.rhow      = repmat(nan,[1 sz(1)]);
      S.rhom      = repmat(nan,[1 sz(1)]);
      S.nuw       = repmat(nan,[1 sz(1)]);
      S.num       = repmat(nan,[1 sz(1)]);
      
      S.kguo      = repmat(nan,[1 sz(1)]);
      S.kgade     = repmat(nan,[1 sz(1)]);
      S.ksv       = repmat(nan,[1 sz(1)]);
      S.kdewit    = repmat(nan,[1 sz(1)]);
      S.kdelft    = repmat(nan,[1 sz(1)]);
      S.kdalr     = repmat(nan,[1 sz(1)]);
      S.kng       = repmat(nan,[1 sz(1)]);
      
      %% with fscanf line is 1st dimension
      %% while we want column to be first dimension
     [RAW,count] = fscanf(fid,'%f',[sz(2) sz(1)]);
      RAW         = RAW';
      
      S.T         = reshape( RAW(:, 1),sz0(1:end-1));
      S.Omega     = reshape( RAW(:, 2),sz0(1:end-1));
      S.hw        = reshape( RAW(:, 3),sz0(1:end-1));
      S.hm        = reshape( RAW(:, 4),sz0(1:end-1));
      S.rhow      = reshape( RAW(:, 5),sz0(1:end-1));
      S.rhom      = reshape( RAW(:, 6),sz0(1:end-1));
      S.nuw       = reshape( RAW(:, 7),sz0(1:end-1));
      S.num       = reshape( RAW(:, 8),sz0(1:end-1));
      S.kguo      = reshape( RAW(:, 9),sz0(1:end-1));
      S.kgade     = reshape((RAW(:,10) + RAW(:,11).*i),sz0(1:end-1));
      S.ksv       = reshape((RAW(:,12) + RAW(:,13).*i),sz0(1:end-1));
      S.kdewit    = reshape((RAW(:,14) + RAW(:,15).*i),sz0(1:end-1));
      S.kdelft    = reshape((RAW(:,16) + RAW(:,17).*i),sz0(1:end-1));
      S.kdalr     = reshape((RAW(:,18) + RAW(:,19).*i),sz0(1:end-1));
      S.kng       = reshape((RAW(:,10) + RAW(:,21).*i),sz0(1:end-1));
      
    %  S.T         = reshape( RAW( 1,:),sz0(1:ndim-1));
    %  S.Omega     = reshape( RAW( 2,:),sz0(1:ndim-1));
    %  S.H         = reshape( RAW( 3,:),sz0(1:ndim-1));
    %  S.D         = reshape( RAW( 4,:),sz0(1:ndim-1));
    %  S.rhow      = reshape( RAW( 5,:),sz0(1:ndim-1));
    %  S.rhom      = reshape( RAW( 6,:),sz0(1:ndim-1));
    %  S.nuw       = reshape( RAW( 7,:),sz0(1:ndim-1));
    %  S.num       = reshape( RAW( 8,:),sz0(1:ndim-1));
    %  S.kguo      = reshape( RAW( 9,:),sz0(1:ndim-1));
    %  S.kgade     = reshape((RAW(10,:) + RAW(11,:).*i),sz0(1:ndim-1));
    %  S.ksv       = reshape((RAW(12,:) + RAW(13,:).*i),sz0(1:ndim-1));
    %  S.kdewit    = reshape((RAW(14,:) + RAW(15,:).*i),sz0(1:ndim-1));
    %  S.kdelft    = reshape((RAW(16,:) + RAW(17,:).*i),sz0(1:ndim-1));
    %  S.kdalr     = reshape((RAW(18,:) + RAW(19,:).*i),sz0(1:ndim-1));
    %  S.kng       = reshape((RAW(10,:) + RAW(21,:).*i),sz0(1:ndim-1));

      fclose(fid);
   
   end % error opening file (iostat=-2
   
end % error finding file (iostat=-1) 
   
%% Output
%------------------------

   if nargout==1
      varargout = {S};
   elseif nargout==2
      varargout = {S,iostat};
   end

%% EOF   