function varargout = Sprintsession_20081215_Examples(varargin)
%SPRINTSESSION_20081215_EXAMPLES  Various examples for sprintsession 2008-12-15
%
%   This function includes various examples for the sprintsession of
%   2008-12-15. This function is created using oetnewfun
%
%   Syntax:
%   varargout = Sprintsession_20081215_Examples(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Sprintsession_20081215_Examples
%
%   See also

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

% Created: 10 Dec 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% create a new function 'test'
% open a template for a new function in the matlab editor
oetnewfun('test')

% make sure that in the properties, the relevant svn:keywords are included.
% This can either be done autolmatically (to be set in subversion config
% file) or manually (which means for each file separately).

%% use of fullfile
% Use fullfile instead of a combined string to create a file or pathname.
% This much more flexible because:
% 1) it is platform independent
% 2) it doesn't matter whether the pathname ends with a filesep or not

fullfile('p:', 'mctools', 'ucit.demo')
% gives the same result as
fullfile('p:\mctools\', 'ucit.demo')
% and even the same result as
fullfile('p:/mctools/', 'ucit.demo')

%% use of propertyname-propertyvalue pairs
varargin = {'keyword1', 4,...
    'keywordn', 15,...
    'keyword2', 'value2'}; % usually the cell varargin is obtained via the input of the function

% define a structure (e.g. OPT) in your function in which the fieldnames
% are the keywords and the field contents are the default values
% When you use the following structure notation, it gives a clear overview
% of the available property names and the corresponding default values
OPT = struct(...
    'keyword1', 1,...
    'keyword2', 'value2',...
    'keyword3', {{'value' 3}},... % cell arrays should be put in double brackets
    'keywordn', 10);

[OPT Set Default] = setProperty(OPT, varargin{:});