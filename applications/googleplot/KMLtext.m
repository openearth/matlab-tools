function [OPT, Set, Default] = KMLtext(lat,lon,label,varargin)
% KMLTEXT Just like text 
%
%    KMLtext(lat,lon,'fileName',fname,<keyword,value>)
%
%
% The following see <keyword,value> pairs have been implemented:
% The first arguemnt can be a z value
%  'fileName'   = [];          % name of output file. Can be either a *.kml 
%                              % or *.kmz (zipped *.kml) file. if not  
%                              % defined a gui pops up
%  'kmlName'    = 'untitled';  % name of kml that shows in GE
%
% Example: 
% 
% [lat,lon] = meshgrid(54:.1:55, 4:.1:5);
% label = sprintf('%d,%d',lat(:),lon(:));
% labels=arrayfun(@(x,y) sprintf('%2.1f %2.1f',x,y),lat,lon,'uni',false);
% KMLtext(lat,lon,labels)
%
% See also: googlePlot, text

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

%% input check

if ~isempty(varargin)
    if isnumeric(varargin{1})
        z = varargin{1};
        varargin(1) = [];
        OPT.is3D = true;
    else
        z = zeros(size(lat));
        OPT.is3D = false;
    end
else
    z = zeros(size(lat));
    OPT.is3D = false;
end

lat = lat(:);
lon = lon(:);

% correct lat and lon
if any((abs(lat)/90)>1)
    error('latitude out of range, must be within -90..90')
end
lon = mod(lon+180, 360)-180;

%% process varargin

OPT.fileName      = [];
OPT.kmlName       = 'untitled';
OPT.openInGE      = false;
OPT.timeIn        = [];
OPT.timeOut       = [];
OPT.textColor     = [];% TO DO
OPT.textSize      = [];% TO DO
OPT.textAlpha     = [];% TO DO
OPT.labelDecimals = 1;

[OPT, Set, Default] = setProperty(OPT, varargin);
%% make sure the labels are in a cell array.
if isnumeric(label)
    label = label(:);
    labelFormat = sprintf('%%.%df',OPT.labelDecimals);
    label = arrayfun(@(x) sprintf(labelFormat,x),label,'uni',false);
elseif ischar(label)
    label = cellstr(label);
else
    label = label(:);
end

%% get filename

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','text.kml');
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

% for ii = 1:length(ind);
%     OPT_style = struct(...
%         'name',['style' num2str(ii)],...
%         'lineColor',OPT.lineColor(ind(ii),:) ,...
%         'lineAlpha',OPT.lineAlpha(ind(ii)),...
%         'lineWidth',OPT.lineWidth(ind(ii)));
%     output = [output KML_style(OPT_style)];     %#ok<AGROW>
% end
% 
% % print styles
fprintf(OPT.fid,output);

%% generate contents

% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;

% % line properties
% OPT_line = struct(...
%     'name','',...
%     'styleName',['style' num2str(OPT.styleNR(1))],...
%     'visibility',1,...
%     'extrude',0);
% 
if isempty(OPT.timeIn)
   OPT_text.timeIn = [];
else
   OPT_text.timeIn = datestr(OPT.timeIn(1),29); 
end

if isempty(OPT.timeOut)
   OPT_text.timeOut = [];
else
   OPT_text.timeOut = datestr(OPT.timeOut(1),29); 
end

% loop through number of lines
for ii=1:length(lat)
    if OPT.is3D
        newOutput = KML_text(lat(ii),lon(ii),label{ii},z(ii),OPT_text);
    else
        newOutput = KML_text(lat(ii),lon(ii),label{ii},OPT_text);
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