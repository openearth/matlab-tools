function [XYZdata]=readXYZ(XYZfilename)
%read XYZ : Reads XYZ-files
%   
%   Syntax:
%     function [XYZdata]=readXYZ(XYZfilename)
%   
%   Input:
%     XYZfilename    string with filename of XYZ
%   
%   Output:
%     XYZdata        struct with contents of mda file
%                    .X           : X-coordinate [m]
%                    .Y           : Y-coordinate [m]
%                    .Z           : water depth [m]
%                    
%   Example:
%     
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Wiebe de Boer
%
%       wiebe.deboer@deltares.nl
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
% Created: 3 Nov 2010
% Created with Matlab version: 7.11.0 (R2010b)

%-----------read data from file--------------
%-------------------------------------------
fid=fopen(XYZfilename,'rt');
tline = fgetl(fid);
nn = 0;

while isstr(tline) & length(tline)>1
    nn = nn+1;
    [XYZdata.X(nn,1),XYZdata.Y(nn,1),XYZdata.Z(nn,1)] = strread(tline,'%f %f %f','delimiter',' ');
    tline = fgetl(fid);
end

fclose(fid);
