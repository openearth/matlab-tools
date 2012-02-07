function [RAYlocdata]=ddb_readRAYloc(RAYlocfile)
%read MDA : Reads UNIBEST MDA-files
%   
%   Syntax:
%     function [MDAdata]=readMDA(MDAfilename)
%   
%   Input:
%     MDAfilename    string with filename of MDA
%   
%   Output:
%     MDAdata        struct with contents of mda file
%                    .X           : X-coordinate of reference line [m]
%                    .Y           : Y-coordinate of reference line [m]
%                    .Y1          : Offset of coastline from reference line [m]
%                    .nrgridcells : Number of grid cells in-between current and previous reference line point
%                    .nr          : Index of reference line point
%                    .Y2          : Offset of coastline from reference line on the right side of a coastline point [m]
%                    .Xcoast      : X-coordinate of coastline [m]
%                    .Ycoast      : Y-coordinate of coastline [m]
%   
%   Example:
%     x = [1:10:1000]';
%     y = x.^1.2;
%     writeMDA('test.mda', [x,y]);
%     [MDAdata]=readMDA('test.mda');
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $


%-----------read data from file--------------
%-------------------------------------------
RAYlocdata = '';
fid = fopen(RAYlocfile,'rt');
tline = fgetl(fid);
nn = 0;

while ~isempty(tline) & length(tline)>1
    nn = nn+1;
    [RAYlocdata.X1(nn,1),RAYlocdata.Y1(nn,1),RAYlocdata.X2(nn,1),RAYlocdata.Y2(nn,1),RAYlocdata.Ray(nn,1)] = strread(tline,'  %f  %f  %f  %f  %s','delimiter',' ');
    %Remove quotes
    dummy = RAYlocdata.Ray{nn,1};
    idquote = findstr(dummy,'''');
    idstr = setdiff(1:length(dummy),idquote);
    RAYlocdata.Ray(nn,1)={dummy(idstr)}; 
    tline = fgetl(fid);
end
if  isempty(RAYlocdata)
    fprintf('File contains no data.\n')
    return
end
fclose(fid);
