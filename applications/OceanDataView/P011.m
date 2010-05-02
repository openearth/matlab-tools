function varargout = P011(varargin);
%P011   read/search BODC P011 parameter vocabulary
%
%    L = P011('read')
%
% returns struct with field per database entry.
%
%    <indices> = P011(<L>,'find','pattern')
%    <indices> = P011(<L>,'disp','pattern')
%
% displays table and returns indces into fields of L.
%
% The p011 parameter vocabulary needs to be downloaded (xml) 
% first from
% http://www.bodc.ac.uk/products/web_services/
% into the directoty >> fileparts(which('p011')).
%
% A direct url to P011 is:
% http://vocab.ndg.nerc.ac.uk/axis2/services/vocab/getList?recordKey=http://vocab.ndg.nerc.ac.uk/list/P061/current&earliestRecord=1900-01-01T00:00:00Z
%
% Examples:
%
%    P011(L,'disp','salinity')
%
%See also: NERC_VERIFY

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
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

if isstruct(varargin{1})
   L = varargin{1};
   varargin = {varargin{2:end}};
end

%% load vocab

if strcmpi(varargin{1},'read')

   ncfile = [fileparts(mfilename('fullpath')) filesep 'P011.nc'];
   
   if exist(ncfile,'file')==2
   
      L = nc2struct(ncfile);
   
      disp('P011: loaded cached P011.xml')
   
   else
   
      PREF.KeepNS = 0;
      
     % TODO
     %disp('P011: downloading looong xml file, please wait several minutes ...')
     %urlwrite('')
      
      disp('P011: parsing looong xml file, please wait several minutes ...')
   
      L2  = xml_read('P011.xml',PREF);
      
      save([fileparts(mfilename('fullpath')),'P011.mat'],'-struct','L2');
      
      fldnames = fieldnames(L2.codeTableRecord);
      
      for ifld=1:length(fldnames)
      
         fldname = fldnames{ifld};
      
         L.(fldname) = {L2.codeTableRecord(:).(fldname)};
         
      end
      
      struct2nc([fileparts(mfilename('fullpath')),'P011.nc'],L);
   
   end

   if nargout==1
      varargout = {L};
   end

%% display results of a search

elseif strcmpi(varargin{1},'find') | ...
       strcmpi(varargin{1},'disp')

   % find indices

   searchpattern = varargin{2};
   ii = regexpi(L.entryTerm,searchpattern); % per cell item, empty or start index of searchpattern
   ii = find(~cellfun(@isempty,ii));       % indices of non-empty searchpattern matches

   % make table
   
   if ~isempty(ii)
   
   standard_names = {L.entryKey{ii}};
   standard_names = strrep(standard_names,'http://vocab.ndg.nerc.ac.uk/term/','');
   standard_names = char(standard_names);
   
   n  = length(ii);
   n1 = size(standard_names       ,2);
   n2 = size(char(L.entryTerm{ii}),2);

   disp(['P011 entries matching: "',searchpattern,'"'])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   disp([pad(num2str([1:n]'),' ',-4) repmat(' | ',[n 1]) standard_names       repmat(' | ',[n 1]) char(L.entryTerm{ii})])
   disp([                            '-----+-'           repmat('-',[1 n1])   '-+-'               repmat('-',[1 n2])   ])
   else
   disp('P011: no match found')
   end

   % output
   
   if nargout==1
      varargout = {ii};
   end

end


%% EOF
