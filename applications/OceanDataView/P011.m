function varargout = P011(varargin);
%P011   read/search BODC P011 parameter vocabulary
%
%    L = P011('read',1)
%
% returns struct with field per database entry.
%
%    <indices> = P011(<L>,'find','pattern')
%
% displays table AND returns indices into fields of L after
% searching the description (long_name, entryTerm).
%
%    OK = P011(<L>,'verify','standard_name')
%
% checks whether standard_name (entryKey) is present in vocab.
%
%    description = P011(<L>,'find'  ,'standard_name')
%
% returns description (long_name, entryTerm) of standard_name (entryKey).
%
% The P011 parameter vocabulary needs to be downloaded (xml) 
% first from
% http://www.bodc.ac.uk/products/web_services/
% into the directory >> fileparts(which('p011')).
%
% Examples:
%
%    L         = P011(  'read'       ,1         )
%    indices   = P011(L,'find'       ,'salinity');
%    OK        = P011(L,'verify'     ,'ODSDM021')
%    long_name = P011(L,'description','ODSDM021')
%    long_name = P011(L,'description','ODSDM0')
%
%See also: NERC_VERIFY, NC_CF_STANDARD_NAME_TABLE

%% Copyright notice
%   --------------------------------------------------------------------
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

L                 = [];
OPT.listReference = 'P011';
OPT.disp          = 1;
OPT.standard_name = 'entryKey';  % fieldname of L (xml)
OPT.long_name     = 'entryTerm'; % fieldname of L (xml)

OPT.read          = '';
OPT.find          = ''; % description to standard_name
OPT.verify        = ''; % check existence of standard_name
OPT.description   = ''; % standard_name to description 

if isstruct(varargin{1})
   L        =  varargin{1};
   varargin = {varargin{2:end}};
end

OPT = setproperty(OPT,varargin{:});

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

      fldnames = fieldnames(L2.codeTableRecord);
      
      for ifld=1:length(fldnames)
      
         fldname = fldnames{ifld};
      
         L.(fldname) = {L2.codeTableRecord(:).(fldname)};
         
      end
      
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
   ii = find(~cellfun(@isempty,ii));       % indices of non-empty searchpattern matches

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

   % cannot search for exact only due to presence of both list and list number in standard_name
   ii = regexpi(L.(OPT.standard_name),searchpattern); % per cell item, empty or start index of searchpattern
   ii = find(~cellfun(@isempty,ii));                  % indices of non-empty searchpattern matches
   
   if length(ii)==1
      OK = 1;
   elseif ii > 1
      disp(char({L.(OPT.long_name){ii}}))
      error('multiple occurences found, please specify unique id.')
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

   ii = regexpi(L.(OPT.standard_name),searchpattern); % per cell item, empty or start index of searchpattern
   ii = find(~cellfun(@isempty,ii));                  % indices of non-empty searchpattern matches
   
   long_name = char({L.(OPT.long_name){ii}}); % can be more than one

   if nargout==1
      varargout = {long_name};
   end

end

%% EOF
