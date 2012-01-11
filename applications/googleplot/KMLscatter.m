function varargout = KMLscatter(lat,lon,c,varargin)
%KMLscatter  Just like scatter and plotc
%
%   kmlscatter(lat,lon,c,<keyword,value>)
%
% where can can be one scaler or an array of size(lon)
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename               = []; % file name
%  * kmlname                = []; % name that appears in Google Earth places list
%  * CBcolorMap             = colormap (default @(m) jet(m));
%  * CBcolorSteps           = number of colors in colormap (default 20);
%  * CBcLim                 = cLim aka caxis (default [min(c) max(c)]);
%  * name                   = cellstr with name per point (shown when highlighted)
%                             by default empty.
%  * html                   = cellstr with text per point (shown when highlighted)
%                             by default equal to value of c
%  * OPT.iconnormalState    = marker, default 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png'
%  * OPT.iconhighlightState = http://www.mymapsplus.com/Markers
%                             http://www.visual-case.it/cgi-bin/vc/GMapsIcons.pl
%                             http://www.benjaminkeen.com/?p=105
%                             http://code.google.com/p/google-maps-icons/
%                             http://www.scip.be/index.php?Page=ArticlesGE02&Lang=EN
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = kmlscatter()
%
%See also: GOOGLEPLOT, KMLanimatedicon, KMLmarker, KMLtext, SCATTER, PLOTC

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

% get colorbar options first

OPT                     = mergestructs(KMLcolorbar(),KML_header());
% rest of the options
OPT.fileName            =  '';
OPT.openInGE            =  0;
OPT.markerAlpha         =  1;
OPT.html                = [];
OPT.name                = [];
OPT.debug               = 0;

OPT.iconnormalState     = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
OPT.iconhighlightState  = 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
OPT.iconnormalState     = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
OPT.iconhighlightState  = 'http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png';
OPT.scalenormalState    =  0.25;
OPT.scalehighlightState =  1.0;

OPT.CBcolorMap          =  @(m) hsv(m);
OPT.CBcolorSteps        =  20;
OPT.CBcLim              =  [];
OPT.colorbar            =  1;

eol = char(10);

if nargin==0
    varargout = {OPT};
    return
end

[OPT, Set, Default] = setproperty(OPT, varargin);

%% get filename, gui for filename, if not set yet

if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as',[mfilename,'.kml']);
    OPT.fileName = fullfile(filePath,fileName);
end

%% set kmlName if it is not set yet

if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% set cLim

if isempty(OPT.CBcLim)
    OPT.CBcLim         = [min(c(:)) max(c(:))];
    if OPT.CBcLim(1)==OPT.CBcLim(2)
        OPT.CBcLim = OPT.CBcLim + 10.*[-eps eps];
    end
end

if isnumeric(OPT.CBcolorMap)
    OPT.CBcolorSteps = size(OPT.CBcolorMap,1);
end

%% pre-process data
%  make 1D and remove NaNs

if length(c)==1
    c = repmat( c,size(lon));
elseif ~length(c)==length(lon)
    error('c should have length 1 or have same size as lon')
end

lon    = lon(~isnan(c(:)));
lat    = lat(~isnan(c(:)));
c      =   c(~isnan(c(:)));

if isnumeric(OPT.CBcolorMap)
    OPT.CBcolorSteps = size(OPT.CBcolorMap,1);
end

if isa(OPT.CBcolorMap,'function_handle')
    colorRGB           = OPT.CBcolorMap(OPT.CBcolorSteps);
