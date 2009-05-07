function Xround = roundoff(X, n, varargin)
%ROUNDOFF   routine rounds number to predefined number of decimal digits
%
%   This routine returns a rounded number to a specified number of decimal
%   digits
%
%   Syntax:
%   Xround = roundoff(X, n, varargin)
%
%   Input:
%   X        = number, or matrix of numbers, to be rounded
%   n        = number of decimal digits to be rounded to (can also be
%              negative)
%   varargin = optional mode: either 'normal' (default), 'ceil' or 'floor'
%
%   Output:
%   Xround   = rounded X, same size as X
%
%   Example
%               roundoff(5.8652, 2)
%               ans =
%                   5.8700
%
%               roundoff(5.8652, 2, 'floor')
%               ans =
%                   5.8600
%
%               roundoff(5.8652, 0)
%               ans =
%                   6
%
%               roundoff(5.8652, -1)
%               ans =
%                   10
%
%   See also round

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

% Created: 07 May 2009
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% check input
if nargin == 1
    getdefaults('n', 0, 1);
elseif nargin == 0
    error('ROUNDOFF:NotEnoughInputs','At least input argument "X" must be specified')
end
if round(n) ~= n
    error('ROUNDOFF:IntegerReq','Input must be an integer')
end


%% check varargin
mode = 'normal';
if ~isempty(varargin)
    mode = varargin{1};
end

switch mode
    case 'ceil'
        Xround = ceil(X.*10.^n)./10.^n;
    case 'floor'
        Xround = floor(X.*10.^n)./10.^n;
    otherwise
        Xround = round(X.*10.^n)./10.^n;
end