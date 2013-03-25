function varargout = csv2struct(fname,varargin)
%CSV2STRUCT    Read columns from xls file into matlab struct fields 
%
%    DATA = csv2struct(fname)
%
% reads columns from fname into struct fields. The first line
% is used to make the field names, the second line is used
% for the units (if 'units' set=1, but default 0) as in
%
%    [DATA,units] = csv2struct(fname,'units',1,<keyword,value>)
%
% For other keywords + defaults call without arguments: csv2struct()
%
% e.g. D = csv2struct('somefile.csv','delimiter',';','CommentStyle','%')
%
% Note: columns are mapped to numeric, columns where char conversion
% yields NaN are kept as char (incl lines with pure text)
% Note: removal of double quotes needs to be specified explicitly for
% column names (1) and column values (2) seperately with keyword 'quotes'
% with a two-element vector. Note that viz. "korea, republic of" or
% "100,000" would otherwise yield two columns each due to their internal
% comma's, e.g.
%
% Example: D = csv2struct('koreas.csv','delimiter',',','quotes',[0 1])
% +---------------->
% | column1,column2
% | "Korea, Democratic People's Republic of","120,540"
% | "Korea, Republic of","100,210"%          
% +---------------->
%
% See also: XLS2STRUCT, NC2STRUCT, LOAD & SAVE('-struct',...)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

%% options

   OPT.units        = 0;
   OPT.delimiter    = ',';
   OPT.error        = 0;
   OPT.CommentStyle = '#';
   OPT.quotes       = [0 0];
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:});
   
%% get meta-info

   META.name = fname;
   tmp           = dir(fname);

   if length(tmp)==0
      
      if OPT.error
         error(['Error finding file: ',fname])
      else
         iostat = -1;
         DAT    = [];
         UNITS  = [];
      end
      
   elseif length(tmp)>0

      META.date     = tmp.date;
      META.bytes    = tmp.bytes;
      META.datenum  = tmp.datenum; % not for old matlab versions

      fid      = fopen(fname);
      rec      = fgetl_no_comment_line(fid,OPT.CommentStyle);
      col      = textscan(rec,'%s','Delimiter',OPT.delimiter);
      if OPT.quotes(1)
      colnames = cellfun(@(x) x([2:end-1]),col{1},'UniformOutput',0);
      else
      colnames = col{1};
      end

      if length(OPT.quotes) > 1
       if OPT.quotes(2)
       fmt      = repmat('%q',[1 length(colnames)]);
       else
       fmt      = repmat('%s',[1 length(colnames)]);
       end
      end
   
      if OPT.units
      rec      = fgetl_no_comment_line(fid,OPT.CommentStyle);
      units    = textscan(rec,fmt,'Delimiter',OPT.delimiter,'CommentStyle',OPT.CommentStyle);
      UNITS    = cellfun(@(x) x([2:end-1]),units{1},'UniformOutput',0);
      else
      UNITS    = [];
      end
   
   %% load
   
      RAW = textscan(fid,fmt,'Delimiter',OPT.delimiter,'CommentStyle',OPT.CommentStyle);
      fclose(fid);
      for icol=1:length(RAW)
      
         fldname = mkvar(colnames{icol});
         
         if OPT.quotes
            % check whether each cellstr begins and ends with a "
            % i.e. whether it is a string, if yes, remove leading and trailing "
            % TO DO Else make number
            if all(all(char(cellfun(@(x) x([1 end]),RAW{icol},'UniformOutput',0))=='"'))
               fldname = mkvar(colnames{icol});
               DAT.(fldname) = cellfun(@(x) x([2:end-1]),RAW{icol},'UniformOutput',0);
            end
         else
            DAT.(fldname) = str2double((RAW{icol}));
            if any(isnan(DAT.(fldname)))
               DAT.(fldname) = RAW{icol};
            end
         end
         
      end

   end

%% out

   if nargout<2
      varargout = {DAT};
   elseif nargout==2
      varargout = {DAT,UNITS};
   elseif nargout==3
      varargout = {DAT,UNITS,META};
   else
      error('syntax [DATA,<units>] = csv2struct(...)')
   end
   
%% EOF   