elseif isnumeric(OPT.CBcolorMap)
    if size(OPT.CBcolorMap,1)==1
        colorRGB         = repmat(OPT.CBcolorMap,[OPT.CBcolorSteps 1]);
    elseif size(OPT.CBcolorMap,1)==OPT.CBcolorSteps
        colorRGB         = OPT.CBcolorMap;
    else
        error(['size ''colorMap'' (=',num2str(size(OPT.CBcolorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.CBcolorSteps),')'])
    end
end

%% showing number next to scatter point makes iconhighlightState too SLOW,
%  so show values only in pop-up.

%if isempty(OPT.html);OPT.html = cellstr(num2str(c(:)));end
if  ischar(OPT.html);OPT.html = cellstr(OPT.html  );end
%if isempty(OPT.name);OPT.name = cellstr(num2str(c(:)));end %  makes iconhighlightState too SLOW!
if  ischar(OPT.name);OPT.name = cellstr(OPT.name  );end

%% start KML

OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

OPT_header = struct(OPT);
OPT_header = rmfield(OPT_header,'timeIn');
OPT_header = rmfield(OPT_header,'timeOut');
output = KML_header(OPT_header);

if OPT.colorbar
    %OPT.CBkmlName = 'colorbar';
    OPT.CBvisible = OPT.visible;
    [clrbarstring,pngNames] = KMLcolorbar(OPT);
end

output = [output '<!--############################-->' eol];

%% STYLE

for ii = 1:OPT.CBcolorSteps
    
    OPT_stylePoly.name  = ['style' num2str(ii)];
    temp                = dec2hex(round([OPT.markerAlpha, colorRGB(ii,:)].*255),2);
    markerColor         = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];
    
    if ~isempty(OPT.html)
        if ~(OPT.scalenormalState==OPT.scalehighlightState & OPT.iconnormalState==OPT.iconhighlightState)
            output = [output ...
                '<StyleMap id="cmarker_',num2str(ii,'%0.3d'),'map">' eol...
                ' <Pair><key>normal</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>' eol...
                ' <Pair><key>highlight</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>' eol...
                '</StyleMap>' eol...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'n">' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalenormalState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconnormalState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>' eol... % no text except when mouse hoover
                ' </Style>' eol...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'h">' eol...
                ' <BalloonStyle><text>' eol...
                ' <h3>$[name]</h3>'... % variable per dot
                ' $[description]' eol... % variable per dot
                ' </text></BalloonStyle>' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalehighlightState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle></LabelStyle>' eol...
                ' </Style>' eol];
        else
            output = [output ...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'map">' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalenormalState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconnormalState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>' eol... % no text except when mouse hoover
                ' </Style>' eol];
        end
    else
        if ~(OPT.scalenormalState==OPT.scalehighlightState & OPT.iconnormalState==OPT.iconhighlightState)
            output = [output ...
                '<StyleMap id="cmarker_',num2str(ii,'%0.3d'),'map">' eol...
                ' <Pair><key>normal</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>' eol...
                ' <Pair><key>highlight</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>' eol...
                '</StyleMap>' eol...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'n">' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalenormalState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconnormalState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>' eol... % no text except when mouse hoover
                ' </Style>' eol...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'h">' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalehighlightState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle></LabelStyle>' eol...
                ' </Style>' eol];
        else
            output = [output ...
                '<Style id="cmarker_',num2str(ii,'%0.3d'),'map">' eol...
                ' <IconStyle>' eol...
                ' <color>' markerColor '</color>' eol...
                ' <scale>' num2str(OPT.scalenormalState) '</scale>' eol...
                ' <Icon><href>'    OPT.iconnormalState '</href></Icon>' eol...
                ' </IconStyle>' eol...
                ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>' eol... % no text except when mouse hoover
                ' </Style>' eol];
        end
    end
end

%% print and clear output

output = [output '<!--############################-->' eol];
fprintf(OPT.fid,'%s',output);output = [];
fprintf(OPT.fid,'<Folder>');
fprintf(OPT.fid,'%s',['<name>',OPT.kmlName,'</name>']); % note format '%s' to allow % inside name
fprintf(OPT.fid,['  <open>',num2str(OPT.open),'</open>']); % TO DO 1

%% set time as wide as all samples, note that header also contains gtime already

if 1 %OPT.timeWide
    fprintf(OPT.fid,'<Camera>');
    fprintf(OPT.fid,KML_timespan('timeIn',min(OPT.timeIn),'timeOut',max(OPT.timeOut),'dateStrStyle',OPT.dateStrStyle));
    fprintf(OPT.fid,'</Camera>');
end

output = repmat(char(1),1,1e5);
kk = 1;


%% pre process time for speed
if isnumeric(OPT.timeIn)
    OPT.timeIn  = datestr(OPT.timeIn ,OPT.dateStrStyle);
end
if isnumeric(OPT.timeOut)
    OPT.timeOut = datestr(OPT.timeOut,OPT.dateStrStyle);
end

%% Plot the points

