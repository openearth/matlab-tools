function allFont = findfont(varargin)
%FINDFONT   returns all font (= text + axes) handles in figure
%
% findfont returns all font (parent) handles in current figure
% findfont(handles) returns all font handles in children of
% handles.
%
% Do not use it to delete all fonts, as then you
% also delete the objects with emmbedded fonts (axes) themselves.
%
% Example:
% set(findfont,'fontsize',6)
%
% See also: TEXT, AXES

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Nov Delft University of Technology
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

if nargin==0
   H = gcf;
else
   H = varargin{1};
end

allText   = findall(H, 'type', 'text');
allAxes   = findall(H, 'type', 'axes');
allFont   = [allText; allAxes];

%% EOF
