function varargout = KMLmarker(lat,lon,varargin)
%KMLMARKER  add a placemarker pushpin with text ballon
%
%   KMLmarker(lat,lon,'fileName',fname,<keyword,value>)
%
% where can can be one scaler or an array of size(lon)
% where - amongst others - the following <keyword,value> pairs have been implemented:
%
%  * filename               = []; % file name
%  * kmlname                = []; % name that appears in Google Earth places list
%  * name                   = cellstr with name per point (shown when highlighted)
%                             by default empty.
%  * html                   = cellstr with text per point (shown when highlighted)
%                             by default equal to value of c
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

   OPT.fileName            =  '';
   OPT.kmlName             =  '';
   OPT.openInGE            = false;
   OPT.markerAlpha         =  0.6;
   OPT.description         =  '';

   OPT.html                = [];
   OPT.name                = [];
  %OPT.iconnormalState     =  '';
  %OPT.iconhighlightState  =  '';
   OPT.scalenormalState    =  0.5;
   OPT.scalehighlightState =  1.0;
   OPT.colornormalState    =  [1 1 0]; % [1 1 0] = yellow
   OPT.colorhighlightState =  [1 1 0];

   if nargin==0
       varargout = {OPT};
       return
   end
   
%% process varargin

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

   [OPT, Set, Default] = setProperty(OPT, varargin);

%% correct lat and lon

   lat = lat(:);
   lon = lon(:);

   if any((abs(lat)/90)>1)
       error('latitude out of range, must be within -90..90')
   end
   lon = mod(lon+180, 360)-180;

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

    temp                    = dec2hex(round([OPT.markerAlpha OPT.colornormalState].*255),2);
    OPT.colornormalState    = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];
    temp                    = dec2hex(round([OPT.markerAlpha OPT.colorhighlightState].*255),2);
    OPT.colorhighlightState = [temp(1,:) temp(4,:) temp(3,:) temp(2,:)];

    if ~isempty(OPT.html)
    output = [output ...
        '<StyleMap id="cmarker_map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_n">\n'...
        ' <IconStyle>\n'...
        ' <color>' OPT.colornormalState '</color>\n'...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'... % ' <Icon><href>'    OPT.iconnormalState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>\n'... % no text except when mouse hoover
        ' </Style>\n'...
        '<Style id="cmarker_h">\n'...
        ' <BalloonStyle><text>\n'...
        ' <h3>$[name]</h3>'... % variable per dot
        ' $[description]\n'... % variable per dot
        ' </text></BalloonStyle>\n'...
        ' <IconStyle>\n'...
        ' <color>' OPT.colorhighlightState '</color>\n'...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...  % ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
    else
    output = [output ...
        '<StyleMap id="cmarker_map">\n'...
        ' <Pair><key>normal</key><styleUrl>#cmarker_n</styleUrl></Pair>\n'...
        ' <Pair><key>highlight</key><styleUrl>#cmarker_h</styleUrl></Pair>\n'...
        '</StyleMap>\n'...
        '<Style id="cmarker_n">\n'...
        ' <IconStyle>\n'...
        ' <color>' OPT.colornormalState '</color>\n'...
        ' <scale>' num2str(OPT.scalenormalState) '</scale>\n'... % ' <Icon><href>'    OPT.iconnormalState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle><color>000000ff</color><scale>0</scale></LabelStyle>\n'... % no text except when mouse hoover
        ' </Style>\n'...
        '<Style id="cmarker_h">\n'...
        ' <IconStyle>\n'...
        ' <color>' OPT.colorhighlightState '</color>\n'...
        ' <scale>' num2str(OPT.scalehighlightState) '</scale>\n'...  % ' <Icon><href>'    OPT.iconhighlightState '</href></Icon>\n'...
        ' </IconStyle>\n'...
        ' <LabelStyle></LabelStyle>\n'...
        ' </Style>\n'];
    end
        
%% print and clear output

   output = [output '<!--############################-->\n'];
   fprintf(OPT.fid,output);output = [];
   fprintf(OPT.fid,'<Folder>');
   fprintf(OPT.fid,'  <name>placeholders</name>');
   fprintf(OPT.fid,'  <open>0</open>');
   
   output = repmat(char(1),1,1e5);
   kk = 1;

%% Plot the points

   for ii=1:length(lon)

    OPT_poly.styleName = ['cmarker_map'];
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
        ' <name>%s</name>\n'...                        % no names so we see just the scatter points
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
        OPT.name{ii},...
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

%% Output

   if nargout==1
    varargout = {handles};
   end

%% EOF

