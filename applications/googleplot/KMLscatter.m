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
%  * colorMap               = colormap (default @(m) jet(m));
%  * colorSteps             = number of colors in colormap (default 20);
%  * cLim                   = cLim aka caxis (default [min(c) max(c)]);
%  * name                   = cellstr with name per point (shown when highlighted)
%                             by default empty.
%  * html                   = cellstr with text per point (shown when highlighted)
%                             by default equal to value of c
%  * OPT.iconnormalState    = marker, default 'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png'
%  * OPT.iconhighlightState = see also, http://www.mymapsplus.com/Markers, 
%                                       http://www.visual-case.it/cgi-bin/vc/GMapsIcons.pl
%                                       http://www.benjaminkeen.com/?p=105
%                                       http://code.google.com/p/google-maps-icons/
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
   OPT                    = KMLcolorbar();
   % rest of the options
   OPT.fileName           =  '';
   OPT.kmlName            =  '';
   OPT.colorMap           =  @(m) jet(m);
   OPT.colorSteps         =  20;
   OPT.cLim               =  [];
   OPT.openInGE           =  0;
   OPT.markerAlpha        =  0.6;
   OPT.description        =  '';
   OPT.colorbar           = 1;

   OPT.html               = [];
   OPT.name               = [];
   OPT.iconnormalState    =  'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
   OPT.iconhighlightState =  'http://svn.openlaszlo.org/sandbox/ben/smush/circle-white.png';
   OPT.scalenormalState   =  0.25;
   OPT.scalehighlightState=  1.0;

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

   if isempty(OPT.cLim)
       OPT.cLim         = [min(c(:)) max(c(:))];
       if OPT.cLim(1)==OPT.cLim(2)
       OPT.cLim = OPT.cLim + 10.*[-eps eps];
       end
   end
   
   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
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

   if isnumeric(OPT.colorMap)
      OPT.colorSteps = size(OPT.colorMap,1);
   end
   
   if isa(OPT.colorMap,'function_handle')
     colorRGB           = OPT.colorMap(OPT.colorSteps);
   elseif isnumeric(OPT.colorMap)
     if size(OPT.colorMap,1)==1
       colorRGB         = repmat(OPT.colorMap,[OPT.colorSteps 1]);
     elseif size(OPT.colorMap,1)==OPT.colorSteps
       colorRGB         = OPT.colorMap;
     else
       error(['size ''colorMap'' (=',num2str(size(OPT.colorMap,1)),') does not match ''colorSteps''  (=',num2str(OPT.colorSteps),')'])
     end
   end   
   
   %% showing number next to scatter point makes iconhighlightState too SLOW, 
   %  so show values only in pop-up.

   if isempty(OPT.html);OPT.html = cellstr(num2str(c(:)));end
   if  ischar(OPT.html);OPT.html = cellstr(OPT.html  );end
  %if isempty(OPT.name);OPT.name = cellstr(num2str(c(:)));end %  makes iconhighlightState too SLOW!
   if  ischar(OPT.name);OPT.name = cellstr(OPT.name  );end

%% start KML

   OPT.fid=fopen(OPT.fileName,'w');

%% HEADER

   OPT_header = struct(...
       'name',OPT.kmlName,...
       'open',0,...
       'description',OPT.description);
   output = KML_header(OPT_header);
   
   if OPT.colorbar
      clrbarstring = KMLcolorbar(OPT);
      output = [output clrbarstring];
   end

output = [output '<!--############################-->\n'];

%% STYLE

