function varargout = xls2struct(fname,varargin)
%XLS2STRUCT    Reads 1D data + fieldnames from xls file into matlab struct (BETA).
%
% DATA = xls2struct(fname)
% DATA = xls2struct(fname,work_sheet_name)
% DATA = xls2struct(fname,work_sheet_name,<keyword,value>)
%
% [DATA,units         ] = xls2struct(fname,work_sheet_name,<keyword,value>)
% [DATA,units,metainfo] = xls2struct(fname,work_sheet_name,<keyword,value>)
%
% where the xls has the following structure:
% * fieldnames (column names) at the first line.
% * units at the second line.
% * every line starting with one of '*%#' is interpreted 
%   as a comment line.
% * all text fields with text 'nan' are interpreted as numeric NaNs
%
% Example:
%
% +---------------+---------------+---------------+---------------+
% |# textline 1   |               |               |               |
% |# textline 2   |               |               |               |
% |# textline 3   |               |               |               |
% | columnname_01 | columnname_02 | columnname_03 | columnname_04 |  
% | units         | units         | units         | units         |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | ...           | ...           | ...           | ...           |
% | number/string | number/string | number/string | number/string |
% +---------------+---------------+---------------+---------------+
%
% and <keyword,value> pairs are:
%
% * addunits, true by default, adds units to DATA struct when 
%             there is only 1 output argument.
% * units   , true by default, specifies whether the units at 
%             the second line are present.
%
% Notes:
% 
% + The last columns extending the fieldnames are added to the 
%   last fieldname as array. Make sure there's no extra columnwith spaces !
%   In case of error just delete the (seemingly) empty rows and columns.
% + Elements where excel displays #DIV/0! or where you entered the 
%   string 'nan' are considered as numerical nans.
% + Do not use 'units' as a fieldname, since the units (2nd line)
%   are already loaded to a field called 'units', with a subield
%   for every main field.
%
% Tested for matlab releases 2006B and 6.5
%
% G.J. de Boer, Apr.-Nov. 2006
%
% See also: XLSWRITE (2006b, otherwise mathsworks downloadcentral), 
%           XLSREAD, STRUCT2XLS

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2008 Delft University of Technology
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

% 2008, Apr 18: made fldname always valid with mkvbar

% TO DO:
% Add keywords/properties above columns:

% +---------------+---------------+---------------+---------------+
% |# textline 1   |               |               |               |
% |# textline 2   |               |               |               |
% |# textline 3   |               |               |               |

% | KEYWORD01     | VALUE01       |               |               |
% | KEYWORD02     | VALUE02       |               |               |
% | KEYWORD03     | VALUE03       |               |               |
% | ...           | ...           |               |               |
% | KEYWORD0n     | VALUE0n       |               |               |

% | columnname_01 | columnname_02 | columnname_03 | columnname_04 |  
% | units         | units         | units         | units         |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | number/string | number/string | number/string | number/string |
% | ...           | ...           | ...           | ...           |
% | number/string | number/string | number/string | number/string |
% +---------------+---------------+---------------+---------------+

if strcmp(version('-release'),'13')
   disp('xlsread: Only properly tested for in R14 and higher.')
end

   %% Input
   %% ----------------------

   OPT.addunits = true;   
   OPT.units    = true;
   OPT.sheet    = [];
   OPT.debug    = 1;
   
   if ~odd(nargin)
      OPT.sheet = varargin{1};
      i     = 2;
   else
      i     = 1;
   end
   
