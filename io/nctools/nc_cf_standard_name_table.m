function varargout = nc_cf_standard_name_table(varargin);
%nc_cf_standard_name_table    read/search CF parameter vocabulary
%
%    L = nc_cf_standard_name_table('read',1)
%
% returns struct with field per database entry.
%
%    <indices> = nc_cf_standard_name_table(<L>,'find','pattern')
%
% displays table AND returns indices into fields of L after
% searching the description (long_name).
%
%    OK = nc_cf_standard_name_table(<L>,'verify','standard_name')
%
% checks whether standard_name (id) is present in vocab.
%
%    description = nc_cf_standard_name_table(<L>,'find'  ,'standard_name')
%
% returns description (long_name) of standard_name (id).
%
% The nc_cf_standard_name_table parameter vocabulary needs to be downloaded (xml) 
% first from
% http://cf-pcmdi.llnl.gov/documents/cf-conventions
% into the directory >> fileparts(which('nc_cf_standard_names_table')).
%
% Examples:
%
%    L         = nc_cf_standard_name_table(  'read'       ,1         )
%    indices   = nc_cf_standard_name_table(L,'find'       ,'salinity');
%    OK        = nc_cf_standard_name_table(L,'verify'     ,'sea_water_salinity')
%    long_name = nc_cf_standard_name_table(L,'description','sea_water_salinity','exact',1)
%    long_name = nc_cf_standard_name_table(L,'description','sea_water_salinity','exact',0)
%
%See also: P011

%% Copyright notice
%   ----------------------------------------------------- ---------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% input

L = [];
OPT.listReference = 'cf-standard-name-table';
OPT.disp          = 1;
OPT.standard_name = 'id';          % fieldname of L (xml)
OPT.long_name     = 'description'; % fieldname of L (xml)
OPT.exact         = 1; % whether match description for standard_name should be exact

OPT.read          = '';
OPT.find          = ''; % description to standard_name
OPT.verify        = ''; % check existence of standard_name
OPT.description   = ''; % standard_name to description 

if isstruct(varargin{1})
   L        = varargin{1};
   varargin = {varargin{2:end}};
end

OPT = setProperty(OPT,varargin{:});

%% load and cache vocab

if ~isempty(OPT.read) | isempty(L)

    ncfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.nc'];
   matfile = [fileparts(mfilename('fullpath')) filesep OPT.listReference '.mat'];
   
   if exist(ncfile,'file')==2
   
      L = nc2struct(ncfile);
     %L = load     (matfile);
   
      disp([OPT.listReference ': loaded cached ' OPT.listReference '.xml'])
   
   else
   
      PREF.KeepNS = 0;
      
     % TODO
     % disp([OPT.listReference ': downloading looong xml file, please wait several minutes ...'])
     % urlwrite('')
      
      disp([OPT.listReference ': parsing looong xml file, please wait several minutes ...'])
   
      L2  = xml_read([OPT.listReference '.xml'],PREF);
      
     %save([fileparts(mfilename('fullpath')) OPT.listReference '.xml.mat'],'-struct','L2');
     
      % parse xml file, to allow indentical behavior for nc_cf_standard_name_table and P011
      
      L.(OPT.standard_name)  = cell(1,length(L2.entry));
      for i=1:length(L2.entry)
      L.(OPT.standard_name){i} = L2.entry(i).ATTRIBUTE.(OPT.standard_name); % can we do this shorter ?
      end
      
      L.(OPT.long_name) = {L2.entry(:).(OPT.long_name)};
      L.canonical_units = {L2.entry(:).canonical_units};
      
      ii = find((cellfun(@isnumeric,L.canonical_units)));
      for iii=1:length(ii)
         L.canonical_units{ii(iii)} = num2str(L.canonical_units{ii(iii)});
      end

      %% set empty to '' to make them char, so iscellstr is 1, so struct2nc works
      fldnames = fieldnames(L);
      for ifld = 1:length(fldnames)
      fldname = fldnames{ifld};
         ii = find((cellfun(@isempty,L.(fldname))));
         for iii=1:length(ii)
            L.(fldname){ii(iii)} = ' ';
         end
         iscellstr(L.(fldname)) % after
      end
      
      save([fileparts(mfilename('fullpath')) filesep 'cf-standard-name-table.mat'],'-struct','L');
      struct2nc(ncfile,L); % issue with cellstr
   
   end

   if nargout==1
      varargout = {L};
   end

end

%% find and display results of a search (description to standard_name)

   if ~isempty(OPT.find)

   % find indices

   searchpattern = OPT.find;
   ii = regexpi(L.(OPT.long_name),searchpattern); % per cell item, empty or start index of searchpattern
   ii = find(~cellfun(@isempty,ii));          % indices of non-empty searchpattern matches

   % make table
   
   if ~isempty(ii) & OPT.disp
   
   standard_names = {L.(OPT.standard_name){ii}};
   standard_names = strrep(standard_names,'http://vocab.ndg.nerc.ac.uk/term/','');
   standard_names = char(standard_names);
   
   n  = length(ii);
   n1 = size(standard_names             ,2);
   n2 = size(char(L.(OPT.long_name){ii}),2);

   disp([OPT.listReference ' entries matching: "',searchpattern,'"'])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   disp([pad(num2str([1:n]'),' ',-4) repmat(' | ',[n 1]) standard_names       repmat(' | ',[n 1]) char(L.(OPT.long_name){ii})])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   else
   disp([OPT.listReference ': no match found'])
   end

   % output
   
   if nargout==1
      varargout = {ii};
   end

end

%% find and display results of a search (standard_name presence)

if ~isempty(OPT.verify)

   searchpattern = OPT.verify;

   ii = strmatch(lower(searchpattern),lower(char(L.(OPT.standard_name)))) % only exact matches
   
   if length(ii)==1
      OK = 1;
   else
      OK = 0;
   end

   if nargout==1
      varargout = {OK};
   end

end

%% find and display results of a search (long_name to standard_name)

if ~isempty(OPT.description)

   searchpattern = OPT.description;

   if OPT.exact
      ii = strmatch(lower(searchpattern),lower(char(L.(OPT.standard_name)))) % only exact matches
   else
      ii = regexpi(L.(OPT.standard_name),searchpattern); % per cell item, empty or start index of searchpattern
      ii = find(~cellfun(@isempty,ii));                  % indices of non-empty searchpattern matches
   end
   
   long_name = char({L.(OPT.long_name){ii}}); % can be more than one

   if nargout==1
      varargout = {long_name};
   end

end

%% EOF
