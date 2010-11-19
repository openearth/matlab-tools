function xb_read_output_test()
% XB_READ_OUTPUT_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <Deltares>
%       
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

% This tools is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTest.category('UnCategorized');


outputdir = fullfile('temp_calculation')
outputfile = fullfile(outputdir, 'xboutput.nc')

% Does the function still run
% Does the function output zs by default
variables = xb_read_output(outputfile)
assert(ismember('zs', {variables.name}));
% Do we have some values?
assert(isnumeric(variables(1).values));


% Does the function still run
% Does the function output xw by default
variables = xb_read_output(outputdir)
assert(ismember('zs', {variables.name}));
% Do we have some values?
assert(isnumeric(variables(1).values));

% Does the function not output zs if we don't want it to.
% TODO: this doesn't work yet.....
variables = xb_read_output(outputfile)
zb1 = variables(ismember({variables.name},'zb')).values;
clear variables
variables = xb_read_output(outputdir)
zb2 = variables(ismember({variables.name},'zb')).values;
clear variables
assert(all(zb1(:) == zb2(:)))


% Does the function not output zs if we don't want it to.
% TODO: this doesn't work yet.....
variables = xb_read_output(outputfile, 'variables', {'zb'}, 'timestepindex', 100)
assert(~ismember('zs', {variables.name}));


% Does the function not output xw if we don't want it to.
% TODO: this doesn't work yet.....
variables = xb_read_output(outputdir, 'variables', {'zb'}, 'timestepindex', 100)
assert(~ismember('zs', {variables.name}));
