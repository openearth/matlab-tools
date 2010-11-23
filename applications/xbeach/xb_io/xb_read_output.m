function variables = xb_read_output(fname, varargin)
%XB_READ_OUTPUT  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_read_output(fname, varargin)
%
%   Input:
%   varargin  = variables, timestepindex
%   Output:
%   varargout = variables
%
%   Example
%   variables = xb_read_output('xboutput.nc')
%   assert(ismember({variables.name},  'xw'))
%   variables = xb_read_output('outputdir')
%   assert(ismember({variables.name},  'xw'})
%   variables = xb_read_output('outputdir', variables, {'yw','zs'},
%   timestepindex, 100}
%   assert(~ismember({variables.name},  'xw'})
%   
%   TODO implement: strides={{':',':'},{1:1:3, 10:1:20, ':'}}, strides 
%
%
%   See also xb_read_input, xb_write_input

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <Deltares>
%       OSX
%
%       <fedor.baart@deltares.nl>	
%
%       <Delft>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

if isdir(fname) 
  variables = xb_read_dat(fname, varargin);
else 
  variables = xb_read_netcdf(fname, varargin);
end


%%
