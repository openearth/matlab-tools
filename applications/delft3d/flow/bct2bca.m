function varargout = bct2bca(bctfile,bcafile,bndfile,varargin)
%BCT2BCA          performs tidal analysis to generate *.bca from *.bct <<beta version!>>
%
%       bct2bca(bctfile,bcafile,bndfile,<keyword,value>)
% BCA = bct2bca(bctfile,bcafile,bndfile,<keyword,value>)
%
% Analyses a Delft3D FLOW *.bct file (time series boundary condition)
% into a  *.bca file (astronomic components boundary conditions).
% using the  *.bnd file (boundary definition file) and using T_TIDE.
%
% Note that the *.bnd file should contain astronomical boudnaries
% for all tiem series present in the *.bct file!!!
%
% Works for now only for 2D boundaries, not for 3D boundary specifications!
%
% The following <keyword,value> pairs are implemented (not case sensitive):
%
%    * timezone:    hours to be SUBTRACTED from to the timeseries to get UTC times.
%                   E.G. for CET set timeshift to + 1 (default 0).
%    * period:      a two element vector to specify the start and end
%                   datenumber. Make sure you obey the Rayleigh criterion.
%                   When set to NaN the entire timeserie in the bctfile is used (default).
%    * components:  set of component names (e.g.: {'K1','O1','P1','Q1','K2','M2','N2','S2'}) 
%                   By default t_tide selects components based on Rayleigh criterion.
%                   NOTE 1. names in delft3d and t_tide are different, and 
%                           are mapped via preliminary T_TIDE_NAME2DELFT3D
%                   NOTE 2. Not all components you specify have to be present
%                           in the *.bca file, depending on the automatic Rayleigh 
%                           criterion selection by T_TIDE.
%
%    * A0      :    include mean component A0 in *.bca (default 1)
%                   Note: t_tide does not generally return an A0 component.
%    * latitude:    [] default (same effect as none in t_tide)
%
%                   NOTE THAT ANY LATITUDE IS REQUIRED FOR T_TIDE TO INCLUDE NODAL FACTORS AT ALL
%
%    * shallow:     see t_tide (default '')
%    * secular:     see t_tide (default 'mean')    
%
%    * infername  = see t_tide (default {}), can be passed as cell array, e.g. {'P1';'K2';'NU2'}.
%    * inferfrom  = see t_tide (default {}), can be passed as cell array, e.g. {'K1';'S2';'N2' }.
%    * infamp     = see t_tide (default []),                              e.g. [0.295;0.276;0.215].
%    * infphase   = see t_tide (default []),                              e.g. [-13.8;-13.7;3.6].
%
%    * method:      't_tide' (default)
%
%    * plot:        0/1 to plot time series and residue (default 1)
%                   combine this with either pause or export to te bale to actually inspect the plots
%    *   pause:     0/1 to pause after each plot (default 1)
%    *   export:    0/1 to print plot (default 0)
%
%    * output:      where to send printed output:
%                   'none'    (no printed output)
%                   'screen'  (to screen) - default
%                   1         (to a separate file per analysed time series, for which the 
%                              name differs per boundary support endpoint. DO not use a 
%                              file name here, that will be rewritten every time!!)
%
%    * residue:     Writes bct of residual  time series (value is name of *.bct file, default [])
%    * prediction:  Writes bct of predicted time series (value is name of *.bct file, default [])
%
%    * unwrap:      Delft3D programmers in the past deciced to interpolate 
%                   the phases inside a boundary segment linearly (as a scalar) 
%                   without correction  for the generally-known phase range 
%                   [0 360]: so the average of 359 and 1 will end up as 180 
%                   rather than 360. Therefore this bct2bch makes sure 
%                   that the two phase values along one boundary can be 
%                   interpolated linearly where [359 1] should be specified as
%                   [359 361]. logical, default 1.
%
%                   Note. The end points of two subsequent boudnaries are not the same, they are defined on 
%                   the adjacent waterlevel points, not on the common corner point !
%
%    OPT = bct2bca returns struct with default <keyword,value> pairs
%
%  It is also to possible to call with all the <keyword,value> pairs as struct fields:
%  bct2bca(bctfile,bcafile,bndfile,struct)
%
% See also: BCT2BCA, DELFT3D_NAME2T_TIDE, T_TIDE_NAME2DELFT3D, 
%           TIME2DATENUM, BCT2BCH,
%           BCT_IO, DELFT3D_IO_BCA, DELFT3D_IO_BND, 
%           T_TIDE (http://www.eos.ubc.ca/~rich/)


% 2008 Feb 14  * updated to include latitude as extra parameter as suggested by Arjan Mol and Anton de Fockert
% 2008 Jul 11: * changed name of t_tide output (to prevent error due to ':' in current column name) [Anton de Fockert]
%              * added comment NOT to use a fixed output file name [Anton de Fockert]
%              * added actual bca output again [Anton de Fockert]
% 2008 Jul 21  * added inference as arguments

% Requires the following m-functions:
% - bct_io
% - delft3d_io_bca
% - delft3d_io_bnd
% - time2datenum
% - datenum2index
% - rad2deg
% - t_tide and associated stuff

% TO DO:
% - Allow for input of BCT, BND structs instead of their filenames.
% - Allow for input of BCA to be empty, to have it only returned as argument.
% - Allow t_tide_name2delft3d to return [] when there is no equivalent delft3d name

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% Defaults
%% -----------------

   H.timezone   = 0;
   H.period     = nan;
   %H.components = {'K1','O1','P1','Q1','K2','M2','N2','S2'};
   H.method     = 't_tide';
   H.A0         = 1;

   H.plot       = 1;
   H.pause      = 1;
   H.export     = 0;
   H.output     = 'screen';
   H.latitude   = [];

   H.shallow    = '';
   H.secular    = 'mean';

   H.residue    = [];
   H.prediction = [];

   H.unwrap     = 1;
   
   H.infername  = {};
   H.inferfrom  = {};
   H.infamp     = [];
   H.infphase   = [];
   
%% Return defaults
%% ----------------------

   if nargin==0
      varargout = {H};
      return
   end   
   
%% Input
%% -----------------

   if isstruct(varargin{1})
      H = mergestructs('overwrite',H,varargin{1});
   else
      iargin = 1;
      %% remaining number of arguments is always even now
      while iargin<=nargin-3,
          switch lower ( varargin{iargin})
          % all keywords lower case
          
          case 'timezone'  ;iargin=iargin+1;H.timezone   = varargin{iargin};
          case 'period'    ;iargin=iargin+1;H.period     = varargin{iargin};
          case 'components';iargin=iargin+1;H.components = varargin{iargin};
          case 'method'    ;iargin=iargin+1;H.method     = varargin{iargin};
      
          case 'plot'      ;iargin=iargin+1;H.plot       = varargin{iargin};
          case 'pause'     ;iargin=iargin+1;H.pause      = varargin{iargin};
          case 'export'    ;iargin=iargin+1;H.export     = varargin{iargin};
          case 'output'    ;iargin=iargin+1;H.output     = varargin{iargin};
          case 'latitude'  ;iargin=iargin+1;H.latitude   = varargin{iargin};
          
          case 'infername' ;iargin=iargin+1;H.infername  = varargin{iargin};
          case 'inferfrom' ;iargin=iargin+1;H.inferfrom  = varargin{iargin};
          case 'infamp'    ;iargin=iargin+1;H.infamp     = varargin{iargin};
          case 'infphase'  ;iargin=iargin+1;H.infphase   = varargin{iargin};
      
          case 'shallow'   ;iargin=iargin+1;H.shallow    = varargin{iargin};
          case 'secular'   ;iargin=iargin+1;H.secular    = varargin{iargin};
      
          case 'residue'   ;iargin=iargin+1;H.residue    = varargin{iargin};
          case 'prediction';iargin=iargin+1;H.prediction = varargin{iargin};

          case 'unwrap'    ;iargin=iargin+1;H.unwrap     = varargin{iargin};
          otherwise
            error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
          end
          iargin=iargin+1;
      end
   end
   
%% Put interference in Nx4 format required by t_tide
%% -----------------

   if ~isempty(H.infername);
      if iscell(H.infername);H.infername = pad(char(H.infername),' ',4);
      end 
   end

   if ~isempty(H.inferfrom);
      if iscell(H.inferfrom);H.inferfrom = pad(char(H.inferfrom),' ',4);
      end
   end
   
%% -----------------

   if  isempty(H.latitude);warning('No latitude passed, performing simple harmonic analysis, not tidal analysis!');end
   
   H

   OPT.bctfile   = bctfile; clear bctfile
   OPT.bcafile   = bcafile; clear bcafile 
   OPT.bndfile   = bndfile; clear bndfile 

   OPT.directory = filepathstr(OPT.bctfile);

%% Loop over boundary segments
%% ------------------------------

   BND          = delft3d_io_bnd('read',OPT.bndfile);

   disp(['Loading ',OPT.bctfile,'...']); % sometimes slow, especially moronic fixed width files with zillions of spaces as produced by NESTHDx
   BCT          = bct_io        ('read',OPT.bctfile);

   %% Write residue/prediction to bct file
   %% ----------------------

   if ~isempty(H.residue)
      BCTres = BCT;
   end
   
   if ~isempty(H.prediction)
      BCTprd = BCT;
   end

%% Loop over boundary segments = Tables
%% ------------------------------

   for itable = 1:BCT.NTables
   
      ncol = size(BCT.Table(itable).Data,2);
      
      d3d_days                  = +              BCT.Table(itable).Data(:,1)./60./24; % minutes 2 days
      
      BCT.Table(itable).datenum = + d3d_days ...
                                  + time2datenum(BCT.Table(itable).ReferenceTime) ...
                                  - H.timezone/24;
      if isnan(H.period)
         H.period = BCT.Table(itable).datenum([1 end]);
      end
   
      for icol = 2:ncol; % 1st column is date in minutes wrt the refdate
      
         %% !!!!!!!!! actually only for new endpoints, what about 3D data
      
         T.location      = BCT.Table(itable).Location;
         T.index         = datenum2index(BCT.Table(itable).datenum,H.period      );
         T.datenum       =               BCT.Table(itable).datenum(T.index,1     );
         T.quantity      =               BCT.Table(itable).Data   (T.index,icol  );
         T.quantity_name =               BCT.Table(itable).Parameter(icol).Name;
         T.quantity_unit =               BCT.Table(itable).Parameter(icol).Unit;
         T.datenum0      =               BCT.Table(itable).datenum(T.index(1    ));
         T.interval      =          diff(BCT.Table(itable).datenum(T.index([1 2])))*24;
         
         if strcmpi(H.method(1),'t') % t_tide
                     
              BASEFILENAME = [filename(BCT.FileName),'.',...
                              H.method              ,'.',...
                              T.location            ,'.',...
                       strrep(T.quantity_name,':','')]; % to be used for both t_tide *.txt files and *.png

              if isnumeric(H.output)

                             
                 if isempty(H.latitude)
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'inference' ,H.infername,H.inferfrom,H.infamp,H.infphase,...
                              'interval'  ,T.interval,...
                              'output'    ,[BASEFILENAME,'.cmp']);
                 else
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'inference' ,H.infername,H.inferfrom,H.infamp,H.infphase,...
                              'interval'  ,T.interval,...
                              'latitude'  ,H.latitude,...
                              'output'    ,[BASEFILENAME,'.cmp']);
                 end
              else
                 if isempty(H.latitude)
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'inference' ,H.infername,H.inferfrom,H.infamp,H.infphase,...
                              'interval'  ,T.interval,...
                              'output'    ,H.output);
                 else
                   [tidestruc,pout]=t_tide(T.quantity,...
                              'start'     ,T.datenum0,...
                              'inference' ,H.infername,H.inferfrom,H.infamp,H.infphase,...
                              'interval'  ,T.interval,...
                              'latitude'  ,H.latitude,...
                              'output'    ,H.output);
                 end
              end
              
            %% Take care of A0 (in components AND residue)
            %% ----------------------
            
              if H.A0
                 A0 = nanmean(T.quantity);
                 
                 tidestruc.name    = strvcat('Z0  ',tidestruc.name);
                 tidestruc.freq    = [0; ...
                                      tidestruc.freq];
                 tidestruc.tidecon = [A0 0 0 0;...
                                      tidestruc.tidecon];
	         
                 pout = pout - A0;
              end

            %% Plot
            %% ----------------------
            
            if H.plot
            
               TMP = figure;
               
                  % t_plot(T.datenum,T.quantity,pout,tidestruc)
                  plot    (T.datenum,T.quantity       ,'b','DisplayName','timeseries');
                  hold on
                  plot    (T.datenum,pout             ,'g','DisplayName','prediction');
                  plot    (T.datenum,T.quantity - pout,'r','DisplayName','residue'   );
                  legend  show
                  datetick('x')
                  xlabel  (['year: ',num2str(unique(year(xlim)))])
                  disp('Press key to continue bct2bca ...')
                  Handles.title  = title ({['Boundary location name: ',T.location]});
                  Handles.ylabel = ylabel({['Boundary series   name: ',T.quantity_name],...
                                                                       T.quantity_unit}); % is empty in NESTHD *.bct files

                  set(Handles.title ,'interpreter','none')                       
                  set(Handles.ylabel,'interpreter','none')                       
                  grid
	          
                  if H.pause
                     disp('Press key to continue ...')
                     pause
                  end
                  
                  if H.export
                     print([BASEFILENAME,'.png'],'-dpng')
                  end
               
               
               try
               close(TMP)
               end

            end
            
            %% Write residue/prediction to bct file
            %% ----------------------

            if ~isempty(H.residue)
               BCTres.Table(itable).Data(T.index,icol  ) = T.quantity - pout;
            end            

            if ~isempty(H.prediction)
               BCTprd.Table(itable).Data(T.index,icol  ) = pout;
            end            

            %% Rename to delft3d names
            %% '' when no equivalent is present
            %% ----------------------
            tidestruc.name = cellstr(tidestruc.name);
            keep           = ones(size(tidestruc.freq)); % all 1
            for j=1:length(tidestruc.name)
               tidestruc.name{j} = t_tide_name2delft3d(tidestruc.name{j});
               if isempty(tidestruc.name{j})
                  keep(j)           = 0;
               end
            end

            %% Remove components that are unknown to Delft3D (tidestruc.name='')
            %% ----------------------
            tidestruc0 = tidestruc;
            clear        tidestruc
            kept       = 0;
            for j=1:length(keep)
              if keep(j)
                kept = kept +1;
                tidestruc.name   {kept}   = tidestruc0.name   {j}  ;% {n x 1 cell}
                tidestruc.freq   (kept)   = tidestruc0.freq   (j)  ;% [n x 1 double]
                tidestruc.tidecon(kept,:) = tidestruc0.tidecon(j,:);% [n x 4 double]
              end
            end
            
            %% Use only selected components
            %% ----------------------
