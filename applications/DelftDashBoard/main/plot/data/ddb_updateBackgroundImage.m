function handles = ddb_updateBackgroundImage(handles)
%DDB_UPDATEBACKGROUNDIMAGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_updateBackgroundImage(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_updateBackgroundImage
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');
dx=(xl(2)-xl(1))/20;
dy=(yl(2)-yl(1))/20;
xl(1)=xl(1)-dx;
xl(2)=xl(2)+dx;
yl(1)=yl(1)-dy;
yl(2)=yl(2)+dy;

pos=get(handles.GUIHandles.mapAxis,'Position');

imageQuality=1;

% Coordinate system of bathymetry data or satellite image
switch handles.GUIData.backgroundImageType
    case{'bathymetry'}
        iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
        dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
        dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    case{'satellite'}
        dataCoord.name='WGS 84';
        dataCoord.type='geographic';
end
coord=handles.screenParameters.coordinateSystem;

% Find bounding box for data
if ~strcmpi(coord.name,dataCoord.name) || ~strcmpi(coord.type,dataCoord.type)
    [xtmp,ytmp]=meshgrid(xl(1):dx:xl(2),yl(1):dy:yl(2));
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,coord,dataCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=[xl(1) xl(2)];
    yl0=[yl(1) yl(2)];
end

% Clear some variables
clear xtmp ytmp xtmp2 ytmp2

% Now get the data
% In case of bathymetry data, get z values
% Otherwise get cdata
switch handles.GUIData.backgroundImageType
    case{'bathymetry'}
        % First get z data
        maxcellsize=(xl0(2)-xl0(1))/600;
        if strcmpi(dataCoord.type,'geographic')
            maxcellsize=maxcellsize*111111;
        end
        [x0,y0,z,ok]=ddb_getBathy(handles,xl0,yl0,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',maxcellsize);
        if ok
            % Now convert to current coordinate system
            res=(xl(2)-xl(1))/(pos(3)/imageQuality);
            if ~strcmpi(coord.name,dataCoord.name) || ~strcmpi(coord.type,dataCoord.type)
                % Interpolate on rectangular grid
                [x11,y11]=meshgrid(xl(1):res:xl(2),yl(1):res:yl(2));
                tic
                disp('Converting coordinates ...');
                [x2,y2]=ddb_coordConvert(x11,y11,coord,dataCoord);
                toc
                tic
                disp('Interpolating data ...');
                z11=interp2(x0,y0,z,x2,y2);
                toc
                x11=xl(1):res:xl(2);
                y11=yl(1):res:yl(2);
            else
                x11=squeeze(x0(1,:));
                y11=squeeze(y0(:,1));
                z11=z;
            end
            
            handles.GUIData.x=x11;
            handles.GUIData.y=y11;
            handles.GUIData.z=z11;
            
            handles=ddb_plotBackgroundBathymetryImage(handles,x11,y11,z11);
            
        end
        
    case{'satellite'}
        % Get the data
        tic
        disp('Getting image data ...');
        [xx,yy,cdata]=ddb_getMSVEimage(xl0(1),xl0(2),yl0(1),yl0(2),'zoomlevel',0,'npix',1200,'whatKind',lower(handles.screenParameters.satelliteImageType),'cache',handles.satelliteDir);
        toc
        
        % Now convert to current coordinate system
        if ~strcmpi(coord.name,dataCoord.name) || ~strcmpi(coord.type,dataCoord.type)
            % Interpolate on rectangular grid
            res=(xl(2)-xl(1))/(pos(3)/imageQuality);
            [x11,y11]=meshgrid(xl(1):res:xl(2),yl(1):res:yl(2));
            tic
            disp('Converting coordinates ...');
            [x2,y2]=ddb_coordConvert(x11,y11,coord,dataCoord);
            toc
            tic
            disp('Interpolating data ...');
            cdata=double(cdata);
            r1=interp2(xx,yy,cdata(:,:,1),x2,y2);
            g1=interp2(xx,yy,cdata(:,:,2),x2,y2);
            b1=interp2(xx,yy,cdata(:,:,3),x2,y2);
            cdata=[];
            cdata(:,:,1)=r1;
            cdata(:,:,2)=g1;
            cdata(:,:,3)=b1;
            cdata=uint8(cdata);
            x11=xl(1):res:xl(2);
            y11=yl(1):res:yl(2);
            toc
        else
            x11=xx;
            y11=yy;
        end
        
        tic
        disp('Plotting image data ...');
        handles=ddb_plotBackgroundSatelliteImage(handles,x11,y11,cdata);
        toc
        
end


