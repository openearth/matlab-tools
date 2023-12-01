function writeSLR(SLRfile,SLR)
% function writeSLR(SLRfile,SLR)
%
% Bas Huisman, 2023

% write SLR : Writes a unibest sea level rise file
%
%   Syntax:
%     function writeSLR(filename,SLRdata)
% 
%   Input:
%     filename                String with CLR filename
%     SLRdata                 Structure with SLR-data
%             .time           Date/time [year] as [Nx1]
%             .slrrate        Rate of sea level rise [m/yr] as [Nx1]
%             .slope          Slope of the active beach profile [1:slope] as [Nx1] (= width of active height / active height)
%   or
%     SLRdata                 Array of [Nx3] with columns of time, slrrate and slope
% 
%   Output:
%     '.slr file'
%
%   Example:
%     SLRdata.time = [2000,2100];
%     SLRdata.slrrate = [0.003,0.01];
%     SLRdata.slope = [150;150];
%     writeSLR('test.slr', SLRdata)
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

% $Id: writeSLR.m 19276 2023-11-30 13:32:38Z huism_b $
% $Date: 2023-11-30 14:32:38 +0100 (do, 30 nov 2023) $
% $Author: huism_b $
% $Revision: 19276 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeCLR.m $
% $Keywords: $

if isnumeric(SLR)
    SLR0=SLR;
    if size(SLR0,2)<3 && size(SLR0,1)==3
        SLR0=SLR0';
    end
    SLR=struct;
    SLR.time=SLR0(:,1);
    SLR.slrrate=SLR0(:,2);
    SLR.slope=SLR0(:,3);
end

%-----------Write data to file--------------
%-------------------------------------------
fid = fopen(SLRfile,'wt');
for ii=1:length(SLR.time)
    fprintf(fid,'  %4.0f  %8.3f  %8.3f \n',SLR.time(ii),SLR.slrrate(ii),SLR.slope(ii));
end 
fclose(fid); 
