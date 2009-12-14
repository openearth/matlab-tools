function varargout = KMLanimatedIcon(lat,lon,varargin)
%KMLAMINATEDICON
%
%   KMLanimatedIcon(lat,lon,c,<keyword,value>)
%
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename           = []; % file name
%  * kmlname            = []; % name that appears in Google Earth places list
%  * colorMap           = colormap (default @(m) jet(m));
%  * colorSteps         = number of colors in colormap (default 20);
%  * cLim               = cLim aka caxis (default [min(c) max(c)]);
%  * long_name          = ''; used for point description ... (default 'value=')
%  * units              = ''; 'long_name = x units'
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLanimatedIcon()
%
% See also: GOOGLEPLOT

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% process options

if ~isempty(varargin)
    if ~ischar(varargin{1})
        c                  = varargin{1};
        varargin           = varargin(2:end);
        OPT.coloredIcon    = true;
    else
        OPT.coloredIcon    = false;
    end
else
    OPT.coloredIcon    = false;
end

OPT.fileName           = [];
OPT.kmlName            = [];
OPT.icon               = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
OPT.scale              = 1.0;
OPT.openInGE           = 0;
OPT.markerAlpha        = 1;
OPT.timeIn             = [];
OPT.timeOut            = [];
OPT.description        = 'Animated Icon';
OPT.dateStrStyle       = 29; % set to yyyy-mm-ddTHH:MM:SS for detailed times
OPT.colorMap           = @(m) jet(m);
OPT.colorSteps         = 20;
OPT.cLim               = [];

if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setProperty(OPT, varargin);

%% get filename

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','untitled.kml');
    OPT.fileName = fullfile(filePath,fileName);
end

% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% if colordata is defined, color the icon
if OPT.coloredIcon
    % set cLim

    if isempty(OPT.cLim)
        OPT.cLim         = [min(c(:)) max(c(:))];
    end

    % pre-process data
    %  make 1D and remove NaNs

    lon    = lon(~isnan(c(:)));
    lat    = lat(~isnan(c(:)));
    c      =   c(~isnan(c(:)));
    colors = OPT.colorMap(OPT.colorSteps);
end
%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0,...
    'description',OPT.description);
output = KML_header(OPT_header);

output = [output '<!--############################-->\n'];

%% STYLE
if OPT.coloredIcon
    for ii = 1:OPT.colorSteps

    temp                = dec2hex(round([OPT.markerAlpha, colors(ii,:)].*255),2);
    markerColor         = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

    output = [output ...
        '<Style id="Marker_',num2str(ii,'%0.3d'),'">\n'...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scale) '</scale>\n'...
        ' <Icon><href>' OPT.icon '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' </Style>\n'];
    end
else
     output = [output ...
        '<Style id="Marker">\n'...
        ' <IconStyle>\n'...
        ' <scale>' num2str(OPT.scale) '</scale>\n'...
        ' <Icon><href>' OPT.icon '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' </Style>\n'];
end
output = [output '<!--############################-->\n'];

%% print and clear output

fprintf(OPT.fid,output);
output = repmat(char(1),1,1e5);
kk = 1;

%% Plot the points

for ii=1:length(lon)
    if OPT.coloredIcon
        % convert color values into colorRGB index values
        cindex = round(((c(ii)-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);
        cindex = min(cindex,OPT.colorSteps);
        cindex = max(cindex,1); % style numbering is 1-based

        styleName = ['Marker_',num2str(cindex,'%0.3d')];
    else
        styleName = 'Marker';
    end
    % define time
    
    %% preproces timespan
    if  ~isempty(OPT.timeIn)
        if length(OPT.timeIn)>1
            tt = ii;
        else
            tt = 1;
        end
        if ~isempty(OPT.timeOut)
            timeSpan = sprintf([...
                '<TimeSpan>\n'...
                '<begin>%s</begin>\n'...OPT.timeIn
                '<end>%s</end>\n'...OPT.timeOut
                '</TimeSpan>\n'],...
                datestr(OPT.timeIn (tt),OPT.dateStrStyle),...
                datestr(OPT.timeOut(tt),OPT.dateStrStyle));
        else
            timeSpan = sprintf([...
                '<TimeStamp>\n'...
                '<when>%s</when>\n'...OPT.timeIn
                '</TimeStamp>\n'],...
                datestr(OPT.timeIn (tt),OPT.dateStrStyle));
        end
    else
        timeSpan ='';
    end
    
      
    newOutput= sprintf([...
        '<Placemark>\n'...     
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' %s'...                                       % timeSpan
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'... % coordinates
        ' </Placemark>\n'],...
        styleName,timeSpan,...
        lon(ii),lat(ii));

    % add newOutput to output
    output(kk:kk+length(newOutput)-1) = newOutput;
    kk = kk+length(newOutput);

    % write output to file if output is full, and reset
    if kk>1e5
        fprintf(OPT.fid,'%s',output(1:kk-1));
        kk = 1;
        output = repmat(char(1),1,1e5);
    end

end

%% print and clear output

% print output
fprintf(OPT.fid,'%s',output(1:kk-1));

%% FOOTER

output = KML_footer;
fprintf(OPT.fid,output);

%% close KML

fclose(OPT.fid);

%% openInGoogle?

if OPT.openInGE
    system(OPT.fileName);
end

%% Output

if nargout==1
    varargout = {handles};
end

%% EOF

