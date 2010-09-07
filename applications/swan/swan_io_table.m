function varargout = swan_io_table(varargin)
%SWAN_IO_TABLE            read SWAN ASCII output table        (BETA VERSION).
%
%   TAB = swan_io_table(fname)
%   TAB = swan_io_table(fname,fieldcolumnnames)
%   TAB = swan_io_table(fname,fieldcolumnnames,mxyc)
%   TAB = swan_io_table(INP.table(i))
%
% where fname is the table file name (recommended *.crv)
% where fieldcolumnnames is a cell array or a white space delimited char 
%    with the field names for each column, which are by default 
%    the small case SHORT names as defined for SWAN input file code:
%    Use SWAN_INPUT to get to read these. Use SWAN_QUANTITY to
%    get info regarding these. All fieldnames are turned into upper case.
%    If not specified, one raw output matrix is returned.
% where mxyc is a 2-element vector with the number of 
%    SWAN !nodes ! , i.e. 1 more than the number of 
%    SWAN !meshes! as given in the SWAN input file.
%    Use swan_input to get to know this (in case of COMPGRID).
%    If not specified, or empty, 1D vectors are returned.
% where INP.table is returned by INP = swan_io_input('INPUT')
%    For multidimensional INP.table loads all tables.
%
% Example to load following SWAN table:
%
%    ----------------------------------------------------
%    TABLE 'COMPGRID' HEADER   'tst.crv'  XP YP DEP HSIGN 
%    ----------------------------------------------------
%
%    TAB = swan_io_table('tst.crv','XP YP DEP HSIGN');
%
% Example to load SWAN table automatically using INPUT file-info:
%
%    INP = swan_io_input('INPUT')
%
%    for itab=1:length(INP.table)
%       TAB(itab) = swan_io_table(INP.table(itab).fname ,...
%                                 INP.table(itab).parameter.names,...
%                                [INP.table(itab).mxc+1  ...
%                                 INP.table(itab).myc+1]);
%    end
%
%    % is same as
%
%    TAB = swan_io_table(INP.table)
%
% See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_GRD, SWAN_IO_BOT

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
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

% 2009 Jun 04: use new matlab code-cells syntax to divide code into 'chapters'
% 2009 mar 12: added option to read based on solely table 
%              struct as read by SWAN_IO_INPU. Removed 
%              default parameter name list, only split into 
%              fields when parameter names are specified, changed 
%              order of input into (...,fieldcolumnnames,<mxyc>). [Gerben de Boer]
% 2009 mar 19: added loading of fname incl. path (as added to table struct in SWAN_IO_INPUT)

%% Input

   INP.table.mmax = [];
   INP.table.nmax = [];
   
   if isstruct(varargin{1})
      INP.table = varargin{1};
      
%% Recursively call SWAN_IO_TABLE for multiple tables
      if length(INP.table(:)) > 1
         disp(['swan_io_table: Loading multiple tables.'])
         for itab=1:length(INP.table)      
            TAB(itab) = swan_io_table(INP.table(itab));  
            disp(['loaded table ',num2str(itab),': ',INP.table(itab).sname])
         end
         TAB = reshape(TAB,size(INP.table)); % for 2D TAB arrays
         varargout = {TAB};
         return
%% Proceed SWAN_IO_TABLE for single table
      else
         INP.table.mmax = INP.table.mxc + 1;
         INP.table.nmax = INP.table.myc + 1;
      end
      
   elseif ischar(varargin{1})

      INP.table.fullfilename = varargin{1};

