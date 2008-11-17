function ux2dos(files_in,varargin)
%UX2DOS   Change all end-of-line characters of ASCII files to DOS-type
%
% UX2DOS(files_in,files_out)
% where files_in and files_out are a cell or character 
% str of the filenames to be processed.
%
% UX2DOS(files_in)
% where files_out is set to files_in, and files_in
% are backup-ed to files_in.bak
%
% © Deltares, G.J. de Boer, 2008.
%
%See also: FPRINTEOL, DOS2UX, PATH2OS.

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl (g.j.deboer@tudelft.nl)
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherland
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


   %% Input
   %% -------------------------

   if ischar(files_in)
      files_in  = cellstr(files_in);
   end

   if nargin==1
      files_out = files_in;
      backup    = 1;
      disp('Files are overwritten with different end-of-line characters.')
   else
      files_out = varargin{1};
      backup    = 0;
      if ischar(files_out)
         files_out = cellstr(files_out);
      end
      if ~(length(files_in)==length(files_out))
         error('files_in has not same size as files_out')
      end
   end

   %% READ file
   %% -------------------------
   for ifile=1:length(files_in)
      file_in  = files_in{ifile};
      fid      = fopen(file_in,'r');
      nline    = 0;
      while 1
         rec                 = fgetl(fid);
         if ~ischar(rec)
            break
         else
            nline            = nline + 1;
            textlines{nline} = rec;
         end
      end
      fclose(fid);
      
   end

   %% WRITE file
   %% -------------------------
      
   for ifile=1:length(files_in)
      file_in  = files_in {ifile};
      file_out = files_out{ifile};

      if backup
         copyfile(file_in,[file_in,'.bak']);
      end
      
      fid      = fopen(file_out,'w');
      for iline=1:length(textlines)
         fprintf  (fid,textlines{iline});
         fprinteol(fid,'d')
      end
      fclose(fid);

   end

%% EOF