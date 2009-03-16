function X = deterministic(P, x, varargin)
%DETERMINISTIC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = deterministic(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   deterministic
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% Created: 09 Mar 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%%
if isscalar(x)
    X = repmat(x, size(P));
else
    X = x;
end