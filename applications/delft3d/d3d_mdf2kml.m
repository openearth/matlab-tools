function OPT = d3d_mdf2kml(mdf,varargin)
%D3D_MDF2KML  One line description goes here.
%
%   Create a kml-file (or kmz-file) of a Delft3D model setup
%
%   Syntax:
%   d3d_mdf2kml(mdf,<keyword,value>)
%
%   Input:
%   mdf  = filename of the mdf file
%
%   Keyword-value pairs:
%   epsg      = epsg code of the grid
%   dep       = switch for bathymetry output (true/false)
%   dry       = switch for dry points output (true/false)
%   thd       = switch for thin dams output (true/false)
%   kmz       = switch for saving to kmz (true/false)
%
%
%   Example
%   d3d_mdf2kml()
%
%   See also DELTF3D_GRD2KML

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 16 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Handle input arguments

if ~exist(mdf,'file')
    error('mdf file does not exist')
    return
end

[pathstr,name,ext,versn] = fileparts(mdf);
if isempty(pathstr)
    pathstr = pwd;
end

OPT.epsg        = 4326;             % epsg-code: 28992; % 7415; % 28992; ['Amersfoort / RD New']
OPT.ddep        = 10;               % height offset
OPT.grdColor    = [0.7 0.7 0.7];    % color of grid lines
OPT.dep         = false;            % switch for bathymetry
OPT.clim        = [-50 0];          % color limits for bathymetry
OPT.dry         = false;            % switch for dry points
OPT.dryColor    = [1 0 0.5];        % color of dry points
OPT.thd         = false;            % switch for thin dams
OPT.thdColor    = [0 1 0];          % color for thin dams
OPT.thdWidth    = 2;                % width of thin dams
OPT.kmz         = false;            % switch for output to kmz

OPT = setproperty(OPT,varargin{:});

%% Read mdf-file
MDF = delft3d_io_mdf('read',mdf);
G = wlgrid('read',MDF.keywords.filcco);
xg = G.X;
yg = G.Y;

%% Convert grid
z = repmat(10,size(xg));
if OPT.epsg ~= 4326
    [xg,yg]=convertCoordinates(xg,yg,'CS1.code',OPT.epsg,'CS2.code',4326);
end

kml1 = 'grid.kml';

KMLmesh(yg,xg,z,...
    'fileName',kml1,...
    'kmlName','grid',...
    'lineColor',OPT.grdColor,...
    'lineAlpha',.6,...
    'lineWidth',1);

%% Convert bathymetry
if isfield(MDF.keywords,'fildep')
    OPT2 = delft3d_grd2kml(MDF.keywords.filcco,'epsg',OPT.epsg,'mdf',mdf,'dep',MDF.keywords.fildep,'clim',OPT.clim,'ddep',1);
else
    OPT2 = delft3d_grd2kml(MDF.keywords.filcco,'epsg',OPT.epsg,'mdf',mdf);
end

kml2 = [filename(MDF.keywords.filcco),'_2D.kml'];
delete([filename(MDF.keywords.filcco),'_3D.kml']);
delete([filename(MDF.keywords.filcco),'_3D_ver_lft.png']);

%% Process dry points
if OPT.dry
    D = delft3d_io_dry('read' ,MDF.keywords.fildry);
    nr = length(D.m);
    
    for i = 1:nr
        m1=min(D.m0(i),D.m1(i));
        n1=min(D.n0(i),D.n1(i));
        m2=max(D.m0(i),D.m1(i));
        n2=max(D.n0(i),D.n1(i));
        x1=xg(m1-1:m2,n1-1)';
        y1=yg(m1-1:m2,n1-1)';
        x1=[x1 xg(m2,n1-1:n2)];
        y1=[y1 yg(m2,n1-1:n2)];
        x1=[x1 xg(m2:-1:m1-1,n2)'];
        y1=[y1 yg(m2:-1:m1-1,n2)'];
        x1=[x1 xg(m1-1,n2:-1:n1-1)];
        y1=[y1 yg(m1-1,n2:-1:n1-1)];
        xDry{i} = x1';
        yDry{i} = y1';
    end
    
    [m,n]=size([xDry{:}]);
    z = mat2cell(repmat(OPT.ddep+1, size([xDry{:}])),m,repmat(1,n,1));
    
    kml3 = 'drypoints.kml';
    KMLpatch3(yDry,xDry,z,'fileName',kml3,'fillColor',OPT.dryColor,'fillAlpha',0.8,'kmlName','drypoints');
end
%% Process thin dams
if OPT.thd
    T = delft3d_io_thd('read' ,MDF.keywords.filtd);
    nr = length(T.m);
    xThd = [];
    yThd = [];
    
    for i = 1:nr
        m1=min(T.m(:,i));
        n1=min(T.n(:,i));
        m2=max(T.m(:,i));
        n2=max(T.n(:,i));
        k=0;
        for jj=m1:m2
            for kk=n1:n2
                k=k+1;
                m=jj;
                n=kk;
                if strcmpi(T.DATA(i).direction,'u')
                    xThd = [xThd nan xg(m,n-1) xg(m,n)];
                    yThd = [yThd nan yg(m,n-1) yg(m,n)];
                else
                    xThd =[xThd nan xg(m-1,n) xg(m,n)];
                    yThd =[yThd nan yg(m-1,n) yg(m,n)];
                end
            end
        end
    end
    
    z = repmat(OPT.ddep+2, size(xThd));
    
    kml4 = 'thindams.kml';
    KMLline(yThd',xThd',z','lineWidth',OPT.thdWidth,'lineColor',OPT.thdColor,'fileName',kml4,'kmlName','thindams');
end
%% Merge kml-files to one
KMLmerge_files('sourceFiles',{kml1,kml2,kml3,kml4},'fileName',[name,'.kml']);

delete(kml1);
delete(kml2);
delete(kml3);
delete(kml4);

if OPT.kmz
    ge_makekmz([name,'.kmz'],'sources',{[name,'.kml'],[filename(MDF.keywords.filcco),'_2D_ver_lft.png']})
    delete([name,'.kml']);
    delete([filename(MDF.keywords.filcco),'_2D_ver_lft.png']);
end
