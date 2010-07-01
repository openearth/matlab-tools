function varargout=delft3d_io_bch(cmd,varargin),
%DELFT3D_IO_BCH   read/write open boundaries (*.bch) <<beta version!>>
%
%  DATA=delft3d_io_bch('read' ,filename);
%
%       delft3d_io_bch('write',filename,DATA);
% where DATA has fields:
%
%   DATA.phases     (n_endpoints x n_boundaries x n_frequencies) in [deg]
%   DATA.amplitudes (n_endpoints x n_boundaries x n_frequencies) in [data units]
%   DATA.a0         (n_endpoints x n_boundaries                ) in [data units]
%   DATA.frequencies(n_frequencies                             ) in [deh/hr]
%
% G.J. de Boer, Feb 2006.
%
% See also: delft3d_io_ann, delft3d_io_bca, delft3d_io_bch, delft3d_io_bnd, 
%           delft3d_io_crs, delft3d_io_dep, delft3d_io_dry, delft3d_io_eva, 
%           delft3d_io_fou, delft3d_io_grd, delft3d_io_ini, delft3d_io_mdf, 
%           delft3d_io_obs, delft3d_io_restart,             delft3d_io_src, 
%           delft3d_io_tem, delft3d_io_thd, delft3d_io_wnd, 

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
     error('too much output paramters: 0 or 1');
  end
  if STRUCT.iostat<0,
     disp(['Error opening file: ',varargin{1}]);
     STRUCT.iostat = -1;
  end;
  
case 'write',
  iostat=Local_write(varargin{:});
  if nargout ==1
     varargout = {iostat};
  elseif nargout >1
     error('too much output paramters: 0 or 1');
  end
  if iostat<0,
     error(['Error writing file: ',varargin{1}]);
  end;
end;

% ------------------------------------
% ------------------------------------
% ------------------------------------

function STRUCT=Local_read(varargin),

STRUCT.filename  = varargin{1};

fid              = fopen(STRUCT.filename,'r');
if fid==-1
   STRUCT.iostat = fid;
else
   STRUCT.iostat = -1;
   i             = 0;
   

   STRUCT.frequencies = str2num(fgetl(fid));
   STRUCT.data        = fscanf(fid,'%f');
   
   STRUCT.nof    = length(STRUCT.frequencies);
   frequency0    = find(STRUCT.frequencies==0);
   frequencyrest = find(~(STRUCT.frequencies==0));
   n_freq_data0  = length(frequency0);
   STRUCT.nobnd  = prod(size(STRUCT.data))./(2*STRUCT.nof-n_freq_data0)/2;
   
   %% Read constant a0 (frequency = 0)
   %% ----------------------

   indexa01 = [                            1:...
                                STRUCT.nof  :...
                  STRUCT.nobnd.*STRUCT.nof  ] + frequency0-1;   
   indexa02 = [   STRUCT.nobnd.*STRUCT.nof+1:...
                                STRUCT.nof  :...
               2.*STRUCT.nobnd.*STRUCT.nof  ] + frequency0-1;   

   STRUCT.a0(1,:,:) = STRUCT.data(indexa01);   
   STRUCT.a0(2,:,:) = STRUCT.data(indexa02);   
   
   %% Remove constant a0 (frequency = 0)
   %% ----------------------

   STRUCT.data(indexa01)=nan;
   STRUCT.data(indexa02)=nan;
   STRUCT.data = STRUCT.data(~isnan(STRUCT.data));
   
   %% Read amplitudes
   %% ----------------------
 
   amplitudesA = STRUCT.data(                                           1:...
                                (STRUCT.nof-n_freq_data0).*STRUCT.nobnd  );
   amplitudesB = STRUCT.data(   (STRUCT.nof-n_freq_data0).*STRUCT.nobnd+1:...
                             2.*(STRUCT.nof-n_freq_data0).*STRUCT.nobnd  );
   
   STRUCT.amplitudes(1,:,:) = reshape(amplitudesA,[(STRUCT.nof-n_freq_data0),STRUCT.nobnd])';
   STRUCT.amplitudes(2,:,:) = reshape(amplitudesB,[(STRUCT.nof-n_freq_data0),STRUCT.nobnd])';
   
   offset =2*STRUCT.nobnd*(STRUCT.nof-n_freq_data0);
   
   %% Read phases
   %% ----------------------
   
   phasesA = STRUCT.data(                                               1+offset:...
                                (STRUCT.nof-n_freq_data0).*STRUCT.nobnd  +offset);
                                
   phasesB = STRUCT.data(       (STRUCT.nof-n_freq_data0).*STRUCT.nobnd+1+offset:...
                             2.*(STRUCT.nof-n_freq_data0).*STRUCT.nobnd  +offset);
   
   STRUCT.phases(1,:,:) = reshape(phasesA,[(STRUCT.nof-n_freq_data0),STRUCT.nobnd])';
   STRUCT.phases(2,:,:) = reshape(phasesB,[(STRUCT.nof-n_freq_data0),STRUCT.nobnd])';

   STRUCT.iostat   = 1;
   STRUCT.NTables  = i;
end



% ------------------------------------
% ------------------------------------
% ------------------------------------

function iostat=Local_write(filename,STRUCT),

iostat         = 1;
fid            = fopen(filename,'w');
OS             = 'windows'; % or 'unix'
fprintf_format = ' %9.6g';
fprintf_spaces = '          ';

   %% A0?
   %% ----------------------
   if isfield(STRUCT,'a0')
   
      STRUCT.frequencies = [0 STRUCT.frequencies];
   end

   %% FREQUENCIES
   %% ----------------------

   fprintf(fid,fprintf_format,STRUCT.frequencies); % extra space before value: ' %9.6f'
   fprinteol(fid,OS(1))
   fprinteol(fid,OS(1))

   %% AMPLITUDES and A0
   %% ----------------------
   for i=1:size(STRUCT.amplitudes,1)
      for j=1:size(STRUCT.amplitudes,2)
         if isfield(STRUCT,'a0')
         fprintf(fid,fprintf_format,STRUCT.a0        (i,j,1)); % extra space before value: ' %9.6f'
         end
         fprintf(fid,fprintf_format,STRUCT.amplitudes(i,j,:)); % extra space before value: ' %9.6f'
         fprinteol(fid,OS(1))
      end
   end;

   fprinteol(fid,OS(1))
   
   %% PHASES
   %% ----------------------

   for i=1:size(STRUCT.phases,1)
      for j=1:size(STRUCT.phases,2)
         if isfield(STRUCT,'a0')
         fprintf(fid,fprintf_spaces);
         end
         fprintf(fid,fprintf_format,STRUCT.phases(i,j,:)); % extra space before value: ' %9.6f'
         fprinteol(fid,OS(1))
      end
   end;
   
   fprinteol(fid,OS(1))

fclose(fid);
iostat=1;

% ------------------------------------
% ------------------------------------
% ------------------------------------

