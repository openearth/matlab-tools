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
%
% Example:
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
%       P.O. Box 5048
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
OPT = getlocalsettings;

OPT.description = 'One line description goes here.';

OPT = setProperty(OPT, varargin{2:end});

if ischar(OPT.ADDRESS)
    OPT.ADDRESS = {OPT.ADDRESS};
end

%%
if nargin ~= 0 && ischar(varargin{1})
    DefaultName = varargin{1};
else
    DefaultName = 'Untitled';
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
str = strrep(str, '$Company', OPT.COMPANY);
str = strrep(str, '$author', OPT.NAME);
str = strrep(str, '$email', OPT.EMAIL);
address = sprintf('%%       %s\n', OPT.ADDRESS{:});
address = address(1:end-1);
str = strrep(str, '%       $address', address);
str = strrep(str, '$version', version);

%% open new file in editor
com.mathworks.mlservices.MLEditorServices.newDocument(str)