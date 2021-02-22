function [tiles,ax,logs]=plotMapTiles(varargin)
%PLOTMAPTILES Download and show a map in arbitrary reference system.
%
%   This script downloads map/satellite tiles from OpenStreetMap, MapBox or
%   Google Maps, and shows them in a figure. Map tiles are optionally
%   converted to a local coordinate system.
%   For MapBox (1) an API-key is required.
%
%   Syntax:
%       [tiles,ax,logs]=plotMapTiles(varargin);
%   
%   Input: For <keyword,value> pairs call plotMapTiles() without arguments.
%   varargin  =
%       map_type: 1=satellite MapBox,
%           2=OpenStreetMap,
%           3=Google Earth (satellite)
%           4=Google Earth (maps), 
%           5=Google Earth (hybrid), 
%           6=Google Earth (terrain); 
%       xlim: map limits in longitude or E-W direction [min max]
%       ylim: map limits in latitude or N-S direction [min max]
%       epsg_in: input (xlim and ylim) coordinate system EPSG code. Default
%           is WGS'84 [4326].
%       epsg_out: output or map coordinate system EPSG code. Default is
%           Rijksdriehoek/Amersfoort [28992].
%       tzl: Tile Zoom Level, from 0 (continent) to 19 (house). Default [10]
%       save_tiles: Cache tiles locally, default [true]
%       path_save: path to cache tiles to, default ['./earth_tiles']
%
%   Output:
%       tiles: cell array with map tiles
%       ax: axes that were plotted on
%       logs: info from convertCoordinates
%
%   See also: convertCoordinates, imread, imwrite.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2021 Deltares, KU Leuven
%       Victor Chavarrias & Bart Roest
%
%       victor.chavarrias@deltares.nl
%
%       bart.roest@kuleuven.be
%       l.w.m.roest@tudelft.nl
%       Spoorwegstraat 12
%       8200 Bruges
%       Belgium
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
% Created: 10 Jan 2021
% Created with Matlab version: 9.9.0.1570001 (R2020b) Update 4

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Id: $
%$Revision: 16973 $
%$Date: 2020-12-17 11:20:54 +0100 (do, 17 dec 2020) $
%$Author: chavarri $
%$Id: main_get_tiles.m 16973 2020-12-17 10:20:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/GE2Mat/main_get_tiles.m $

%% INPUT
OPT.mytoken='XXXXXXXXXXXXXXXXXXX'; %MapBox token.
OPT.xlim= [ 2.2934, 3.3673];
OPT.ylim= [51.0880,51.5950];
OPT.epsg_in=4326; %WGS'84 / google earth
OPT.epsg_out=28992; %Amersfoort
OPT.tzl = 10; %zoom
OPT.save_tiles=true;
OPT.path_save=fullfile(pwd,'earth_tiles');
OPT.path_tiles=fullfile(pwd,'earth_tiles'); 
OPT.map_type=2;%map type
%1=satellite;
%2=openstreetmap; 
%3=google earth (satellite); 
%4=google earth (maps); 
%5=google earth (hybrid); 
%6=google earth (terrain); 

if nargin==0;
    tiles = {OPT};
    return
end

OPT = setproperty(OPT,varargin);

%% PATHS
addpath(OPT.path_tiles)

%% CONVERT COORDINATES
% Convert input coordinates to WGS'84.
[xRD,yRD] = ndgrid(OPT.xlim,OPT.ylim);
[lon_deg,lat_deg,logs]=convertCoordinates(xRD,yRD,'CS1.code',OPT.epsg_in,'CS2.code',4326);
[xtile,ytile] = deg2osm(OPT.tzl,lat_deg,lon_deg);

%% Determine Tiles
txl_v=min(floor(xtile(:))):max(floor(xtile(:)));
tyl_v=min(floor(ytile(:))):max(floor(ytile(:)));
nx=numel(txl_v);
ny=numel(tyl_v);
tiles=cell(nx,ny,3);

%% Download/Load tiles
for kx=1:nx
    txl=txl_v(kx);
    for ky = 1:ny
        tyl=tyl_v(ky);
        
        switch OPT.map_type
            case 1 %MapBox
                ti = 1/512;
            case {2,3} %openstreetmap & Google Maps
                ti=1/255;
