function varargout = struct2xls(fname,S,varargin)
%STRUCT2XLS   Save 1D data + fieldnames from matlab struct into xls file 
%
% STRUCT2XLS(filename,struct) converts a matlab struct 
% with 1D numerical fields !! to an excel file. Non-numeric 
% arrays are only allowed with xlswrite in matlab 2006b and above.
% Character arrays can be 2D. By default the 2nd dimension of all 
% 1D arrays should be  equal, and are taken as the column 
% length in the excel sheet.
%
%  Example of resulting *.xls file:
% 
%  +---------------+---------------+---------------+---------------+
%  |# textline 1   |               |               |               |
%  |# textline 2   |               |               |               |
%  |# textline 3   |               |               |               |
%  | columnname_01 | columnname_02 | columnname_03 | columnname_04 |  
%  | units         | units         | units         | units         |
%  | number/string | number/string | number/string | number/string |
%  | number/string | number/string | number/string | number/string |
%  | number/string | number/string | number/string | number/string |
%  | ...           | ...           | ...           | ...           |
%  | number/string | number/string | number/string | number/string |
%  +---------------+---------------+---------------+---------------+
%
% * Requires xlswrite from matlab 2006b depends upon Excel as a COM server.
% - Does not use xlswrite from file exchange, which uses ActiveX.
%   which due to bug in xlswrite files while writing to other directories, the 
%   xlsfile is created locally with a tmp file and and then copied to 
%   the destination directory. So you need write access where you run struct2xls.
% * Beta version.
% * Is not (by default) reciprocal of xls2struct (due to units line below column headers)
%   and cell aray for 2D char arrays
%
% STRUCT2XLS(filename,struct,<keyword,value>) where 
% implemented key words are:
% * units       - 0 = not,
%               - 1 = empty line
%               - cell array is yes
%               - struct with a fieldnames matching the struct field names is yes
% * coldimnum   dim ension of fieldname input arrays to be used as column in excel (1 or 2)
%               (default 2) after option oneD has optionally reshaped so the 1st dimension is 1. 
% * coldimchar   dim ension of fieldname input arrays to be used as column in excel (1 or 2)
%               (default 2) after option oneD has optionally reshaped so the 1st dimension is 1. 
% * oneD        makes sure that both numeric matrix columns and matrix rows are written as Excel 
%               columns (default 1), only works for arrays where either 1st or 2nd dimension has lenght 1..
% * header      cell array of comment lines above column names (see also keyword commentchar)
% * overwrite   which can be 
%               'o' = overwrite (1)
%               'c' = cancel
%               'p' = prompt (default, after which o/a/c can be chosen) (0)
% * commentchar character to append to start of comment (header) line (default '#')  
% * sheet       sheetname (default '')
%
% [success]   = STRUCT2XLS(...)
% [success,M] = STRUCT2XLS(...) where M is the cell array passed to XLSWRITE.
%
% See also: XLS2STRUCT, XLSDATE2DATENUM, XLSREAD, XLSWRITE (2006b, otherwise mathsworks downloadcentral)

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2011 Delft University of Technology
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
% $Keywords$

%% Jan 15 2008: added logicals

%% Keywords

   OPT.coldimchar  = 1;
   OPT.coldimnum   = 2;
   OPT.addunits    = 1; % empty line
   OPT.units       = [];
   OPT.header{1}   = ['This file has been created with struct2xls.m and xlswrite.m @ ',datestr(now)];
   OPT.oned        = 1; % reshape 1D matlab rows and columns into excel columns (numeric, logical and cellstr)
   OPT.commentchar = '#';
   OPT.overwrite   = 'p'; % prompt
   OPT.warning     = 0;
   OPT.sheet       = '';
 
   if nargin==0
      varargout = {OPT};
      return
   end

   OPT = setproperty(OPT,varargin{:});
   
   if ischar(OPT.header)
     OPT.header = cellstr(OPT.header);
   end
   
   assert(~isempty(strfind('oap',OPT.overwrite)),'Wrong input for ''overwrite'' use o/a/p')
   
%% Check if file already exists

   if exist(fname,'file')==2
      
      if strcmp(OPT.overwrite,'p') || OPT.overwrite==0
         disp(['File ',fname,' alreay exists. '])
         OPT.overwrite = input('Overwrite/cancel ? (o/a/c): ','s');
         % for some reason input in Matlab R14 SP3 removes slashes
         % OPT.overwrite = input(['File ',fname,' alreay exists. Overwrite/cancel ? (o/a/c)'],'s');
         while isempty(strfind('oac',OPT.overwrite))
             OPT.overwrite = input('Overwrite/cancel ? (o/a/c): ','s');
         end
      end
      
      if strcmpi(OPT.overwrite,'o') || OPT.overwrite==1
         disp (['File ',fname,' overwritten as it alreay exists.'])
         delete(fname)
      end      
      
      if strcmpi(OPT.overwrite,'c')
         if nargout==0
            error(['File ',fname,' not saved as it alreay exists.'])
         else
            disp( ['File ',fname,' not saved as it alreay exists.'])
            success = -2;
            varargout = {success};
            return
         end
      end 
      
      if strcmpi(OPT.overwrite,'a')
          %No action, append
      end
   else
      OPT.overwrite = 'o'; % create
   end


