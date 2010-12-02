function xb_generateOvertoppingTimeseries_example(varargin)
%XB_GENERATEOVERTOPPINGTIMESERIES_EXAMPLE  example of generating overtopping timeseries

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% Created: 20 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

[time obs_x obs_y velocity depth discharge] = xb_generateOvertoppingTimeseries(...
    'basedir',   fullfile(fileparts(mfilename('fullpath')), 'exampleoutput'), ...    % description of input argument 1
    'stride_t',  1, ...     % take a stride of OPT.stride_t through the time vector
    'obs_x',     [], ...
    'obs_y',     [], ...
    'obs_n',     [100 100], ...
    'obs_m',     [100 110])
