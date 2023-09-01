function writeLTR2(filename, orientation, active_height, pro_file, cfs_file, cfe_file, sco_file, varargin)
%write LTR : Writes a unibest lt-run specification file (automatically computing coast angle)
%
%   Syntax:
%     function writeLTR(filename, LTRdata)
%       or :
%     function writeLTR(filename, orientation, active_height, pro_file, cfs_file, cfe_file, sco_file, ray_file)
% 
%   Input:
%     filename             string with output filename
%     LTRdata              Structure with the following fields:
%                          .angle
%                          .h0
%                          .pro_file
%                          .cfs_file
%                          .cfe_file
%                          .sco_file
%                          .ray_file
% 
%     or alternatively:
%     filename             string with output filename
%     orientation          Shoreline orientation, [nx1]
%     active_height        Active height (closure depth + active beach crest) ([Nx1] matrix or single value)
%     pro_file             string with name of the pro-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     cfs_file             string with name of the cfs-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     cfe_file             string with name of the cfe-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     sco_file             string with name of the sco-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%     ray_file             (optional; assumed to be similar to sco-file otherwise) string with name of the ray-file(s) (either {Nx1} cellstr or 1 string (then a number is added automatically))
%  
%   Output:
%     .LTR file
%
%   Example:
%     writeLTR('test.ltr', 20, [], 8, 'diep', 'bijker', 'waves', 'baseline', 'baseline')
%     writeLTR('test.ltr', 'shore.pol', 'loc.ldb', 5, 'diep', 'bijker', 'waves', 'baseline', 'baseline')
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

% $Id: writeLTR.m 17266 2021-05-07 08:01:51Z huism_b $
% $Date: 2021-05-07 10:01:51 +0200 (vr, 07 mei 2021) $
% $Author: huism_b $
% $Revision: 17266 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeLTR.m $
% $Keywords: $

if isstruct(orientation)

    LTRdata = orientation;
    
    fid = fopen(filename,'wt');
    fprintf(fid,'%s\n','Number of Climates');
    fprintf(fid,'%s\n', num2str(LTRdata.no));
    fprintf(fid,'%s\n','         ORKST     PROFH     .PRO       .CFS       .CFE       .SCO       .RAY');
    for ii=1:LTRdata.no
        fprintf(fid,'     %8.2f    %8.2f   ''%s''   ''%s''  ''%s''  ''%s''  ''%s'' \n',LTRdata.angle(ii), LTRdata.h0(ii), LTRdata.pro_file{ii}, LTRdata.cfs_file{ii}, LTRdata.cfe_file{ii}, LTRdata.sco_file{ii}, LTRdata.ray_file{ii} );
    end
    fclose(fid);
    
elseif nargin>=8

    %-----------Catch input data----------------
    %-------------------------------------------
    number_of_rays    = max(max(length(sco_file),length(pro_file)),length(orientation));

    %-----------Catch input data----------------
    %-------------------------------------------
    err=0;
    if length(orientation)~=number_of_rays
        orientation = repmat(orientation(1),[number_of_rays 1]);
    end
    if length(active_height)~=number_of_rays
        active_height = repmat(active_height(1),[number_of_rays 1]);
    end
    if length(pro_file)~=number_of_rays
        pro_file = [repmat(pro_file,[number_of_rays 1])];
        pro_file = [pro_file, num2str([1:number_of_rays]','%02.0f')];
        pro_file = num2cell(pro_file,2);
    end
    if length(cfs_file)~=number_of_rays
        cfs_file = [repmat(cfs_file,[number_of_rays 1])];
        %cfs_file = [cfs_file, num2str([1:number_of_rays]','%02.0f')];
        cfs_file = num2cell(cfs_file,2);
    end
    if length(cfe_file)~=number_of_rays
        cfe_file = [repmat(cfe_file,[number_of_rays 1])];
        %cfe_file = [cfe_file, num2str([1:number_of_rays]','%02.0f')];
        cfe_file = num2cell(cfe_file,2);
    end

    if length(sco_file)~=number_of_rays
        sco_file = [repmat(sco_file,[number_of_rays 1])];
        sco_file = [sco_file, num2str([1:number_of_rays]','%02.0f')];
        sco_file = num2cell(sco_file,2);
    end

    if nargin==9
        ray_file = varargin{1};
        if length(ray_file)~=number_of_rays
            ray_file = [repmat(ray_file,[number_of_rays 1])];
            ray_file = [ray_file, num2str([1:number_of_rays]','%02.0f')];
            ray_file = num2cell(ray_file,2);
        end
    else
        ray_file = sco_file;
    end

    %-----------Write data to file--------------
    %-------------------------------------------
    if err==0
        fid = fopen(filename,'wt');
        fprintf(fid,'%s\n','Number of Climates');
        fprintf(fid,'%s\n', num2str(number_of_rays));
        fprintf(fid,'%s\n','         ORKST     PROFH     .PRO      .CFS      .CFE      .SCO      .RAY');
        for ii=1:number_of_rays
            fprintf(fid,'     %8.2f    %8.2f   ''%s''%s  ''%s''  ''%s''  ''%s''  ''%s'' \n',orientation(ii), active_height(ii), pro_file{ii},repmat(' ',[1 max(0,25-length(pro_file{ii}))]), cfs_file{ii}, cfe_file{ii}, sco_file{ii}, ray_file{ii});
        end
        fclose(fid);
    else
        fprintf(' warning: input incorrectly specified!')
    end

else
    fprintf('Error in writing LTR file : Number of input variables is incorrect! \n');
end

