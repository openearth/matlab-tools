function oetnewfun(varargin)
% OETNEWFUN  Create a new function given the filename
%
% Routine to create a new function including help block template and
% copyright block. Description, company, address, email and author can be
% specified using property value pairs. Except the description, all
% properties are by default obtained using the command getenv function. 
%
% Syntax:
% oetnewfun('filename')
% oetnewfun('filename', 'PropertyName', PropertyValue,...)
%
% Input:
% varargin  = 'filename'
% PropertyNames: 
%   'description' = One line description
%   'Company'     = string containing company name
%   'address'     = cell array of strings with the address
%   'email'       = string containing email address
%   'Author'      = string containing the author name
%
% Example:
% %% create relevant fields in your PC (only once)
% setenv('COMPANY', 'Deltares')
% setenv('ADDRESS', '{''Deltares'' ''P.O. Box 177'' ''2600 MH Delft'' ''The Netherlands''}')
% setenv('EMAIL', 'your.email@Deltares.nl')
% setenv('NAME', 'Your Name')
% %% create new function
% oetnewfun('filename',...
%     'description', 'This is an example of a new function.')
%
% See also: newfun getenv setenv

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
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

%% defaults
OPT = struct(...
    'description', 'One line description goes here.',...
    'Company', getenv('COMPANY'),...
    'address', {eval(getenv('ADDRESS'))},...
    'email', getenv('EMAIL'),...
    'Author', getenv('NAME'));

OPT = setProperty(OPT, varargin{2:end});

% make sure that address is a cell array
if ischar(OPT.address)
    OPT.address = {OPT.address};
end

%%
if nargin ~= 0 && ischar(varargin{1})
    DefaultName = varargin{1};
else
    DefaultName = '';
end

[fpath fname] = fileparts(fullfile(cd, DefaultName));

% read template file
fid = fopen(which('oettemplate.m'));
str = fread(fid, '*char')';
fclose(fid);

% replace strings in template
str = strrep(str, '$filename', fname);
str = strrep(str, '$FILENAME', upper(fname));
str = strrep(str, '$description', OPT.description);
str = strrep(str, '$date(dd mmm yyyy)', datestr(now, 'dd mmm yyyy'));
str = strrep(str, '$date(yyyy)', datestr(now, 'yyyy'));
str = strrep(str, '$Company', OPT.Company);
str = strrep(str, '$author', OPT.Author);
str = strrep(str, '$email', OPT.email);
address = sprintf('%%       %s\n', OPT.address{:});
address = address(1:end-1);
str = strrep(str, '%       $address', address);
str = strrep(str, '$version', version);

%% open new file in editor
com.mathworks.mlservices.MLEditorServices.newDocument(str)