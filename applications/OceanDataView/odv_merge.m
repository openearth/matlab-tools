function R = odvplot_overview_kml(D,varargin)
%odv_merge   merges set of odv files to one struct for one parameter
%
%   M = odv_merge(D(:))
%
% merges one parameter from multiple odv files read into D(:)
% into one struct with vectors.
%
%   odv_merge(D,'sdn_standard_name',''SDN:P011::ODSDM021'',<keyword,value>)
%
% Works only for trajectory data, i.e. when D.cast = 0;
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% $HeadURL

   OPT.sdn_standard_name = ''; % char or numeric: nerc vocab string (P011::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);

%% find column to plot based on sdn_standard_name

   if isempty(OPT.sdn_standard_name)
      [OPT.index.var, ok] = listdlg('ListString', {D(1).sdn_long_name{10:2:end}} ,...
                           'InitialValue', [1],... % first is likely pressure so suggest 2 others
                           'PromptString', 'Select single variables to plot as colored dots', ....
                                   'Name', 'Selection of c/z-variable');
      OPT.index.var = OPT.index.var*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D(1).sdn_standard_name)
      %disp(['SDN name: ',D.sdn_standard_name{i},'  <-?->  ',OPT.sdn_standard_name])
         if any(strfind(D(1).sdn_standard_name{i},OPT.sdn_standard_name))
            OPT.index.var = i;
            break
         end
      end
      if OPT.index.var==0
         error([OPT.sdn_standard_name,' not found.'])
         return
      end
   end
   
%% find column to use as vertical axis

   if D(1).cast
   if isempty(OPT.index.z)
      [OPT.index.z, ok] = listdlg('ListString', {D.sdn_long_name{10:2:end}} ,...
                           'InitialValue', 1,... % first is likely pressure so suggest it
                           'PromptString', 'Select the single variable to ue as y/z-vertex (depth, pressure, ...)', ....
                                   'Name', 'Selection of y/z-variable');
      OPT.index.z = OPT.index.z*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
         if any(strfind(D.sdn_standard_name{i},OPT.z));
            OPT.index.z = i;
            break
         end
      end
   end
   end

%%% merge parameter

   fldnames = ...
   {'odv_name',...
    'standard_name',...    
    'units',...    
    'local_name',...    
    'local_units',...       
    'sdn_long_name',...       
    'sdn_standard_name',...
    'sdn_units'};
    
    for ifld=1:length(fldnames)
       fldname = fldnames{ifld};
       R.(fldname) = D(1).(fldname){OPT.index.var};
    end

%%% merge data

   R.cruise       = cell([length(D),1]);
   R.station      = cell([length(D),1]);
   R.type         = cell([length(D),1]);
   R.datenum      = cell([length(D),1]);
   R.latitude     = cell([length(D),1]);
   R.longitude    = cell([length(D),1]);
   R.LOCAL_CDI_ID = cell([length(D),1]);
   R.EDMO_code    = cell([length(D),1]);
   R.data         = cell([length(D),1]);
   
   for i=1:length(D)
   
      R.cruise{i}       = D(i).data.cruise;
      R.station{i}      = D(i).data.station;
      R.type{i}         = D(i).data.type;
      R.datenum{i}      = D(i).data.datenum  ;
      R.latitude{i}     = D(i).data.latitude ;
      R.longitude{i}    = D(i).data.longitude;
      R.LOCAL_CDI_ID{i} = D(i).LOCAL_CDI_ID;
      R.EDMO_code{i}    = D(i).EDMO_code;
      
      value = str2num(char(D(i).rawdata{OPT.index.var,:}));
      if ~isempty(value)
         R.data{i}      = value; % error if empty, make nan
      end

      if D(1).cast
         R.data{i}      = str2num(char(D(i).rawdata{OPT.index.z,:}));
      end
   
   end
   
   R.data         = cell2mat(R.data     );
   R.datenum      = cell2mat(R.datenum  );
   R.latitude     = cell2mat(R.latitude );
   R.longitude    = cell2mat(R.longitude);

%% EOF