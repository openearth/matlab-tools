%VAKLODINGEN2KML   make kml file of each vaklodingen grid
%
%See also: jarkus_grids2kml, vaklodingen2png, vaklodingen_overview

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

clear all
outputDir = 'F:\KML\vaklodingen\';
url       = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/vaklodingen';
contents  = opendap_folder_contents(url);
EPSG      = load('EPSGnew');

% z scaling parameters:
a = 40; % lift up meters
b = 5;  % exageration
c = 30; % colormap limits

for ii = 1:1:length(contents);

    [path, fname] = fileparts(contents{ii});
    x    = nc_varget(contents{ii},   'x');
    y    = nc_varget(contents{ii},   'y');
    time = nc_varget(contents{ii},'time');

    %create output directory
    outputDir2 = [outputDir fname '_preview'];

    %Check dir, make if needed
    if ~isdir(outputDir2)
        mkdir(outputDir2);
    end

    % calculate coordinates, should not be necessary!!
    % it is though ... but it goes lightning fast anyways ;-)
    [x,y] = meshgrid(x,y);

    % convert time to years
    time = datestr(time+datenum(1970,1,1),10);

    %loop through all the years
    for jj = size(time,1)%:-1:1

        % dispaly progress
        disp([num2str(ii) '/' num2str(length(contents)) ' ' fname ' ' time(jj,:)]);

        % load z data
        z = nc_varget(contents{ii},'z',[jj-1,0,0],[1,-1,-1]);

        % make sure there are no crazy high Z values
        % should not be necessary!!
        z(z>500) = nan;

        disp(['elements: ' num2str(sum(~isnan(z(:))))]);
        tolerance = 1;
        maxSize = 100000;
        [tri,x2,y2,z2] = delaunay_simplified(x,y,z,tolerance,maxSize);
            
        % convert coordinates
        [lat,lon] = convertCoordinatesNew(x2,y2,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');

        %scale z
        z2= (z2+a)*b;

        % make *.kmz
        KMLtrisurf(tri,lat,lon,z2,'fileName',[outputDir2 time(jj,:) '_3D.kmz'],...
            'kmlName',[fname ' ' time(jj,:) ' 2D'],'lineWidth',0,...
            'colormap','colormapbathymetry','colorSteps',64,...
            'fillAlpha',0.85,'cLim',[(a-c)*b (a+c)*b]);
     end
end