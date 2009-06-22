function [OPT, Set, Default] = KMLline3(lat,lon,z,varargin)
% KMLLINE3 Just like line3
% 
% see the keyword/vaule pair defaults for additional options

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
OPT.fileName = [];
OPT.kmlName = 'untitled';
OPT.lineWidth = 1;
OPT.lineColor = [0 0 0];
OPT.lineAlpha = 1;
OPT.fillColor = [0 .7 0];
OPT.fillAlpha = 0.6;
OPT.openInGE = false;
OPT.reversePoly = false;
OPT.extrude = 0;

[OPT, Set, Default] = setProperty(OPT, varargin);
%% get filename
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

%% start KML
OPT.fid=fopen(OPT.fileName,'w');
%% HEADER
OPT_header = struct(...
    'name',OPT.kmlName);
output = KML_header(OPT_header);
%% STYLE
% write multiple styles if different line or fill styles are defined.
if ~logical(OPT.extrude)
    OPT_style = struct(...
        'name',['style' num2str(1)],...
        'lineColor',OPT.lineColor(1,:) ,...
        'lineAlpha',OPT.lineAlpha(1),...
        'lineWidth',OPT.lineWidth(1));
    output = [output KML_style(OPT_style)];

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
else
    OPT_stylePoly = struct(...
        'name',['style' num2str(1)],...
        'lineColor'   ,OPT.lineColor(1,:),...
        'lineAlpha'   ,OPT.lineAlpha(1),...
        'lineWidth'   ,OPT.lineWidth(1),...
        'fillColor'   ,OPT.fillColor(1,:),...
        'fillAlpha'   ,OPT.fillAlpha(1),...
        'polyFill'    ,1,...
        'polyOutline' ,1);
    output = [output KML_stylePoly(OPT_stylePoly)];

    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)+...
       length(OPT.fillColor(:,1))+length(OPT.fillAlpha)>5
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
            if length(OPT.fillColor(:,1))>1
                OPT_style.lineColor = OPT.fillColor(ii,:);
            end
            if length(OPT.fillAlpha(:,1))>1
                OPT_style.lineAlpha = OPT.fillAlpha(ii,:);
            end
            output = [output KML_stylePoly(OPT_stylePoly)];
        end
    end
end

%% print output
fprintf(OPT.fid,output);
%% POLYGON
OPT_line = struct(...
    'name','',...
    'styleName',['style' num2str(1)],...
    'timeIn',[],...
    'timeOut',[],...
    'visibility',1,...
    'extrude',OPT.extrude);
% preallocate output
output = repmat(char(1),1,1e5);
kk = 1;
for ii=1:length(lat(1,:))
    if length(OPT.lineColor(:,1))+length(OPT.lineWidth)+length(OPT.lineAlpha)>3
        OPT_line.styleName = ['style' num2str(ii)];
    end
    newOutput = KML_line(lat(:,ii),lon(:,ii),z(:,ii),OPT_line);
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);
    if kk>1e5
        %then print and reset
        fprintf(OPT.fid,output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end
end

fprintf(OPT.fid,output(1:kk-1)); output = ''; % print and clear output
%% FOOTER
output = KML_footer;
fprintf(OPT.fid,output);
%% close KML
fclose(OPT.fid);
%% compress to kmz?
if strcmpi(OPT.fileName(end),'z')
    movefile(OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip(OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete([OPT.fileName(1:end-3) 'kml'])
end
%% openInGoogle?
if OPT.openInGE
    system(OPT.fileName);
end