%             case 3
        end
        
        [tx, ty] = ndgrid([txl:ti:txl+1],[tyl:ti:tyl+1]); %#ok<NBRAK>
        [lat_deg,lon_deg] = osm2deg(OPT.tzl,tx,ty);
        
        switch OPT.map_type
            case 1
                baseserver = 'api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/256';
                baseformat = 'jpeg';
                basetoken = sprintf('@2x?access_token=%s',OPT.mytoken);
                source = sprintf([baseserver,'/%i/%i'],OPT.tzl,txl);
                sourcecache = sprintf(['%s/%s/%i.',baseformat],OPT.path_tiles,source,tyl);
                httptilename = sprintf('https://%s/%i%s',source,tyl,basetoken);
            case 2
                %check possible ones here: https://wiki.openstreetmap.org/wiki/Tile_servers
%                 baseserver = 'a.tile.openstreetmap.org'; 
                baseserver = 'a.tile.openstreetmap.de'; 
                baseformat = 'png';
                source = sprintf([baseserver,'/%i/%i'],OPT.tzl,txl);
                sourcecache = sprintf(['%s/%s/%i.',baseformat],OPT.path_tiles,source,tyl);
                httptilename = sprintf(['http://%s/%i.',baseformat],source,tyl);
            case {3,4,5,6}
                switch OPT.map_type
                    case 3
                        str_type='s';
                    case 4
                        str_type='m';
                    case 5
                        str_type='y';
                    case 6
                        str_type='t';
                end
                baseserver = sprintf('mt1.google.com/vt/lyrs=%s',str_type); 
                baseformat = 'jpg';
                source = sprintf([baseserver,'&x=%d&y=%d&z=%d'],txl,tyl,OPT.tzl); %http://mt1.google.com/vt/lyrs=m&x=1325&y=3143&z=13
                sourcecache = sprintf('%s/%s/%i/%i/%i.%s',OPT.path_tiles,baseserver,OPT.tzl,txl,tyl,baseformat);
                httptilename = sprintf('http://%s',source);
        end

        if exist(sourcecache,'file')==2
            [A,map]=imread(sourcecache);  
        else
            disp([ 'Downloading tile: ' ,httptilename])
            [A,map]=imread(httptilename);
            sourcecachedir = fileparts(sourcecache);
%             fprintf(1,'%s\n',sourcecachedir);
            if exist(sourcecachedir,'dir') ~= 7
                mkdir(sourcecachedir);
            end
            
            switch OPT.map_type
                case {1,3,4,5,6}
                    imwrite(A,sprintf('%s',sourcecache));
                case 2
                    imwrite(A,map,sprintf('%s',sourcecache));
            end
        end
        
        switch OPT.map_type
            case {1,3,4,5,6}
                
            case 2
                A = ind2rgb(A,map);                
        end
            
        %satellite and openstreetmap
        Im = permute(A,[2 1 3]); 

        [xRD,yRD,logs]=convertCoordinates(lon_deg,lat_deg,'CS1.code',4326,'CS2.code',OPT.epsg_out);
        tiles{kx,ky,1}=xRD;
        tiles{kx,ky,2}=yRD;
        tiles{kx,ky,3}=Im;
        
        %display
        fprintf('tile x %4.2f %% tile y %4.2f %% \n',kx/nx*100,ky/ny*100)
    end
end


%% PLOT
[nx,ny,~]=size(tiles);
figure;
hold on
ax=gca;
for kx=1:nx
    for ky=1:ny
         surf(ax,tiles{kx,ky,1},tiles{kx,ky,2},zeros(size(tiles{kx,ky,2})),tiles{kx,ky,3},'EdgeColor','none')
    end
end
% switch logs.CS2.type
%     case 'projected'
axis equal
%     otherwise
% end

%% SAVE
if OPT.save_tiles
    path_full_save=fullfile(OPT.path_save,'tiles');
    if exist(path_full_save,'file')
        fprintf(2,'you are trying to overwrite a tiles variable: %s\n',path_full_save);
        yn=input('Overwrite? [yes/no/rename] ','s');
        if strncmpi(yn,'y',1);
             save(path_full_save,'tiles')
        elseif strncmpi(yn,'r',1);
            fname = input('Filename: ','s');
            save(path_full_save,fname);
        end
    else
        save(path_full_save,'tiles');
    end
end
end

function [xtile,ytile] = deg2osm(zoom,lat_deg,lon_deg);
    n = 2^zoom;
    xtile = n * ((lon_deg + 180) / 360);
    ytile = n/ 2 * (1 - (log(tan(lat_deg*pi/180) + sec(lat_deg*pi/180)) / pi)) ;
end

function [lat_deg,lon_deg] = osm2deg(zoom,xtile,ytile);
    % OSM documentation
    n = 2^zoom;
    lon_deg = xtile ./ n * 360.0 - 180.0;
    lat_rad = atan(sinh(pi * (1 - 2 * ytile ./ n)));
    lat_deg = lat_rad * 180.0 ./ pi;
end


%EOF