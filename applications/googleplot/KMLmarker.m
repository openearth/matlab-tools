function varargout = KMLmarker(varargin)
%KMLMARKER  add a placemarker pushpin with text ballon
%
%   There are three ways to call this function:
%
%   KMLmarker(address,'fileName',fname,<keyword,value>)
%             Address is a cellstr of addresses eg: {'Groningen, Amsterdam'}
%   KMLmarker(lat,lon,'fileName',fname,<keyword,value>)
%   KMLmarker(lat,lon,z,'fileName',fname,<keyword,value>)
%
% where lat can  be one scaler or an array of size(lon)
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * fileName               = []; % file name
%  * kmlName                = []; % name that appears in Google Earth places list
%  * name                   = cellstr with name per point (shown when highlighted)
%                             by default empty.
%  * html                   = cellstr with text per point (shown when highlighted)
%                             by default equal to value of c
%  * OPT.iconnormalState    = marker, default 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png'
%                                       see also, http://www.mymapsplus.com/Markers,
%                                       http://www.visual-case.it/cgi-bin/vc/GMapsIcons.pl
%                                       http://www.benjaminkeen.com/?p=105
%                                       http://code.google.com/p/google-maps-icons/
%                                       http://www.scip.be/index.php?Page=ArticlesGE02&Lang=EN
%  * OPT.iconhighlightState = marker for highlighted state, defaults to
%                             marker for normalstate
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLmarker()
%
%See also: GOOGLEPLOT, KMLanimatedicon, KMLscatter, KMLtext

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

%% input check

%% process <keyword,value>

OPT                     = KML_header();

OPT.fileName            =  '';
OPT.openInGE            = false;
OPT.markerAlpha         =  1;
OPT.labelAlpha          =  0;
OPT.html                = [];
OPT.name                = [];
OPT.iconnormalState     =  '';
OPT.iconhighlightState  =  '';
OPT.scalenormalState    =  0.8;
OPT.scalehighlightState =  1.0;
OPT.colornormalState    =  []; % [1 1 0] = yellow
OPT.colorhighlightState =  [];
OPT.scalelabelStyle     =  1;
OPT.colorlabelStyle     =  [1 1 1];
OPT.iconHotspot         = ''; %<hotSpot x="0.5"  y="0.5" xunits="fraction" yunits="fraction"/>


if nargin==0
    varargout = {OPT};
    return
end

%% process varargin

if iscellstr(varargin{1})
    address         = varargin{1};
    varargin(1)     = [];
    OPT.mode        = 'address';
    nn              = numel(address);
elseif ischar(varargin{1})
    address         = cellstr(varargin{1});
    varargin(1)     = [];
    OPT.mode        = 'address';
    nn              = numel(address);
elseif isnumeric(varargin{1})
    address         = [];
    lat             = varargin{1};
    lon             = varargin{2};
    varargin(1:2)   = [];
    nn              = numel(lat);
    if ~isempty(varargin)
        if isnumeric(varargin{1})
            z           = varargin{1};
            varargin(1) = [];
            OPT.mode    = 'latlonz';
        else
            OPT.mode    = 'latlon';
        end
    else
        OPT.mode    = 'latlon';
    end
end

[OPT, Set, Default] = setproperty(OPT, varargin{:});

%% correct lat and lon
if ismember(OPT.mode,{'latlon','latlonz'})
    lat = lat(:);
    lon = lon(:);
    
    if any((abs(lat)/90)>1)
        error('latitude out of range, must be within -90..90')
    end
    lon = mod(lon+180, 360)-180;
end
%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% pre-process data

if  ischar(OPT.html);OPT.html = cellstr(OPT.html  );end
if  ischar(OPT.name);OPT.name = cellstr(OPT.name  );end

% Icon's
if isempty(OPT.iconnormalState)
    iconnormalState = '';
else
    iconnormalState =    [' <Icon><href>'    OPT.iconnormalState '</href></Icon>\n'];
end

if isempty(OPT.iconhighlightState)
    iconhighlightState = iconnormalState;
else
    iconhighlightState = [' <Icon><href>'    OPT.iconhighlightState '</href></Icon>\n'];
end

% Label's
if ~OPT.labelAlpha % no text except when mouse hoover
    OPT.scalelabelStyle = 0;
    temp                = dec2hex(round([OPT.labelAlpha OPT.colorlabelStyle].*255),2);
    OPT.colorlabelStyle = [' <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>\n'];    
else
    temp                = dec2hex(round([OPT.labelAlpha OPT.colorlabelStyle].*255),2);
    OPT.colorlabelStyle = [' <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>\n'];
end


%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

header = KML_header(OPT);

fprintf(OPT.fid,'%s\n',header);
%fprintf(OPT.fid,'<Folder>');

%% STYLE

output = ['<!--############################-->\n'];


if ~isempty(OPT.colornormalState)
    temp                    = dec2hex(round([OPT.markerAlpha OPT.colornormalState].*255),2);
    OPT.colornormalState    = [' <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>\n'];
