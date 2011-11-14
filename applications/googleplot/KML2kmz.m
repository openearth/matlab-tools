function varargout = KML2kmz(varargin)
%KML2KMZ   zip kml (and subsidiary files) files into kmz
%
%    KMLkmz(kml_file,<other_files,<other_files,<...>>>)
%
% where any other_files can be a char or a cellstr (collection of other_files)
%
% example
%
%    KML2kmz('release.kml',{'icon_file.png','figure_file.png'},'logo_file.png')
%
%    will create 'release.kmz' with inside {release.kml','icon_file.png','figure_file.png','logo_file.png'}
%
% The original kml_file is left inact.
%
% For more info: http://code.google.com/intl/nl/apis/kml/documentation/kmzarchives.html
%
%See also: Googleplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares for Building with Nature
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

%% gather all files

   if        ischar(varargin{1})
   kml_file       = varargin{1};
   elseif iscellstr(varargin{1})
   kml_file       = varargin{1}{1};
   end
   
   all_files = {};
   for i=1:nargin
     if                 ischar(varargin{i})
       all_files = {all_files{:} varargin{i}};
     elseif          iscellstr(varargin{i})
       all_files = {all_files{:} varargin{i}{:}};
     else
         varargin{2}
       error(['nly cellstr or char allowed for input: ',num2str(i)])
     end
   end

%% remove redundancies

   all_files = unique(all_files);

%% check

ii = strmatch('.kml',cellfun(@(x)fileext(x),all_files,'UniformOutput',0));
n = length(ii);
   if n > 1
      char(all_files{ii})
      error(['Each *.kmz may contain only one *.kml (with can have arbitrary name), whereas yours has ',num2str(n),' *.kml files.'])
   end

%% go

   kmz_file = fullfile(fileparts(kml_file),[filename(kml_file) '.kmz']);
   
   zip     ([tempdir filesep filename(kml_file),'.zip'],all_files);
   copyfile([tempdir filesep filename(kml_file),'.zip'],kmz_file);
   delete  ([tempdir filesep filename(kml_file),'.zip']);

%% EOF