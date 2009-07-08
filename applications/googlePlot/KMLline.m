function [OPT, Set, Default] = KMLline(lat,lon,varargin)
% KMLLINE Just like line (and that's just like plot)
%
%    kmlline(lat,lon,'fileName',fname,<keyword,value>)
%
% creates a kml file fname with lines at the Earth surface connecting the
% coordinates defined in (lat,lon). As in plot, an array of coordinates can
% be drawn at onece. Each column in (lat,lon) defines a new line. A single
% line can be split by nan's in (lat,lon).
% 
% coordinates (lat,lon) are in decimal degrees. 
%   LON is converted to a vlaue in the range -180..180)
%   LAT must be in the range -90..90
%
% be aware that GE draws the shortest possible connection between two 
% points, when crossing the nul meridian
%
% The following see <keyword,value> pairs have been implemented:
%   fileName    = [];          % name of output file. Can be either a *.kml 
%                              % or *.kmz (zipped *.kml) file. if not  
%                              % defined a gui pops up
%   kmlName     = 'untitled';  % name of kml that shows in GE
%
%  The following line properties can each be defined as either a single
%  entry or an array with the same lenght as the number of columns in 
%   (lat,lon).
%   lineWidth   = 1;           % line width, can be a fraction
%   lineColor   = [0 0 0];     % color of the lines in RGB (0..1) 
%   lineAlpha   = 1;           % transparency of the line
%
%   openInGE    = false;       % opens output directly in google earth
%   description = '';          % 
%
%  If text is defined, each set of lines (column in (lat,lon)), is
%  accompanied by a title. 
%   text        = '';          % cellstr with same size as size(lat,2)
%   latText     = mean(lat,1); % coordinates of text
%   lonText     = mean(lon,1); %
%
% Example 1: draw a spiral around the earth
%   lat = linspace(-90,90,1000)'; lon = linspace(0,5*360,1000)';
%   KMLline(lat,lon)
%
% Example 2: draw the mean low water line of the netherlands as a function 
%            of time
%   % read data from server
%   url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/strandlijnen/strandlijnen.nc';
%   time = nc_varget(url, 'time')+datenum(1970,1,1);
%   trID = nc_varget(url, 'trID');
%   lat  = nc_varget(url, 'MLWLat');
%   lon  = nc_varget(url, 'MLWLon');
%   % insert a NaN to split lines for a given year at a gap in trID number
%   splits = find(diff(trID)>1e5)+1; length(trID);
%   for ii = length(splits):-1:1
%       lat(splits(ii)+1:end+1,:) = lat(splits(ii):end,:);
%       lon(splits(ii)+1:end+1,:) = lon(splits(ii):end,:);
%       lat(splits(ii),:) = nan;
%       lon(splits(ii),:) = nan;
%   end
%   % draw the lines
%   KMLline(lat,lon,'timeIn',time,'timeOut',time+364,...
%       'lineWidth',4,'lineColor',jet(length(time)),'lineAlpha',.7);
%
% See also: KMLline3, KMLpatch, KMLpcolor, KMLquiver, KMLsurf, KMLtrisurf

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

%% process varargin

OPT.fileName    = [];
OPT.kmlName     = 'untitled';
OPT.lineWidth   = 1;
OPT.lineColor   = [0 0 0];
OPT.lineAlpha   = 1;
OPT.openInGE    = false;
OPT.text        = '';
OPT.latText     = mean(lat,1);
OPT.lonText     = mean(lon,1);
OPT.timeIn      = [];
OPT.timeOut     = [];

[OPT, Set, Default] = setProperty(OPT, varargin);

%% input check
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;


%% get filename

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0);
output = KML_header(OPT_header);

%% define line styles

OPT_style = struct(...
    'name',['style' num2str(1)],...
    'lineColor',OPT.lineColor(1,:) ,...
    'lineAlpha',OPT.lineAlpha(1),...
    'lineWidth',OPT.lineWidth(1));
output = [output KML_style(OPT_style)];

% if multiple styles are define, generate them
if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
    for ii = 2:length(lat(1,:))
        OPT_style.name = ['style' num2str(ii)];
        if length(OPT.lineColor(:,1))>1
            OPT_style.lineColor = OPT.lineColor(ii,:);
        end
        if length(OPT.lineWidth(:,1))>1
            OPT_style.lineWidth = OPT.lineWidth(ii,:);
        end
        if length(OPT.lineAlpha(:,1))>1
            OPT_style.lineAlpha = OPT.lineAlpha(ii,:);
        end
        output = [output KML_style(OPT_style)];
    end
end

% print styles
fprintf(OPT.fid,output);

%% generate contents

% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;

% line properties
OPT_line = struct(...
    'name','',...
    'styleName',['style' num2str(1)],...
    'visibility',1,...
    'extrude',0);

if isempty(OPT.timeIn)
   OPT_line.timeIn = [];
else
   OPT_line.timeIn = datestr(OPT.timeIn(1),29); 
end

if isempty(OPT.timeOut)
   OPT_line.timeOut = [];
else
   OPT_line.timeOut = datestr(OPT.timeOut(1),29); 
end

% loop through number of lines
for ii=1:length(lat(1,:))
    
    % update linestyles if multiple are defined
    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
        OPT_line.styleName = ['style' num2str(ii)];
    end
    
    % update timeIn and timeOut if multiple times are defined
    if length(OPT.timeIn)>1
    	OPT_line.timeIn = datestr(OPT.timeIn(ii),29);
    end
    if length(OPT.timeOut)>1
        OPT_line.timeOut = datestr(OPT.timeOut(ii),29);
    end
    
    % write the line
    newOutput =  KML_line(lat(:,ii),lon(:,ii),'clampToGround',OPT_line);
    
    % add a text if it is defined
    if ~isempty(OPT.text)
        newOutput = [newOutput,KML_text(OPT.latText(ii),OPT.lonText(ii),OPT.text{ii})];
    end    
    
    % add newOutput to output
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    
    % write output to file if output is full, and reset
    if kk>1e5
        fprintf(OPT.fid,output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
end

% print output
fprintf(OPT.fid,output(1:kk-1)); 

%% FOOTER
output = KML_footer;
fprintf(OPT.fid,output);

%% close KML
fclose(OPT.fid);

%% compress to kmz?
if strcmpi  ( OPT.fileName(end),'z')
    movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete  ([OPT.fileName(1:end-3) 'kml'])
end
%% openInGoogle?
if OPT.openInGE
    system(OPT.fileName);
end

%% EOF