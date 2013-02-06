function z = ddb_interpolateBathymetry(bathymetry,x,y,varargin)
%ddb_interpolateBathymetry  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_interpolateBathymetry(bathymetry, x,y, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_interpolateBathymetry
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

% Default (use background bathymetry)
datasets{1}='gebco08';
zmin=-100000;
zmax=100000;
verticaloffset=0;
startdates=[];
searchintervals=[];
verticaloffsets=[];
    
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'datasets'}
                datasets=varargin{i+1};
            case{'zmin'}
                zmin=varargin{i+1};
            case{'zmax'}
                zmax=varargin{i+1};
            case{'startdates'}
                startdates=varargin{i+1};
            case{'searchintervals'}
                searchintervals=varargin{i+1};
            case{'verticaloffsets'}
                verticaloffsets=varargin{i+1};
            case{'verticaloffset'}
                verticaloffset=varargin{i+1};
            case{'coordinatesystem'}
                coord=varargin{i+1};
        end
    end
end

if isempty(startdates)
startdates=zeros(length(datasets))+floor(now);
end
if isempty(searchintervals)
searchintervals=zeros(length(datasets))-1e5;
end
if isempty(verticaloffsets)
verticaloffsets=zeros(length(datasets))+0;
end


% Generate bathymetry

% Fill matrix z with NaN values
z=zeros(size(x));
z(z==0)=NaN;

% x(isnan(x))=0;
% y(isnan(y))=0;

for id=1:length(datasets)   
    
    idata=length(datasets)-id+1;

    xg=x;
    yg=y;

    % Loop through selected datasets
    
    bathyset=datasets{idata};
    startdate=startdates(idata);
    searchinterval=searchintervals(idata);
    zmn=zmin(idata);
    zmx=zmax(idata);
    offset=verticaloffsets(idata);
    
    % Convert grid to cs of background image
    iac=strmatch(lower(bathyset),lower(bathymetry.datasets),'exact');
    dataCoord.name=bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    [xg,yg]=ddb_coordConvert(xg,yg,coord,dataCoord);
    
    % Find minimum grid resolution for this dataset
    [dmin,dmax]=findMinMaxGridSize(xg,yg,'cstype',coord.type);
    
    % Determine bounding box
    xl(1)=min(min(xg));
    xl(2)=max(max(xg));
    yl(1)=min(min(yg));
    yl(2)=max(max(yg));
    dbuf=(xl(2)-xl(1))/10;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;
    
    [xx,yy,zz,ok]=ddb_getBathymetry(bathymetry,xl,yl,'bathymetry',bathyset,'maxcellsize',dmin,'startdate',startdate,'searchinterval',searchinterval);
    
    % Convert to MSL
    zz=zz+offset;

    % Remove values outside requested range
    zz(zz<zmn)=NaN;
    zz(zz>zmx)=NaN;        
    
    isn=isnan(xg);
    % Next two line are necessary in Matlab 2010b (and older?)
    xg(isn)=0;
    yg(isn)=0;
    % Copy new values (that are not NaN) to new bathymetry
    z0=interp2(xx,yy,zz,xg,yg);    
    z0(isn)=NaN;
    
    z(~isnan(z0))=z0(~isnan(z0));
        
end

% Interpolated data in MSL, now convert to model datum
z=z-verticaloffset;