for ii=1:length(lon)
    if OPT.debug
        disp(num2str([ii, length(lon)],'%g / %g'))
    end
    %% preprocess timespan
    if ~isempty(OPT.timeIn)
        if size(OPT.timeIn,1)==1
            timeSpan = KML_timespan('timeIn',OPT.timeIn      ,'timeOut',OPT.timeOut      ,'dateStrStyle',OPT.dateStrStyle);
        else
            timeSpan = KML_timespan('timeIn',OPT.timeIn(ii,:),'timeOut',OPT.timeOut(ii,:),'dateStrStyle',OPT.dateStrStyle);
        end
    else
        timeSpan = '';
    end
    % convert color values into colorRGB index values
    cindex = round(((c(ii)-OPT.CBcLim(1))/(OPT.CBcLim(2)-OPT.CBcLim(1))*(OPT.CBcolorSteps-1))+1);
    cindex = min(cindex,OPT.CBcolorSteps);
    cindex = max(cindex,1); % style numbering is 1-based
    
    OPT_poly.styleName = ['cmarker_',num2str(cindex,'%0.3d'),'map'];
    if isempty(OPT.name) && ~isempty(OPT.html)
        newOutput= sprintf([...
            '<Placemark>\n'...
            ' <name></name>\n'...            % no names so we see just the scatter points
            ' <visibility>%s</visibility>\n'...
            ' <description><![CDATA['...     % start required wrapper for html
            '%s'...
            ']]></description>\n'...         % end   required wrapper for html
            '%s',...                         % timeSpan
            ' <styleUrl>#%s</styleUrl>\n'... % styleName
            ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
            ' </Placemark>\n'],...
            num2str(OPT.visible),...
            str2line(cellstr(OPT.html{ii}),'s',''),... % remove trailing blanks per line (blanks are skipped in html anyway), and reshape 2D array correctly to 1D
            timeSpan,...
            OPT_poly.styleName,...
            lon(ii),lat(ii));
    elseif isempty(OPT.name) && isempty(OPT.html)
        newOutput= sprintf([...
            '<Placemark>\n'...
            ' <name></name>\n'...            % no names so we see just the scatter points
            ' <visibility>%s</visibility>\n'...
            '%s',...                         % timeSpan
            ' <styleUrl>#%s</styleUrl>\n'... % styleName
            ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
            ' </Placemark>\n'],...
            num2str(OPT.visible),...
            timeSpan,...
            OPT_poly.styleName,...
            lon(ii),lat(ii));
    elseif ~isempty(OPT.name) && isempty(OPT.html)
        newOutput= sprintf([...
            '<Placemark>\n'...
            ' <name>%s</name>\n'...          % no names so we see just the scatter points
            ' <visibility>%s</visibility>\n'...
            '%s',...                         % timeSpan
            ' <styleUrl>#%s</styleUrl>\n'... % styleName
            ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
            ' </Placemark>\n'],...
            OPT.name{ii},...
            num2str(OPT.visible),...
            timeSpan,...
            OPT_poly.styleName,...
            lon(ii),lat(ii));
    else
        
        newOutput= sprintf([...
            '<Placemark>\n'...
            ' <name>%s</name>\n'...          % no names so we see just the scatter points
            ' <visibility>%s</visibility>\n'...
            ' <description><![CDATA['...     % start required wrapper for html
            '%s'...
            ']]></description>\n'...         % end   required wrapper for html
            '%s',...                         % timeSpan
            ' <styleUrl>#%s</styleUrl>\n'... % styleName
            ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
            ' </Placemark>\n'],...
            char(OPT.name{ii}),...
            num2str(OPT.visible),...
            str2line(cellstr(OPT.html{ii}),'s',''),... % remove trailing blanks per line (blanks are skipped in html anyway), and reshape 2D array correctly to 1D
            timeSpan,...
            OPT_poly.styleName,...
            lon(ii),lat(ii));
    end
    
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

fprintf(OPT.fid,'</Folder>');

fprintf(OPT.fid,'%s',clrbarstring);

%% FOOTER

output = KML_footer;
fprintf(OPT.fid,'%s',output);

%% close KML

fclose(OPT.fid);

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end

%% openInGoogle?

if OPT.openInGE
    system(OPT.fileName);
end

%% Output

if nargout==1
    varargout = {pngNames};
end

%% EOF