end
if ~isempty(OPT.colorhighlightState)
    temp                    = dec2hex(round([OPT.markerAlpha OPT.colorhighlightState].*255),2);
    OPT.colorhighlightState = [' <color>' temp(1,:) temp(4,:) temp(3,:) temp(2,:) '</color>\n'];
end

if ~isempty(OPT.html)
    output = [output ...
        '<StyleMap id="cmarker_map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_' OPT.fileName '_n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_' OPT.fileName '_h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_' OPT.fileName '_n">\n'...
        ' <IconStyle>\n'...
        OPT.colornormalState ...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'...
        iconnormalState...
        OPT.iconHotspot...
        ' </IconStyle>\n'...
        ' <LabelStyle>\n'...
        OPT.colorlabelStyle...
        ' <scale>' num2str(OPT.scalelabelStyle) '</scale>\n'...
        ' </LabelStyle>\n'...
        ' </Style>\n'...
        '<Style id="cmarker_' OPT.fileName '_h">\n'...
        ' <BalloonStyle><text>\n'...
        ' $[name]'... % variable per dot
        ' $[description]\n'... % variable per dot
        ' </text></BalloonStyle>\n'...
        ' <IconStyle>\n'...
        OPT.colorhighlightState...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...
        iconhighlightState...
        OPT.iconHotspot...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
else
    output = [output ...
        '<StyleMap id="cmarker_map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_' OPT.fileName '_n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_' OPT.fileName '_h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_' OPT.fileName '_n">\n'...
        ' <IconStyle>\n'...
        OPT.colornormalState '\n'...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'...
        iconnormalState...
        OPT.iconHotspot...
        ' </IconStyle>\n'...
        ' <LabelStyle>\n'...
        OPT.colorlabelStyle...
        ' <scale>' num2str(OPT.scalelabelStyle) '</scale>\n'...
        ' </LabelStyle>\n'...
        ' </Style>\n'...
        '<Style id="cmarker_' OPT.fileName '_h">\n'...
        ' <IconStyle>\n'...
        OPT.colorhighlightState '\n'...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...
        iconhighlightState...
        OPT.iconHotspot...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
end

%% print and clear output

output = [output '<!--############################-->\n'];
fprintf(OPT.fid,output);

output = repmat(char(1),1,1e5);
kk = 1;

%% Plot the points

for ii=1:nn
    multiWaitbar('Writing kml files ...', ii/nn, 'Color', [1.0 0.4 0.0]) % orange

    %% preprocess timespan
    if isempty(OPT.timeIn) | isempty(OPT.timeOut)
    timeSpan = '';
    else
    timeSpan = KML_timespan(ii,'timeIn',OPT.timeIn,'timeOut',OPT.timeOut,'dateStrStyle',OPT.dateStrStyle);
    end
    
    %% preprocess html
    
    if ~isempty(OPT.html)
        if length(OPT.html)>1
            html = sprintf(' <description><![CDATA[%s]]></description>\n',str2line(cellstr(OPT.html{ii}),'s',''));
            % CDATA is wrapper for html
            % str2line to remove trailing blanks per line (blanks are
            % skipped in html anyway), and reshape 2D array correctly to 1D
        else
            html = sprintf(' <description><![CDATA[%s]]></description>\n',str2line(cellstr(OPT.html{1}),'s',''));
        end
    else
        html = '';
    end
  
    %% preprocess name
    if ~isempty(OPT.name)
        if length(OPT.name)>1
            name = sprintf(' <name>%s</name>\n',OPT.name{ii});
        else
            name = sprintf(' <name>%s</name>\n',OPT.name{1});
        end
    else
        name = '';
    end
    
    OPT_poly.styleName = ['cmarker_map'];
    
    switch OPT.mode
        case 'address'
            coordinates = sprintf(' <address>%s</address>\n',address{ii});
        case 'latlon'
            coordinates = sprintf(' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n',lon(ii),lat(ii));
        case 'latlonz'
            coordinates = sprintf(' <Point><altitudeMode>absolute</altitudeMode><coordinates>% 2.8f,% 2.8f, % 2.4f</coordinates></Point>\n',lon(ii),lat(ii),z(ii));
    end
    
    
    newOutput= sprintf([...
        '<Placemark>\n'...
        '%s',...                          % no names so we see just the scatter points
        ' <visibility>1</visibility>\n'...
          ' <snippet></snippet>\n'...      % prevent html from showing up in menu
        '%s',... html
        '%s',... timeSpan
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        '%s'...
        ' </Placemark>\n'],...
        name,...
        html,...
        timeSpan,...
        OPT_poly.styleName,...
        coordinates);
    
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
%fprintf(OPT.fid,'</Folder>');
fprintf(OPT.fid,output);

%% close KML

fclose(OPT.fid);

%% close the waitbar
multiWaitbar('closeall');

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

if nargout > 0
   varargout = {OPT};
end

%% EOF

