function nctools_test()
%NCTOOLS_TEST  Test file for nctools library.
%
%   Test script for testing the snctools and mexnc library. 
%
%   Syntax:
%   nctools_test()
%
%   Example
%   nctools_test
%
%   See also nctools

%   --------------------------------------------------------------------
%   Copyright (C) 2009 <COMPANY>
%       
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created with Matlab version: 7.5.0.338 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords:

%% Write test
function writetest()
filename = fullfile(tempdir, 'tmp.nc');
varstruct = struct('Name', 'temp', 'Nctype', 'double', 'Dimension', {{ 'temp' }});
value = rand(5,1); % random value
delete(filename); %remove file
nc_create_empty(filename); %create file
nc_add_dimension(filename, 'temp', 5); %create dimension
nc_addvar(filename, varstruct); %create variable 
nc_varput(filename, 'temp', value);
newvalue = nc_varget(filename, 'temp');
msg = sprintf('Data not succesfully written and read. SNCTOOLS java was %d', getpref('SNCTOOLS', 'USE_JAVA'));
assert(all(value == newvalue), msg);
end
setpref ('SNCTOOLS', 'USE_JAVA', true); % this requires SNCTOOLS 2.4.8 or better
writetest
setpref ('SNCTOOLS', 'USE_JAVA', false); % this requires SNCTOOLS 2.4.8 or better
writetest
end
