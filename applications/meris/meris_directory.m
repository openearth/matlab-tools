function varargout = meris_directory(directory,varargin)
%MERIS_DIRECTORY   retrieves all image and SIOP names from directory with meris images
%
%  IMAGE_names             = MERIS_DIRECTORY(directory,<extension>)
% [IMAGE_names,SIOP_names] = MERIS_DIRECTORY(directory,<extension>)
%
% Example: a directory with the following 2 files:
%
%   MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089Belgica2000SubT.mat
%   MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089Restwes99Oroma02SubT.mat
%
% would give 1 NAME and 2 SIOPS:
%
%   IMAGE_names = {'MER_FR__2PNUPA20060630_102426_000000982049_00051_22650_5089'};
%   SIOP_names  = {'Belgica2000SubT','Restwes99Oroma02SubT'};
%
% The default for the optional <extension> is '.mat'.
%
%See also: MERIS_NAME2META, MERIS_FLAGS, MERIS_MASK

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Dec. Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------


      ext = '.mat';
   if nargin>1
      ext = varargin{1};
   end
   
   dirlist = dir([directory,filesep,'*',ext]);
   iname   = 0;
   isiop   = 0;
   
   %% Check for double occurences of images after removal of extensions (SIOPS)
   %% ----------------------------------
   
   for ifile=2:length(dirlist)
   
      meris.name = dirlist(ifile).name( 1:59 );
      meris.siop = dirlist(ifile).name(60:end);
      
      if iname==0
      
         NAMEs{1} = meris.name;
         iname    = 1;
   
      else
      
         if ~any(strcmp(NAMEs,meris.name))
            iname         = iname + 1;
            NAMEs{iname} = meris.name;
         end
   
      end
      
      %% Check for double occurences of extensions (SIOPS)
      %% ----------------------------------

         if ~isempty(meris.siop)
         
            if isiop==0
   
               SIOPs{1}   = meris.siop;
               isiop      = 1;
               
            else
         
               if ~any(strcmp(SIOPs,meris.siop))
                  isiop        = isiop+ 1;
                  SIOPs{isiop} = meris.siop;
               end
            
            end
            
         end
   
   end
   
   %% Output
   %% ----------------------------------

   if nargout<2
      varargout = {NAMEs};
   else
      varargout = {NAMEs,SIOPs};
   end

%% EOF