for ii = 1:OPT.colorSteps

    OPT_stylePoly.name  = ['style' num2str(ii)];
    temp                = dec2hex(round([OPT.markerAlpha, colorRGB(ii,:)].*255),2);
    markerColor         = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

    if ~isempty(OPT.html)
    output = [output ...
        '<StyleMap id="cmarker_',num2str(ii,'%0.3d'),'map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_',num2str(ii,'%0.3d'),'n">\n'...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'...
        ' <Icon><href>'    OPT.iconnormalState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>\n'... % no text except when mouse hoover
        ' </Style>\n'...
        '<Style id="cmarker_',num2str(ii,'%0.3d'),'h">\n'...
        ' <BalloonStyle><text>\n'...
        ' <h3>$[name]</h3>'... % variable per dot
        ' $[description]\n'... % variable per dot
        ' </text></BalloonStyle>\n'...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...
        ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
    else
    output = [output ...
        '<StyleMap id="cmarker_',num2str(ii,'%0.3d'),'map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_',num2str(ii,'%0.3d'),'h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_',num2str(ii,'%0.3d'),'n">\n'...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'...
        ' <Icon><href>'    OPT.iconnormalState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>\n'... % no text except when mouse hoover
        ' </Style>\n'...
        '<Style id="cmarker_',num2str(ii,'%0.3d'),'h">\n'...
        ' <IconStyle>\n'...
        ' <color>' markerColor '</color>\n'...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...
        ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
    end
end

%% print and clear output

   output = [output '<!--############################-->\n'];
   fprintf(OPT.fid,output);output = [];
   fprintf(OPT.fid,'<Folder>');
   fprintf(OPT.fid,'  <name>patches</name>');
   fprintf(OPT.fid,'  <open>0</open>');
   
   output = repmat(char(1),1,1e5);
   kk = 1;

%% Plot the points

   for ii=1:length(lon)

    % convert color values into colorRGB index values
    cindex = round(((c(ii)-OPT.cLim(1))/(OPT.cLim(2)-OPT.cLim(1))*(OPT.colorSteps-1))+1);
    cindex = min(cindex,OPT.colorSteps);
    cindex = max(cindex,1); % style numbering is 1-based
    

    OPT_poly.styleName = ['cmarker_',num2str(cindex,'%0.3d'),'map'];
    if isempty(OPT.name) & ~isempty(OPT.html)
    newOutput= sprintf([...
        '<Placemark>\n'...
        ' <name></name>\n'...                          % no names so we see just the scatter points
        ' <visibility>1</visibility>\n'...
        ' <description><![CDATA['... % start required wrapper for html
        '%s'...
        ']]></description>\n'...     % end   required wrapper for html
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
        ' </Placemark>\n'],...
        str2line(cellstr(OPT.html{ii}),'s',''),... % remove trailing blanks per line (blanks are skipped in html anyway), and reshape 2D array correctly to 1D
        OPT_poly.styleName,...
        lon(ii),lat(ii));
    elseif isempty(OPT.name) & isempty(OPT.html)
    newOutput= sprintf([...
        '<Placemark>\n'...
        ' <name></name>\n'...                          % no names so we see just the scatter points
        ' <visibility>1</visibility>\n'...
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
        ' </Placemark>\n'],...
        OPT_poly.styleName,...
        lon(ii),lat(ii));
    elseif ~isempty(OPT.name) & isempty(OPT.html)
    newOutput= sprintf([...
        '<Placemark>\n'...
        ' <name>%s</name>\n'...                          % no names so we see just the scatter points
        ' <visibility>1</visibility>\n'...
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
        ' </Placemark>\n'],...
        OPT.name{ii},...
        OPT_poly.styleName,...
        lon(ii),lat(ii));
    else
    newOutput= sprintf([...
        '<Placemark>\n'...
        ' <name>%s</name>\n'...                          % no names so we see just the scatter points
        ' <visibility>1</visibility>\n'...
        ' <description><![CDATA['... % start required wrapper for html
        '%s'...
        ']]></description>\n'...     % end   required wrapper for html
        ' <styleUrl>#%s</styleUrl>\n'...               % styleName
        ' <Point><coordinates>% 2.8f,% 2.8f, 0</coordinates></Point>\n'...
        ' </Placemark>\n'],...
        char(OPT.name{ii}),...
        str2line(cellstr(OPT.html{ii}),'s',''),... % remove trailing blanks per line (blanks are skipped in html anyway), and reshape 2D array correctly to 1D
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

