function handles = ddb_generateNewBathymetryDataset(handles)
%DDB_GENERATENEWBATHYMETRYDATASET  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_generateNewBathymetryDataset(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_generateNewBathymetryDataset
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
Coord=handles.ScreenParameters.CoordinateSystem;

if handles.Bathymetry.NewDataset.AutoLimits
    
    ii=handles.Bathymetry.ActiveUsedDataset;
    k=strmatch(handles.Bathymetry.UsedDataset(ii).Name,handles.Bathymetry.Datasets,'exact');
    data=handles.Bathymetry.Dataset(k);
    
    BathyCoord.Name=handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Name;
    BathyCoord.Type=handles.Bathymetry.Dataset(k).HorizontalCoordinateSystem.Type;
    
    xlim(1)=min(min(data.x));
    xlim(2)=max(max(data.x));
    ylim(1)=min(min(data.y));
    ylim(2)=max(max(data.y));
    
    dx=handles.Bathymetry.NewDataset.dX;
    dy=handles.Bathymetry.NewDataset.dY;
    
    if strcmpi(Coord.Name,BathyCoord.Name)
        xl=xlim;
        yl=ylim;
    else
        [xl,yl]=ddb_coordConvert(xlim,ylim,BathyCoord,Coord);
    end
    xl
    yl
    xl(1)=dx*floor(xl(1)/dx);
    xl(2)=dx*ceil(xl(2)/dx);
    yl(1)=dy*floor(yl(1)/dy);
    yl(2)=dy*ceil(yl(2)/dy);
    
else
    
    xl(1)=handles.Bathymetry.NewDataset.XMin;
    xl(2)=handles.Bathymetry.NewDataset.XMax;
    yl(1)=handles.Bathymetry.NewDataset.YMin;
    yl(2)=handles.Bathymetry.NewDataset.YMax;
    
end

% xl and yl are the limits of the new coordinate system

x1=xl(1):dx:xl(2);
y1=yl(1):dy:yl(2);

[xg,yg]=meshgrid(x1,y1);
[xg,yg]=ddb_coordConvert(xg,yg,Coord,BathyCoord);

x0=data.x;
y0=data.y;
z0=data.z;

z1=interp2(x0,y0,z0,xg,yg);

name='NewDataset';
handles.Bathymetry.NrDatasets=handles.Bathymetry.NrDatasets+1;
ii=handles.Bathymetry.NrDatasets;
handles.Bathymetry.ActiveDataset=ii;
handles.Bathymetry.Datasets{ii}=name;
handles.Bathymetry.Dataset(ii).Name=name;
handles.Bathymetry.Dataset(ii).FileName='';
handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Name=Coord.Name;
handles.Bathymetry.Dataset(ii).HorizontalCoordinateSystem.Type=Coord.Type;
handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Name='Mean Sea Level';
handles.Bathymetry.Dataset(ii).VerticalCoordinateSystem.Level=0;
handles.Bathymetry.Dataset(ii).Edit=1;
handles.Bathymetry.Dataset(ii).Comments={'none'};
handles.Bathymetry.Dataset(ii).Type='gridded';
handles.Bathymetry.Dataset(ii).x=x1;
handles.Bathymetry.Dataset(ii).y=y1;
handles.Bathymetry.Dataset(ii).z=z1;


