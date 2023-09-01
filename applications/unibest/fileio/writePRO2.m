function writePRO2(PROfile,PROdata)
%write PRO : Writes a unibest profile file 
%
%   Syntax:
%     function writePRO2(PROfile,PROdata)
% 
%   Input:
%     PROfile              Name of profile to be written
%     PROdata              Structure with profile information
%          .profX              [Nx1] vector with x coordinates
%          .profZ              [Nx1] vector with y coordinates
%          .codeDIR            Code X-Direction: +1/-1  Landwards/Seawards)
%          .cpntcoast          Reference X-point coastline  
%          .xpntdynbnd         X-point dynamic boundary
%          .xpnttrunc          X-point trunction transpor_CFSt
%          .codeZ              Code Z-Direction; +1/-1 Bottom-Level/Depth)
%          .reflevel           correction for reference level
%          .gridX              [Nx1] vector with x-locations of specified gridDX
%          .gridDX             [Nx1] vector with dx of grid
% 
%   Output:
%     .pro files
%
%   Example:
%     writePRO(PROfile,PROdata)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Boussinesqweg 1
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
% Created: 1 Oct 2018
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writePRO.m 12357 2015-11-12 12:33:26Z huism_b $
% $Date: 2015-11-12 13:33:26 +0100 (Thu, 12 Nov 2015) $
% $Author: huism_b $
% $Revision: 12357 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writePRO2.m $
% $Keywords: $

    %------------Read input data----------------
    %-------------------------------------------
    fid = fopen(PROfile,'wt');
    if PROdata.codeDIR<=0
        fprintf(fid,'-1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
    else
        fprintf(fid,' 1                 (Code X-Direction: +1/-1  Landwards/Seawards)\n');
    end
    fprintf(fid,'%3.0f                (reference X-point coastline)\n',PROdata.cpntcoast);
    fprintf(fid,'%5.2f                (X-point dynamic boundary)\n',PROdata.xpntdynbnd);
    fprintf(fid,'%5.2f                (X-point trunction transpor_CFSt)\n',PROdata.xpnttrunc);
    if PROdata.codeZ<=0
        fprintf(fid,'-1                 (Code Z-Direction; +1/-1 Bottom-Level/Depth)\n');
    else
        fprintf(fid,' 1                 (Code Z-Direction; +1/-1 Bottom-Level/Depth)\n');
    end
    fprintf(fid,'%3.0f                 (Reference level)\n',PROdata.reflevel);
    fprintf(fid,'%3.0f                 (Number of points for Dx)\n',length(PROdata.gridX));
    fprintf(fid,'         X     DX\n');
    for xx=1:length(PROdata.gridX)
        fprintf(fid,'%6.2f  %6.1f\n',[PROdata.gridX(xx) PROdata.gridDX(xx)]);
    end
    fprintf(fid,'%3.0f                 (Number of points for Profile)\n',length(PROdata.profX));
    fprintf(fid,'         X     Depth   \n');
    for xx=1:length(PROdata.profX)
        fprintf(fid,'%6.2f  %6.2f\n',[PROdata.profX(xx) PROdata.profZ(xx)]);
    end
    fclose(fid);
end