%% Transform into cell array
%  that can contain all 1D arrays

   fldnames  = fieldnames(S);
   nfld      = length(fldnames);

%% Make 1D vectors (rowwise and columnwise) 1D in right dimension for excel columns
      
   if OPT.oned
      for ifld=1:nfld
         fldname   = char(fldnames(ifld));
         if isnumeric(S.(fldname)) || ...
            islogical(S.(fldname)) 
            if length(size(S.(fldname)))==2
               if (size(S.(fldname),2)==1)
                  S.(fldname) = S.(fldname)';
                  if OPT.warning
                    warning([mfilename,' field ''',fldname,''' has been transposed to fit into an Excel column.\n'])
                  end
               end
            end
         % for some reason cellstr needs to be [n x 1] instead of [1 x n]
         elseif iscellstr(S.(fldname))
            if length(size(S.(fldname)))==2
               if (size(S.(fldname),1)==1)
                  S.(fldname) = S.(fldname)';
                  if OPT.warning
                    warning([mfilename,' field ''',fldname,''' has been transposed to fit into an Excel column.\n'])
                  end
               end
            end
         end
      end
   end

%% Initialize cell array

   maxlength = 0;
   for ifld=1:nfld
      fldname   = char(fldnames(ifld));
      maxlength = max(maxlength,length(S.(fldname)));
   end
   

   nheader = length(OPT.header);
   nextra  = nheader + 1 + (OPT.addunits==1 || iscell(OPT.addunits));
   M       = cell (maxlength + nextra,nfld);
   
%% Add header and column names

   for iheader=1:nheader
      M{iheader,1} = [OPT.commentchar,' ',OPT.header{iheader}];
   end
         
%% Fill cell array

   for ifld=1:nfld
   
      fldname             = char(fldnames(ifld));
      fldsize             = size(S.(fldname));
      
      M{nheader + 1,ifld}    = fldname;
      if ~isempty(OPT.units)
         if iscell(OPT.units)
            M{nheader + 2,ifld}    = char(OPT.units{ifld});
         elseif isstruct(OPT.units)
            if isfield(OPT.units,fldname)
            M{nheader + 2,ifld}    = OPT.units.(fldname);
            end
         end
      end

      %if strcmp(version('-release'),'14')    | ...
      %
      %   M = zeros(maxlength,nfld);
      %
      %   %% uses xlswrite from download central
      %   %% ---------------------
      %   if OPT.coldim==1
      %      M(1:fldsize(OPT.coldim),ifld) = S.(fldname)';
      %   elseif OPT.coldim==2
      %      M(1:fldsize(OPT.coldim),ifld) = S.(fldname);
      %   end
      %
      %   colnames = fldnames;
      %   if isempty(filepathstr(fname))
      %     xlswrite(M,OPT.header,colnames,fname); % download central
      %   else
      %     tmpfilename = gettmpfilename('','.xls'); % download central
      %     xlswrite(M,OPT.header,colnames,tmpfilename);
      %     copyfile(tmpfilename,fname)
      %     delete  (tmpfilename)
      %   end
      %
      %else
      
      if iscellstr(S.(fldname))
         S.(fldname) = char(S.(fldname));
      end

         if isnumeric(S.(fldname)) || ...
            islogical(S.(fldname))

            %% uses xlswrite shipped with matlab 

            if OPT.coldimnum==1
               for irow=1:1:fldsize(OPT.coldimnum)
               M{irow + nextra,ifld} = S.(fldname)(irow,:);
               end
            elseif OPT.coldimnum==2
               for irow=1:1:fldsize(OPT.coldimnum)
               M{irow + nextra,ifld} = S.(fldname)(:,irow);
               end
            end
         elseif ischar(S.(fldname))

            %% uses xlswrite shipped with matlab 

            if OPT.coldimchar==1
               for irow=1:1:fldsize(OPT.coldimchar)
               M{irow + nextra,ifld} = S.(fldname)(irow,:);
               end
            elseif OPT.coldimchar==2
               for irow=1:1:fldsize(OPT.coldimchar)
               M{irow + nextra,ifld} = S.(fldname)(:,irow);
               end
            end
         end

      %end
   end
   
   if isempty(OPT.sheet)
       success = xlswrite(path2os(fname),M); % microsoft does not like double \ in path if file does not yet exist
   else
       success = xlswrite(path2os(fname),M,OPT.sheet);
   end
   
   if nargout==1
      varargout = {success};
   elseif nargout==2
      varargout = {success,M};
   end
   
%% EOF   