function varargout = bca2bct(bcafile,bctfile,bndfile,period,ncomponents,refdate,varargin);
%BCA2BCT          performs tidal prediction to generate *.bct from *.bca <<beta version!>>
%
%     bca2bct(bcafile,bctfile,bndfile,period,ncomponents,refdate,<keyword,value>);
% BCT=bca2bct(bcafile,bctfile,bndfile,period,ncomponents,refdate,<keyword,value>);
%
% Generates a Delft3D FLOW *.bct file (time series boundary condition)
% from a *.bca file (astronomic components boundary conditions).
% using the *.bnd file (boundary definition file) and using T_TIDE prediction.
% 
% *  period is a time array in matlab datenumbers
%    E.g. a 10-minute ( 10 minutes is 1 day / 24 hours /6) time series:
%    period = datenum(1999,5,1,3,0,0):1/24/6:datenum(1999,10,1,2,0,0);
%
% *  bcafile, bndname and bctfile are file names (including directory).
%
% *  ncomponents is the number of astronomical components per boundary
%    (same for all boundaries) in the *.bca file.
%
% *  where refdate is a matlab datenumber or the string as
%    defined in the *.mdf file: "yyyy-mm-dd"
%    or "yyyymmdd".
%
% The following <keyword,value> pairs are implemented (not case sensitive):
%
%    * latitude:    [] default (same effect as none in t_tide)
%
%                   NOTE THAT ANY LATITUDE IS REQUIRED FOR T_PREDIC TO INCLUDE NODAL FACTORS AT ALL
%
%    OPT = bct2bca returns struct with default <keyword,value> pairs
%
% Note: t_tide does not generally return an A0 component, determine A0 yourselves.
%
% G.J. de Boer, March 8th 2006 - Feb 2008.
%
% See also:  BCT2BCA, DELFT3D_NAME2T_TIDE, T_TIDE_NAME2DELFT3D, 
%            BCT_IO, DELFT3D_IO_BCA, DELFT3D_IO_BND, 
%            T_TIDE (http://www.eos.ubc.ca/~rich/) 

% Requires the following m-functions:
% - bct_io
% - delft3d_io_bca
% - delft3d_io_bnd
% - t_tidename2freq
% - t_predic and associated stuff

% 2008 jul 11: * changed name of t_tide output (to prevent error due to ':' in current column name)

%   --------------------------------------------------------------------
%   Copyright (C) 2006-8 Delft University of Technology
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

   if nargin <6
       error('syntax: bca2bct(bcafile,bctfile,bndfile,period,ncomponents,refdate,..);')
   end

%% Defaults
%% -----------------

   H.latitude   = [];
   
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
      while iargin<=nargin-6,
          switch lower ( varargin{iargin})
          % all keywords lower case
          
          case 'latitude'  ;iargin=iargin+1;H.latitude   = varargin{iargin};

          otherwise
            error(sprintf('Invalid string argument (caps?): "%s".',varargin{iargin}));
          end
          iargin=iargin+1;
      end
   end   
   
%% Check input
%% -----------------

   if isempty(H.latitude);warning('No latitude passed, performing simple harmonic analysis, not tidal analysis!');end
   
   H
   
%% Load (ancillary) data
%% -----------------
   
   BND = delft3d_io_bnd('read',bndfile);
   disp(['Boundary definition file read: ',bndfile]);
   
   BCA = delft3d_io_bca('read',bcafile,BND,ncomponents);
   disp(['Astronomic boundary data file read: ',bcafile]);
   
%% Date / time
%% ------------------------------

   if ischar(refdate)
      if length(redate)==8
      %% "yyyymmdd"
      %% --------------------
         ReferenceTime   = str2num(refdate);
         refdate = datenum(str2num(refdate(1: 4)),...
                           str2num(refdate(5: 6)),...
                           str2num(refdate(7: 8)));
      else
      %% "yyyy-mm-dd"
      %% --------------------
         ReferenceTime  = str2num([refdate(1: 4);...
                                   refdate(6: 7);...
                                   refdate(9:10)]);
         refdate = datenum(str2num(refdate(1: 4)),...
                           str2num(refdate(6: 7)),...
                           str2num(refdate(9:10)));
      end
   else
      %% datenumber
      %% --------------------
      [Y,M,D,HR,MI,SC] = datevec(refdate);
      ReferenceTime  = str2num([num2str(Y,'%0.4d'),...
                                num2str(M,'%0.2d'),...
                                num2str(D,'%0.2d')]);
   end   

   minutes_wrt_refdate = (period - refdate).*(24*60);

%% Fill BCT
%% ------------------------------
   
   BCT.FileName = bctfile;
   BCT.NTables  = BND.NTables;

for ibnd=1:length(BND.DATA)
    
   %% Only for astronomical boundaries
   %% delft3d_io_bca already checked that the 
   %% required tables exist
   %% --------------------------------
   
   if lower(BND.DATA(1).datatype)=='a'
   
      BCT.Table(ibnd).Name              = ['t_predic @ latitude ',num2str(H.latitude),' from bca file: ',bcafile];
      BCT.Table(ibnd).Contents          = 'uniform';
      BCT.Table(ibnd).Location          = BND.DATA(ibnd).name;
      BCT.Table(ibnd).TimeFunction      = 'non-equidistant';
      BCT.Table(ibnd).ReferenceTime     =  ReferenceTime;
      BCT.Table(ibnd).TimeUnit          = 'minutes';
      BCT.Table(ibnd).Interpolation     = 'linear';
       
      BCT.Table(ibnd).Data(:,1)         = minutes_wrt_refdate;
      
      BCT.Table(ibnd).Parameter(1).Name = 'Time starting at ITDATE = 0.0';
      BCT.Table(ibnd).Parameter(1).Unit = '[   min  ]';
       
      BCT.Table(ibnd).Parameter(2).Name = 'water elevation (z)  end A';
      BCT.Table(ibnd).Parameter(2).Unit = '[   m    ]';
      
      BCT.Table(ibnd).Parameter(3).Name = 'water elevation (z)  end B';
      BCT.Table(ibnd).Parameter(3).Unit = '[   m    ]';
      
      for isize=1:2
                   
         %% Although delft3d_io_bca above cannot handle a different number 
         %% of componentsa per boundary yet (ncomponents), 
         %% bca2bct can already (ncomp).
         %% Should be same for the two boundary end points thgough.
         
         if     isize==1
         ncomp   = length(BCA.DATA(ibnd,isize).amp);
         elseif isize==2
            if ~(ncomp == length(BCA.DATA(ibnd,isize).amp));
               error(['Number of components should be equal for two end points for boundary: ',BCT.Table(ibnd).Name ])
            end
         end
         
         %% Tidal prediction parameters
         %% ------------------------------
         
         H.names = BCA.DATA(ibnd,isize).names;
         H.names = delft3d_name2t_tide(H.names);

         %% t_predic wants frequecies in cycles /hour
         %% ------------------------------

        [H.freq,...
         H.names,...
         H.tindex]   = t_tide_name2freq(cellstr(H.names),'unit' ,'cyc/hr');
         
         H.freq      = H.freq(:);
         H.names     = pad(char(H.names),4,' ');
         
         
         if ~(ncomponents==length(H.names))
            error('ncomponent error')
         end
         
         %% Tidal amp/phase
         %% ------------------------------
      
         %% tidecon is a matrix with 
         %% column 1 amplitude
         %% column 2 amplitude error
         %% column 3 phase
         %% column 4 phase error
         
         %% the 2nd and 4th are set to eps, because when they are zero, 
         %% t_predic shows a lot of the following warnings:
         
         %   Warning: Divide by zero.
         %   (Type "warning off MATLAB:divideByZero" to suppress this warning.)
         %   > In ...\t_tide\t_predic.m at line 92
         %     In ...\bca2bct.m at line 133
         %     In ...\bca2bct_example.m at line 9
      
         tidecon = zeros([ncomp 4]) + eps;
         
         for icomp=1:ncomp
            tidecon(icomp,1) = BCA.DATA(ibnd,isize).amp(icomp);
            tidecon(icomp,3) = BCA.DATA(ibnd,isize).phi(icomp);
         end
         
         % Results from t_tide:
         % 
         %    tidestruc = 
         %           name: [35x4 char]
         %           freq: [35x1 double]
         %        tidecon: [35x4 double]
      
         if isempty(H.latitude)
            hpredic = t_predic(period,H.names,H.freq,tidecon);
         else
            hpredic = t_predic(period,H.names,H.freq,tidecon,'latitude',H.latitude);
         end
          
         BCT.Table(ibnd).Data(:,isize+1) = hpredic;
         
      end
      
      disp(['Processed boundary ',num2str(ibnd),' of ',num2str(BND.NTables)])
      %pause
      
   end % if lower(BND.DATA(1).datatype)=='a'

end

%% Write the BCT file with the time series
%% ----------------------------

bct_io('write',bctfile,BCT)

if nargout==1
   varargout = {BCT};
end

% BCT = bct_io('read','dummy.bct')
% ----------------------------------------------------------------
% BCT
% 
%       Check: 'OK'
%    FileName: 'TMP_cas.bct'
%     NTables: 75
%       Table: [1x75 struct]
%       
% BCT.Table(1)
% 
%             Name: 'T-serie BCT north_001            for run: cas'
%         Contents: 'uniform'
%         Location: 'north_001'	
%     TimeFunction: 'non-equidistant'
%    ReferenceTime: 19990506
%         TimeUnit: 'minutes'
%    Interpolation: 'linear'
%        Parameter: [1x3 struct]
%             Data: [3432x3 double]       
% 
% ----------------------------------------------------------------
