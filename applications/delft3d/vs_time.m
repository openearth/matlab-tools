function varargout = vs_time(NFSstruct,varargin),
%D3D_TIMEFRAME
%
% T = vs_time(NEFIS_file_handle)
% Read all time data from NEFIS into a struct.
%
% Implemented:
% - comfile   (FLOW)
% - trimfile  (FLOW)
% - trih file (FLOW)
% - hwgxyfile (WAVE)
% - trk file  (PART)
%
% T = vs_time(NEFIS_file_handle,timeindices)
% reads only the timesteps with index in timeindices:
%
% E.g. vs_time(NEFIS_file_handle,[1 2]) returns the 1st and 2nd
% times. timeindices = 0 returns all available times (default).
%
% T = vs_time(NEFIS_file_handle,timeindices,1) returns only
% a matlab datenum values array.
%
% - nt          # simulated timesteps
% - nt_storage  # timesteps in NEFIS file
% - nt_loaded   # timesteps loaded from NEFIS file
%
% See also: vs_use, vs_get, vs_let, vs_disp

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
%   USA
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

if nargin>1
   Tindex = varargin{1};
else
   Tindex = 0;
end    

if nargin>2
   simple = varargin{2};
else
   simple = 0;
end    

if strcmp(NFSstruct.SubType,'Delft3D-trim')
%% -------------------------------------------

      T.t0            = vs_get  (NFSstruct,'map-const', 'ITDATE','quiet');
      % Reference date
      T.itdate0       = num2str(T.t0(1));
      % Reference time [s]
      T.s0            = T.t0(2);
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct,'map-const', 'TUNIT' ,'quiet');
      % Computational time step of simulation [tunit]
      T.dt_simulation = vs_let  (NFSstruct,'map-const', 'DT'    ,'quiet');
      % Computational time step of simulation [s]
      T.dt_simulation = T.dt_simulation*T.tunit;

      % Sequence numbers of simulation results in NFSstruct [#]
      T.nt_storage    = vs_get_grp_size(NFSstruct,'map-info-series');
      T.it            = (1:T.nt_storage)';

      if ~Tindex==0
      T.it            = T.it(Tindex);
      else
      Tindex          = 1:T.nt_storage;
      end

      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct,'map-info-series',{Tindex},'ITMAPC','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.dt_simulation;
      
      %% determine dt_storage, if possible
      %% ---------------------------------
      
      if length(Tindex)==1
         if T.nt_storage >1
            tmp.t              = vs_let  (NFSstruct,'map-info-series',{1:2},'ITMAPC','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t              = tmp.t.*T.dt_simulation;
            T.dt_storage       = diff(tmp.t(1:2));
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end

elseif strcmp(NFSstruct.SubType,'Delft3D-com')
%% -------------------------------------------

%% many rtime can be written
%% but only one is kept all the time
%% during only coupling to WAQ or WAVE

      % Reference date
      T.itdate0       = num2str(vs_let  (NFSstruct, 'PARAMS'   , 'IT01',  'quiet'));
      % Reference time [s]
      T.s0            = vs_let  (NFSstruct, 'PARAMS'   , 'IT02',  'quiet');
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct, 'PARAMS'   , 'TSCALE','quiet');
      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct, 'CURTIM'   , {Tindex},'TIMCUR','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.tunit;
      % Number of simulation results in NFSstruct [#]
      T.nt_storage    = vs_let  (NFSstruct, 'CURNT'    , 'NTCUR', 'quiet');

      %% determine dt_storage, if possible
      %% ---------------------------------
      
      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end      
      
      if length(Tindex)==1
         if T.nt_storage >1
            % Time numbers of simulation results in NFSstruct [tunit]
            tmp.t             = vs_let  (NFSstruct, 'CURTIM'   , {1:2},'TIMCUR','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t             = tmp.t.*T.tunit;
            T.dt_storage       = diff(tmp.t(1:2));
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         disp('Only one timestep, cannot determine ''dt_storage'' ...')
      end

elseif strcmp(NFSstruct.SubType,'Delft3D-hwgxy')
%% -------------------------------------------

      % Reference date
      T.itdate0       = num2str(vs_let  (NFSstruct, 'PARAMS'   , 'IT01',  'quiet'));
      % Reference time [s]
      T.s0            = vs_let  (NFSstruct, 'PARAMS'   , 'IT02',  'quiet');
      % Basic time unit [s]
      T.tunit         = vs_let  (NFSstruct, 'PARAMS'   , 'TSCALE','quiet');

      % Time numbers of simulation results in NFSstruct [tunit]
      T.t             = vs_let  (NFSstruct, 'map-series', {Tindex},'TIME','quiet');
      % Time numbers of simulation results in NFSstruct [s]
      T.t             = T.t.*T.tunit;

      % Number of simulation results in NFSstruct [#]
      T.nt_storage    = vs_get_grp_size(NFSstruct,'map-series');
      
      T.it            = (1:T.nt_storage)';
      if ~Tindex==0
      T.it            = T.it(Tindex);
      else
      Tindex          = 1:T.nt_storage;
      end      
      
      %% determine dt_storage, if possible
      %% ---------------------------------
      
      if length(Tindex)==1
         if T.nt_storage >1

            % Time numbers of simulation results in NFSstruct [tunit]
            tmp.t             = vs_let  (NFSstruct, 'map-series', {1:2},'TIME','quiet');
            % Time numbers of simulation results in NFSstruct [s]
            tmp.t             = tmp.t.*T.tunit;
            
            T.dt_storage       = diff(tmp.t(1:2));
            
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end      
      
 
 elseif strcmp(NFSstruct.SubType,'Delft3D-trih')
 %% -------------------------------------------
     
      T.itdate        = vs_let(NFSstruct,'his-const '     ,'ITDATE',{0});
      T.dt_simulation = vs_let(NFSstruct,'his-const '     ,'DT'    ,{0});
      T.tunit         = vs_let(NFSstruct,'his-const '     ,'TUNIT' ,{0});
      T.t             = vs_let(NFSstruct,'his-info-series',{Tindex},'ITHISC',{0});
      T.t             = T.t.* T.dt_simulation.* T.tunit;
      T.nt_storage    = vs_get_grp_size(NFSstruct,'his-series'); % ???????????

      T.s0            = T.itdate(2);
      T.itdate0       = num2str(T.itdate(1));
      
      %% determine dt_storage, if possible
      %% ---------------------------------
      
      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end      

      if length(Tindex)==1
         if T.nt_storage >1

            tmp.t              = vs_let(NFSstruct,'his-info-series',{1:2},'ITHISC',{0});
            tmp.t              = tmp.t.* T.dt_simulation.* T.tunit;
            
            T.dt_storage       = diff(tmp.t(1:2));
            
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end        
      
 elseif strcmp(NFSstruct.SubType,'Delft3D-track')
 %% -------------------------------------------
     
      T.itdate        = vs_let(NFSstruct,'trk-const'     ,'ITDATE',{0});
      T.itdate0       = num2str(T.itdate(1));
      T.dt_simulation = vs_let(NFSstruct,'trk-const'     ,'DT'    ,{0});
      T.tunit         = vs_let(NFSstruct,'trk-const'     ,'TUNIT' ,{0});
      T.t             = vs_let(NFSstruct,'trk-info-series',{Tindex},'ITTRKC',{0});
      T.t             = T.t.*T.dt_simulation.*T.tunit;
      T.nt_storage    = vs_get_grp_size(NFSstruct,'trk-series');

      T.s0            = T.itdate(2);
      T.itdate0       = num2str(T.itdate(1));
      
      %% determine dt_storage, if possible
      %% ---------------------------------
      
      if (Tindex==0)
      Tindex          = 1:T.nt_storage;
      end      

      if length(Tindex)==1
         if T.nt_storage >1

            tmp.tunit         = vs_let(NFSstruct,'trk-const'     ,'TUNIT' ,{0});
            tmp.t             = vs_let(NFSstruct,'trk-info-series',{1:2},'ITTRKC',{0});
            
            T.dt_storage       = diff(tmp.t(1:2));
            
         else
            disp('Only one timestep, cannot determine ''dt_storage'' ...')
         end
      else
         T.dt_storage       = diff(T.t(1:2));
      end        

 end
 %% -------------------------------------------
  
      T.y0            = str2num(T.itdate0(1:4));
      T.m0            = str2num(T.itdate0(5:6));
      T.d0            = str2num(T.itdate0(7:8));
      T.h0            = 0;
      T.mi0           = 0;      
   
%   try
%   T.dt_storage       = diff(T.t(1:2));
%   catch
%       disp('Only one timestep, cannot determine ''dt_storage'' ...')
%   end
   
   % Number of simulation results in NFSstruct [#]
   % If run crashes it contains not all timesteps:
   T.nt_loaded     = min(length(T.t),T.nt_storage);

   T.datenum0         = datenum(T.y0 ,T.m0 ,T.d0,...
                                T.h0 ,T.mi0,T.s0);

   T.datenum          = datenum(T.y0 ,T.m0 ,T.d0,...
                                T.h0 ,T.mi0,T.s0 + T.t);

%% remember input file as meta info
%% for later version checking
%% ------------------------

  %T.NFSstruct = NFSstruct;
   T.FileName  = NFSstruct.FileName;

   if simple
       varargout  = {T.datenum};
   else
       varargout  = {T};
   end