%% column names
      if nargin>1
   
          %-% REMOVED DELFTD_WAVE DEFAULT:
          %-% %% Define default (Delft3D) Column parameter names
          %-% %-------------------------
          %-% 
          %-% INP.table.parameter.nfields     = ones(18,1);
          %-% INP.table.parameter.nfields( 5) = 2;
          %-% INP.table.parameter.nfields( 6) = 2;
          %-% INP.table.parameter.nfields(17) = 2;
          %-% 
          %-%                                             %  parameter
          %-%                                             %     columns
          %-%                                             %          dimensions (vector vs. scalar)
          %-%                                             % --------------------------------
          %-% INP.table.parameter.names  = {'HS     ',... %  1  1    1
          %-%                               'DIR    ',... %  2  2    1
          %-%                               'TM01   ',... %  3  3    1
          %-%                               'DEP    ',... %  4  4    1
          %-%                               'VEL    ',... %  5  5- 6 2
          %-%                               'TRA    ',... %  6  7- 8 2
          %-%                               'DSPR   ',... %  7  9    1
          %-%                               'DISS   ',... %  8 10    1
          %-%                               'LEAK   ',... %  9 11    1
          %-%                               'QB     ',... % 10 12    1
          %-%                               'XP     ',... % 11 13    1
          %-%                               'YP     ',... % 12 14    1
          %-%                               'DIST   ',... % 13 15    1
          %-%                               'UBOT   ',... % 14 16    1
          %-%                               'STEEP  ',... % 15 17    1
          %-%                               'WLEN   ',... % 16 18    1
          %-%                               'FOR    ',... % 17 19-20 2
          %-%                               'RTP    ',... % 18 21    1
          %-%                               'PDIR   '};   % 19 22    1
          
         INP.table.parameter.names  = upper(varargin{2});
         if ~iscell(INP.table.parameter.names)
            INP.table.parameter.names = strtokens2cell(deblank(INP.table.parameter.names));
         end
         INP.table.parameter.nfields = ones(length(INP.table.parameter.names),1);
         
%% for all vectors define 2 columns
         
         for ifield=1:length(INP.table.parameter.nfields)
            
            fldname = char(deblank(INP.table.parameter.names{ifield}));
            
            if length(fldname) > 5
               fldname = fldname(1:5);
            end
            
            fldname = deblank(fldname);
            
            if strcmp(upper(fldname),'VEL') | ...
               strcmp(upper(fldname),'TRA') | ...
               strcmp(upper(fldname),'WIND' ) | ...
               strcmp(upper(fldname),'FOR')
      
                INP.table.parameter.nfields(ifield) = 2;  
      
            end
            
         end % for ifield=1:length(shape.nfields)
         
      end % if  nargin>2 

%% reshape size
      if nargin>2
         if ~isempty(varargin{3})
            INP.table.mmax = varargin{3}(1);
            INP.table.nmax = varargin{3}(2);
         end
      end
      if nargin>3
         error('syntax: dep = swan_TABLE(filename,<mxyc,fieldnames>)')
      end
      
   end
   
%% Load full raw matrix

   dat = load(INP.table.fullfilename); %load(TAB.fname);
   
%%  split into scalar/vector columns and give names

   if isfield(INP.table,'parameter')
   for ifield=1:length(INP.table.parameter.nfields)

      ndata   = INP.table.parameter.nfields(ifield); % 1 or 2
      fldname = char(deblank(INP.table.parameter.names{ifield}));
      
      % ['ifield:',num2str(ifield),' ndata:',num2str(ndata),' fldname:',fldname]

      for idata = 1:INP.table.parameter.nfields(ifield)
         columns = sum(INP.table.parameter.nfields(1:ifield-1)) + idata;
         data    = dat(:,columns);

%%  reshape 1D column to proper 2D matrix (if mxc,myc provided)
         
         if ~isempty(INP.table.mmax) & ...
            ~isempty(INP.table.nmax)
            TAB.(fldname)(:,:,idata) = reshape(data,[INP.table.mmax INP.table.nmax]);
         else
            TAB.(fldname)(:,idata  ) = data;
         end
      end

   end
   varargout = {TAB};
   else
   varargout = {dat};
   end % if isfield(INP.table,'parameter')

%% EOF
