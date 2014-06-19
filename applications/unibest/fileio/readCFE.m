function output = readCFE(filename)
%read CFE : Reads a unibest wave parameter file
%
%   Syntax:
%     function readCFE(filename)
% 
%   Input:
%    filename             string with filename
%  
%   Output:
%     data structure for cfe file containing variables and their values
%
%   Example:
%     readCFE('test.cfe')
%
%   This script was not tested much, please contact me including the CFE
%   file if errors arise
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%-----------Read data to structure----------
%-------------------------------------------
fid = fopen(filename,'rt');

line1 = [fgetl(fid) '    dummy']; % dummy is added to make sure the last variable is named correctly (due to end-1 stuff) 

values = str2num(fgetl(fid));

inds = find((double(line1)~=32)==1);

start_inds = [1 (find(diff(inds)~=1)+1) size(inds,2)];

for ii=1:(size(start_inds,2)-2)
    names{ii,1} = line1(inds(start_inds(ii)):(inds(start_inds(ii+1)-1)));
    eval(['output.' names{ii,1} ' = values(1,ii);']);
end

fclose(fid);

