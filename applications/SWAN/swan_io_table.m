function swan = swan_io_table(fname,varargin)
%SWAN_IO_TABLE    read SWAN ASCII output table        (BETA VERSION).
%
% DATA = SWAN_IO_TABLE(fname)
% DATA = SWAN_IO_TABLE(fname,mnmax)
% DATA = SWAN_IO_TABLE(fname,[]   ,fieldcolumnnames)
% DATA = SWAN_IO_TABLE(fname,mnmax,fieldcolumnnames)
%
% where mnmax is a 2-element vector with the number of 
%    SWAN !nodes ! , i.e. 1 more than the number of 
%    SWAN !meshes! as given in the SWAN input file.
%    Use swan_input to get to know this (in case of COMPGRID).
%    If not specified, or is empty, 1D vectors are returned.
%
% where fieldcolumnnames is a cell array or a white space delimited char 
%    with the field names for each column, which are by default 
%    the small case SHORT names as defined for SWAN input file code:
%    Use SWAN_INPUT to get to read these. Use SWAN_QUANTITY to
%    get info regarding these.
%    ------------------------------------------------------
%    TABLE 'COMPGRID' NOHEAD 'SWANOUT'  _                                        
%     HSIGN    DIR      TM01     DEPTH    VELOC    TRANSP _                          
%     DSPR     DISSIP   LEAK     QB       XP       YP     _                          
%     DIST     UBOT     STEEPW   WLENGTH  FORCES   RTP    _                          
%     PDIR                                                                           
%    ------------------------------------------------------
% All fieldnames are turned into upper case.
%
% Example:
%
%   INP = swan_io_input('INPUT')
%   for itab=1:length(INP.table)
%      TAB(itab) = swan_io_table(INP.table(itab).fname ,...
%                               [INP.table(itab).mxc+1  ...
%                                INP.table(itab).myc+1],...
%                                INP.table(itab).parameter.names)
%   end
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_GRD, SWAN_IO_BOT

% to do: add option to read based on solely table struct as read by SWAN_IO_INPUT

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

      mmax = [];
      nmax = [];
   if nargin>1
      if ~isempty(varargin{1})
         mmax = varargin{1}(1);
         nmax = varargin{1}(2);
      end
   end
   
   shape.nfields     = ones(18,1);
   shape.nfields( 5) = 2;
   shape.nfields( 6) = 2;
   shape.nfields(17) = 2;
   
                                 %  paramter
                                 %     columns
                                 %          dimensions (vector vs. scalar)
                                 % --------------------------------
   shape.names  = {'HS     ',... %  1  1    1
                   'DIR    ',... %  2  2    1
                   'TM01   ',... %  3  3    1
                   'DEP    ',... %  4  4    1
                   'VEL    ',... %  5  5- 6 2
                   'TRA    ',... %  6  7- 8 2
                   'DSPR   ',... %  7  9    1
                   'DISS   ',... %  8 10    1
                   'LEAK   ',... %  9 11    1
                   'QB     ',... % 10 12    1
                   'XP     ',... % 11 13    1
                   'YP     ',... % 12 14    1
                   'DIST   ',... % 13 15    1
                   'UBOT   ',... % 14 16    1
                   'STEEP  ',... % 15 17    1
                   'WLEN   ',... % 16 18    1
                   'FOR    ',... % 17 19-20 2
                   'RTP    ',... % 18 21    1
                   'PDIR   '};   % 19 22    1
   
   
   if nargin>2
      shape.names  = upper(varargin{2});
      if ~iscell(shape.names)
         shape.names = strtokens2cell(deblank(shape.names));
      end
      shape.nfields = ones(length(shape.names),1);
      
      %% for all vectors define 2 columns
      %% -----------------------
      for ifield=1:length(shape.nfields)
         
         fldname = char(deblank(shape.names{ifield}));
         
         if length(fldname) > 5
            fldname = fldname(1:5);
         end
         
         fldname = deblank(fldname);
         
         if strcmp(upper(fldname),'VEL') | ...
            strcmp(upper(fldname),'TRA') | ...
            strcmp(upper(fldname),'WIND' ) | ...
            strcmp(upper(fldname),'FOR')

             shape.nfields(ifield) = 2;  

         end
         
      end % for ifield=1:length(shape.nfields)
      
   end % if  nargin>2 
   
   if nargin>3
      error('syntax: dep = swan_TABLE(filename,<mnmax,fieldnames>)')
   end

   dat = load(fname); %load(fname);
   
   for ifield=1:length(shape.nfields)

      ndata   = shape.nfields(ifield); % 1 or 2
      fldname = char(deblank(shape.names{ifield}));

      for idata = 1:shape.nfields(ifield)
         columns = sum(shape.nfields(1:ifield-1)) + idata;
         data                      = dat(:,columns);
         if ~isempty(mmax)
            swan.(fldname)(:,:,idata) = reshape(data,[mmax nmax]);
         else
            swan.(fldname)(:,idata) = data;
         end
      end

   end

   % TABLE 'COMPGRID' NOHEAD 'SWANOUT'  _                                 
   %  HSIGN    DIR      TM01     DEPTH    VELOC    TRANSP _               
   %  DSPR     DISSIP   LEAK     QB       XP       YP     _               
   %  DIST     UBOT     STEEPW   WLENGTH  FORCES   RTP    _               
   
   %HSIGN    >> (checked succesfully with wgxy)
   %DIR      
   %TM01     
   %DEPTH    >> (checked succesfully)  
   %VELOC    (vector)
   %TRANSP   (vector)     
   %DSPR   
   %DISSIP   
   %LEAK     
   %QB       
   %XP       
   %YP                   
   %DIST     
   %UBOT     
   %STEEPW   
   %WLENGTH  >> (checked succesfully with wgxy)
   %FORCES   (vector)
   %RTP      >> (checked succesfully with wgxy)
   %PDIR

%% EOF