%    while i<=nargin-2,
%      if ischar(varargin{i}),
%        switch lower(varargin{i})
%        case 'addunits'   ;i=i+1;OPT.addunits  = varargin{i};
%        case 'units'      ;i=i+1;OPT.units     = varargin{i};
%        otherwise
%           error(sprintf('Invalid string argument: %s.',varargin{i}));
%        end
%      end;
%      i=i+1;
%    end;   

   OPT           = SetProperty(OPT,varargin{i:end});
   META.filename = fname;
   iostat        = 1;
   tmp           = dir(fname);
   
   if length(tmp)==0
      
      if nargout<2
         error(['Error finding file: ',fname])
      else
         iostat = -1;
         DAT    = [];
         UNITS  = [];
      end      
      
   elseif length(tmp)>0
   
      META.filedate     = tmp.date;
      META.filebytes    = tmp.bytes;
   
      sptfilenameshort = filename(fname);
         
      %% Load raw data
      %% ----------------------
   
      if ~isempty(OPT.sheet)
         if strfind(version('-release'),'13')==1
             
             [tstdat,tsttxt] = xlsread(fname,OPT.sheet); % ,'basic'
             
             dimtxt = size(tsttxt);
             dimdat = size(tstdat);
             maxdim = max(dimtxt,dimdat);
             
             tstraw = tsttxt; % is already cell
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if (i1 > dimtxt(1) | ...
                       i2 > dimtxt(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                    else
                      if isempty(tsttxt{i1,i2})
                         if (i1 <= dimdat(1)) & (i2 <= dimdat(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                         end
                      elseif strcmpi(tsttxt{i1,i2},'nan')
                         tstraw{i1,i2} = nan; 
                      end
                   end % if
                end % i2
             end % i1
         else
             [tstdat,tsttxt,tstraw] = xlsread(fname,OPT.sheet); % ,'basic'
             maxdim = size(tstraw);
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if strcmpi(tstraw{i1,i2},'nan')
                      tstraw{i1,i2} = nan; 
                   elseif strcmpi(tstraw{i1,i2},'ActiveX VT_ERROR: '); 
                   % In matlab 7.3.0.267 (R2006b) xlsread gives for 
                   % #DIV/0! the following: 'ActiveX VT_ERROR: '
                      tstraw{i1,i2} = nan; 
                   end % if
                end % i2
             end % i1
         end % release
      else
         if strfind(version('-release'),'13')==1
             
             [tstdat,tsttxt] = xlsread(fname); % ,'basic'
             
             whos
             dimtxt = size(tsttxt);
             dimdat = size(tstdat);
             maxdim = max(dimtxt,dimdat);
             
             tstraw = tsttxt; % is already cell
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if (i1 > dimtxt(1) | ...
                       i2 > dimtxt(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                    else
                      if isempty(tsttxt{i1,i2})
                         if (i1 <= dimdat(1)) & (i2 <= dimdat(2))
                         tstraw{i1,i2} = tstdat(i1,i2); 
                         end
                      elseif strcmpi(tsttxt{i1,i2},'nan')
                         tstraw{i1,i2} = nan; 
                      end
                   end % if
                end % i2
             end % i1
         else
             [tstdat,tsttxt,tstraw] = xlsread(fname); % ,'basic'
             maxdim = size(tstraw);
             for i1=1:maxdim(1)
                for i2=1:maxdim(2)
                   if strcmpi(tstraw{i1,i2},'nan')
                      tstraw{i1,i2} = nan; 
                   elseif strcmpi(tstraw{i1,i2},'ActiveX VT_ERROR: '); 
                   % In matlab 7.3.0.267 (R2006b) xlsread gives for 
                   % #DIV/0! the following: 'ActiveX VT_ERROR: '
                      tstraw{i1,i2} = nan; 
                   end % if
                end % i2
             end % i1
         end % release
      end
      
      %% Take care of fact that excel skips certain rows/columns
      %% depending on data type (numerical/string)
      %% --------------------------------------

      if iscell(tsttxt) 
         commentlines       = zeros(1,size(tstraw,1));
         for j=1:size(tstraw,1)
            if ~isnan(tstraw{j,1})
            commentlines(j) = iscommentline(char(tstraw{j,1}(1)),'%*#');
            end
         end
      elseif iscell(tsttxt) 
         error('tsttxt not char')
      end
      
     %row_skipped_in_numeric_data = size(tstraw,1) - size(tstdat,1);
     %col_skipped_in_numeric_data = size(tstraw,2) - size(tstdat,2);
      
      %% Test entire columns for presence of non-numbers.
      %% One single non-number is sufficient to treat entirte column as text.
      %% --------------------------------------

      numeric_columns = repmat(true ,[1 size(tstraw,2)]);
      txt_columns     = repmat(false,[1 size(tstraw,2)]);
      
      if OPT.units
         rowoffset = 1;
      else
         rowoffset = 0;
      end
      
      % Per column ...
      for i2=1:size(tstraw,2)

         % ... check all rows
         index = find(~commentlines);
         for irow=index(2+rowoffset):size(tstraw,1)
            if ~isnumeric(tstraw{irow, i2});
               numeric_columns(i2) = false;
               txt_columns    (i2) = true;
               break
            end
         end
            
      end
      
      %% Take care of nans
      %% --------------------------------------
      
      % for i=1:size(tsttxt,1)
      % for j=1:size(tsttxt,2)
      %    if strcmp(      tsttxt{i,j} ,'#N/A') | ...
      %       strcmp(lower(tsttxt{i,j}),'nan' )
      %       tstdat(i - row_skipped_in_numeric_data,...
      %              j - col_skipped_in_numeric_data) = nan;
      %       tsttxt{i,j} = '';
      %    end
      % end
      % end
      
      %% Take care of commentlines and header
      %% --------------------------------------
   
      not_a_comment_line = find(~commentlines);
      
      fldnames           = tsttxt(not_a_comment_line(1),:);
      if OPT.units
      units              = tsttxt(not_a_comment_line(2),:);
      end
      
      %% Remove empty field names at end of row
      %% --------------------------------------
      
      nfld         = length(fldnames);
      fldnamesmask = ones(1,nfld);
      for ifld   = 1:nfld
         if  strcmp(fldnames{ifld},'') | ...
            isempty(fldnames{ifld})
            fldnamesmask(ifld) = 0;
         end
      end
      fldnames = {fldnames{fldnamesmask==1}};
      %fldnames          = fldnames(find(~strcmp(fldnames,'')));
      nfld               = length(fldnames);
      
   %% Read data
   %% ----------------------

      for ifld   = 1:nfld
      
         % no good idea, as crap without a column name ends up in your last column
         %if ifld==nfld
         %   ifld2 = size(tstraw,2);
         %else
            ifld2 = ifld;
         %end
      
         fldname         = mkvar(char(fldnames{ifld}));
         
         if OPT.debug
             disp([num2str(ifld,'%0.3d'),'/',num2str(nfld,'%0.3d'),...
                   ' [text type: '    ,num2str(txt_columns(ifld)),...
                   ' or numeric type ',num2str(numeric_columns(ifld)),']',...
                   ': fldname: "',fldname,'"',]);
         end
         
         if OPT.units
            unit            = char(units   {ifld});
            UNITS.(fldname) = unit;
         end
         
         if isempty(fldname)
            break
         end
         
         if OPT.units
            if numeric_columns(ifld)
               DAT.(fldname)    = tstraw(not_a_comment_line(3:end),ifld:ifld2);
               DAT.(fldname)    = cell2mat(DAT.(fldname));
            else
               %% Leave out empty field.
               %% Only empty fields in header end of column are OK,
               %% empty fields in data region are skipped, and lead to
               %% shifting of data over columns.
               %% ------------------------------------------------
               %% DAT.(fldname)    = tstraw(not_a_comment_line(3:end),ifld:ifld2);
               %% ------------------------------------------------
               irow_not_nan = 0;
               for ifld_per_column=[ifld:ifld2]
                 for irow=3:length(not_a_comment_line)
                   if ~isnan(tstraw{not_a_comment_line(irow),ifld_per_column})
                     irow_not_nan = irow_not_nan + 1;
                     DAT.(fldname)(irow_not_nan            ,1)    = ...
                            tstraw(not_a_comment_line(irow),ifld_per_column); 
                   end % isnan
                 end % irow
               end % ifld_per_column
            end % numeric_columns
        else    
            if numeric_columns(ifld)
               DAT.(fldname)    = tstraw(not_a_comment_line(2:end),ifld:ifld2);
               DAT.(fldname)    = cell2mat(DAT.(fldname));
            else
               if iscell(tsttxt)
                  DAT.(fldname) = tstraw(not_a_comment_line(2:end),ifld:ifld2);
               else
                  error('tsttxt not char')
               end
            end
         end
   
      end

         
      end % if length(tmp)==0
      
      META.iomethod = 'xls2struct';
      META.read_at  = datestr(now);
      META.iostatus = iostat;
   
   if nargout<2
      if OPT.units & OPT.addunits
         DAT.units = UNITS;
      end
      varargout = {DAT};
   elseif nargout==2
      varargout = {DAT,UNITS};
   elseif nargout==3
      varargout = {DAT,UNITS,META};
   else
      error('syntax [DATA,<units>] = xls2struct(...)')
   end
   
   
   
   
   
   