%             
%             mask           = 0.*[1:length(length(tidestruc.name))];
%             for j=1:length(tidestruc.name)
%                for jj=1:length(H.components)
%                   if strcmpi(strtrim(char(tidestruc.name{ j})),...
%                              strtrim(char(H.components  (jj))));
%                      mask(j) = 1;
%                   end
%                end
%             end
%             
%             mask = logical(mask);
%           tidestruc.name    = char(tidestruc.name);
%           tidestruc.name    = tidestruc.name   (mask,:);
%           tidestruc.freq    = tidestruc.freq   (mask,:);
%           tidestruc.tidecon = tidestruc.tidecon(mask,:);
            
            tidestruc.name    = char(tidestruc.name);
            tidestruc.name    = tidestruc.name   (:,:);
            tidestruc.freq    = tidestruc.freq   (:,:);
            tidestruc.tidecon = tidestruc.tidecon(:,:);
            
            %% Put in *.bca struct
            %% ----------------------

            BCA.DATA(itable,icol-1).names = tidestruc.name        ;% [n x 2 char]
            BCA.DATA(itable,icol-1).Label = T.location;            % 'north_001A'
            BCA.DATA(itable,icol-1).amp   = tidestruc.tidecon(:,1);% [0.0670 0.1085 0.0244 0.0292 0.0172 0.0252 0.0663 0.0723]
            BCA.DATA(itable,icol-1).phi   = tidestruc.tidecon(:,3);% [168.2587 106.2307 162.9063 81.0589 143.1680 -86.1792 -84.3035 119.0369]                 
                 
         end
              
         %% Make sure there are no transitions across the 360 boundary inside one boundary segment
         %% because Delft3D-FLOW interpolates linearly (as a scalar) inside the boundary segment.
         %%
         %% This does probably also deal correctly with 3D velocity boundaries
         %% where also in the vertical some interpolation is required.
         %% ------------------------------

            if H.unwrap
            
              % all |steps| > 180 are changed
              % BCH.phases(1:end,itable,ifreq) =  domain2angle(BCH.phases(1:end,itable,ifreq),0,360,180);
              BCA.DATA(itable,icol-1).phi =  rad2deg(unwrap(deg2rad(BCA.DATA(itable,icol-1).phi)));
            
            end
              
      end % for icol = 2:ncol;
      
      disp(['Processed boundary ',num2str(itable,'%0.3d'),' of ',num2str(BCT.NTables,'%0.3d')]); % max 200 in Delft3d, so 3 digits OK
   
   end % for itable = BCT.NTables
   
   %% Write residue/prediction to bct file
   %% ----------------------

   if ~isempty(H.residue)
      BCT = bct_io('write',H.residue,BCTres);
   end

   if ~isempty(H.prediction)
      BCT = bct_io('write',H.prediction,BCTprd);
   end

   %% Output
   %% ----------------------
   
   delft3d_io_bca('write',[OPT.bcafile],BCA,BND)

   if nargout==1
      varargout = {BCA};
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   
   function index = datenum2index(t,tlims)
   %DATENUM2INDEX
   %
   % index = datenum2index(datenum,datenum_lims)
   %
   % returns indices in timevector where 
   %
   % index = find(t >= tlims(1) & t <= tlims(2));
   
   index = find(t >= tlims(1) & t <= tlims(2));
   