function OPT = KMLfig2pngNew (h,lat,lon,z,varargin)
% KMLFIG2PNGnew   makes a tiled png figure for google earth
%
%   h = surf(lon,lat,z)
%   KMLfig2png(h,lat,lon,z,<keyword,value>) 
%
% make a surf or pcolor in lon/lat/z, and then pass it to KMLfig2png
%
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLfig2png()
%
% where Lod = Level of Detail.
%
% For plots with    light effects set:  'scaleHeight',true ,...
% For plots without light effects set:  'scaleHeight',false,...
%
% fileName  relative filename, incl relative subPath. 
% basePath  absolute path where to write kml files (will not appear inside kml, those contain only fileName)
% baseUrl   absolute url where kml will appear. (A webkml needs absolute url, albeit only needed in the mother KML, local files can have relative paths.)
%
% See also: GOOGLEPLOT, PCOLOR, KMLFIG2PNG_ALPHA

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

% TO DO: ignore colorbar, if present
% TO DO: also correct kml if hightest levels < default highestLevel

OPT.ha                 =     []; % handle to axes
OPT.hf                 =     []; % handle to figure
OPT.dim                =    256; % tile size in pixels
OPT.dimExt             =     16; % render tiles expanded by n pixels, to remove edge effects
OPT.bgcolor            = [100 155 100];  % background color to be made transparent
OPT.alpha              =      1;
OPT.fileName           =     []; % relative filename, incl relative subpath
OPT.basePath           =     ''; % absolute path where to write kml files (will not appear inside kml, those remain relative)
OPT.baseUrl            =     ''; % absolute url where kml will appear. (A webkml needs absolute url, albeit only needed in the mother KML, local files can have relative paths.)
OPT.kmlName            =     []; % name in Google Earth Place list
OPT.logo               =     [];
OPT.alpha              =      1;
OPT.minLod             =     []; % minimum level of detail to keep a tile in view. Is calculated when left blank.
OPT.minLod0            =     -1; % minimum level of detail to keep most detailed tile in view. Default is -1 (don't hide when zoomed in a lot)
OPT.maxLod             =     [];
OPT.maxLod0            =     -1;
OPT.dWE                =     []; % determines how much extra data to tiles to be able 
OPT.dNS                =     []; % to generate them as fraction of size of smallest tile
OPT.timeIn             =     []; % time properties
OPT.timeOut            =     [];
OPT.timeFormat        = 'yyyy-mm-ddTHH:MM:SS';
OPT.drawOrder          =      1; 
OPT.bgcolor            = [100 155 100];  % background color to be made transparent
OPT.description        =     ''; 
OPT.colorbar           =   true;
OPT.CBcolorbarlocation = {'W'}; %{'N','E','S','W'}; %{'N','NNE','ENE','E','ESE','SSE','S','SSW','WSW','W','WNW','NNW'};
OPT.CBcolorbartitle    = '';
OPT.mergeExistingTiles =   true; % does not work when changing dim
OPT.printTiles         =   true;
OPT.joinTiles          =   true;
OPT.makeKML            =   true;
OPT.basecode           = '';
OPT.highestLevel       = [];
OPT.lowestLevel        = [];
OPT.debug              = 0;  % display some progress info

if nargin==0
  return
else
   D.lat = lat;
   D.lon = lon;
   D.z   = z;
   %if ~isequal(size(D.lon) - size(D.z),[0 0])
   %  D.z = addrowcol(D.z,1,1,Inf); % no, lat KML_fig2pngNew_printTile handle that
   %end
   D.N   = max(D.lat(:));
   D.S   = min(D.lat(:));
   D.W   = min(D.lon(:));
   D.E   = max(D.lon(:));

   OPT.basecode           = KML_fig2pngNew_SmallestTileThatContainsAllData(D);
   OPT.highestLevel       = length(OPT.basecode);
   OPT.lowestLevel        = OPT.highestLevel+4;
end

OPT.h    = h;  % handle to input surf object

OPT = setproperty(OPT, varargin);

%% initialize waitbars

if OPT.printTiles
    multiWaitbar('fig2png_print_tile'  ,0,'label','Printing tiles' ,'color',[0.0 0.4 0.9])
end
if OPT.joinTiles
   multiWaitbar('fig2png_merge_tiles' ,0,'label','Merging tiles'  ,'color',[0.6 0.2 0.2])
end
if OPT.makeKML
    multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML'    ,'color',[0.9 0.4 0.1])
end

%% make sure you always see somehting in GE, even at really low lowestLevel
if OPT.lowestLevel <= OPT.highestLevel 
   disp(['OPT.lowestLevel (',num2str(OPT.lowestLevel),') set to OPT.highestLevel (',num2str(OPT.highestLevel ),') + 1 = ',num2str(OPT.highestLevel+1)])
   OPT.lowestLevel = OPT.highestLevel + 1;
end

OPT.highestLevel  = max(OPT.highestLevel,1);

%% set maxLod and minLod defaults
if  isempty(OPT.dWE)
    OPT.dWE           = 0.2*360/(2^OPT.lowestLevel); % determines how much extra data to tiles to be able 
end
if isempty(OPT.dNS)
    OPT.dNS           = 0.2*360/(2^OPT.lowestLevel); % to generate them as fraction of size of smalles tile
end
    
    
if isempty(OPT.minLod),                 OPT.minLod = round(  OPT.dim/1.5); end
if isempty(OPT.maxLod)&&OPT.alpha  < 1, OPT.maxLod = round(2*OPT.dim/1.5); end % you see 1 layers always
if isempty(OPT.maxLod)&&OPT.alpha == 1, OPT.maxLod = round(4*OPT.dim/1.5); end % you see 2 layers, except when fully zoomed in

if isempty(OPT.basePath)
    OPT.basePath = pwd;
end

%% filename
%            fileName:           relative link in kml
%   Path    /-------------\      where to save files (fopen, mkdir)
% /----------------\
% basePath + subPath + Name
%
% baseUrl  + subPath + Name
% \-----------------------/
%  Url                           absolute link in mother kml
%
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [OPT.Name, OPT.Path] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','renderedPNG.kml');
    OPT.fileName = fullfile(OPT.Path,OPT.Name);
    OPT.subPath  =  '';       % relative part of path that will appear in kml
    OPT.basePath =  OPT.Path; % here we do not know difference between basepath
else
    [OPT.subPath OPT.Name] = fileparts(OPT.fileName);
    OPT.Path = [OPT.basePath filesep OPT.subPath];
end

% set kmlName if it is not set yet
[ignore OPT.Name] = fileparts(OPT.fileName);
if isempty(OPT.kmlName)
    OPT.kmlName = OPT.Name;
end

% make a folder for the sub files
if ~exist([OPT.basePath filesep OPT.Name],'dir')
     mkdir(OPT.basePath,OPT.Name);
end

%% preproces timespan
%  http://code.google.com/apis/kml/documentation/kmlreference.html#timespan

if  ~isempty(OPT.timeIn)
    if ~isempty(OPT.timeOut)
        OPT.timeSpan = sprintf([...
            '<TimeSpan>\n'...
            '<begin>%s</begin>\n'...% OPT.timeIn
            '<end>%s</end>\n'...    % OPT.timeOut
            '</TimeSpan>\n'],...
            datestr(OPT.timeIn,OPT.timeFormat),datestr(OPT.timeOut,OPT.timeFormat));
    else
        OPT.timeSpan = sprintf([...
            '<TimeStamp>\n'...
            '<when>%s</when>\n'...  % OPT.timeIn
            '</TimeStamp>\n'],...
            datestr(OPT.timeIn,OPT.timeFormat));
    end
else
    OPT.timeSpan ='';
end

%% figure settings

OPT.ha  = get(OPT.h ,'Parent');
OPT.hf  = get(OPT.ha,'Parent');
daspect(OPT.ha,'auto') % repair effect of for instance axislat()

          set(OPT.ha,'Position',[0 0 1 1])
          set(OPT.hf,'PaperUnits', 'inches','PaperPosition',...
          [0 0 OPT.dim+2*OPT.dimExt OPT.dim+2*OPT.dimExt],...
          'color',OPT.bgcolor/255,'InvertHardcopy','off');

%% run scripts (These are the core functions)

%   --------------------------------------------------------------------
% Generates tiles at most detailed level
if OPT.printTiles
    KML_fig2pngNew_printTile(OPT.basecode,D,OPT)
end

%   --------------------------------------------------------------------
% Generates tiles other levels based on already created tiles (merging & resizing)
if OPT.joinTiles
   KML_fig2pngNew_joinTiles(OPT)
end

%   --------------------------------------------------------------------
% Generates KML based on png file names
if OPT.makeKML
    KML_fig2pngNew_makeKML(OPT)
end
%   --------------------------------------------------------------------

%% and write the 'mother' KML

if OPT.makeKML
    if ~isempty(OPT.baseUrl)
        if ~strcmpi(OPT.baseUrl(end),'/');
            OPT.baseUrl = [OPT.baseUrl '\'];
        end
    end
    
    % relative for local files
    if isempty(OPT.baseUrl)
       href.kml = fullfile(             OPT.subPath, OPT.Name, [OPT.Name '_' OPT.basecode(1:OPT.highestLevel) '.kml']);
    else
       href.kml = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, [OPT.Name '_' OPT.basecode(1:OPT.highestLevel) '.kml']);
    end
    
    output = sprintf([...
        '<NetworkLink>'...
        '<name>network-linked-tiled-pngs</name>'... % name
        '%s'...              % timespan                                                                                                          % time
        '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'... % link
        '</NetworkLink>'],...
        OPT.timeSpan,href.kml);
    file.kml = [OPT.basePath, filesep,OPT.fileName];
    OPT.fid=fopen(file.kml,'w');
    OPT_header = struct(...
        'name',OPT.kmlName,...
        'open',0,...
        'description',OPT.description);
        
 %% LOGO
 %  add png to directory of tiles (split png and href in KMLcolorbar)

 if isempty(OPT.logo)
     logo   = '';
 else

      % add to one level deeper
     file.logo = fullfile(OPT.basePath,OPT.Name, [filename(OPT.logo),'4GE.png']);
     
     % relative for local files
     if isempty(OPT.baseUrl)
        href.logo = fullfile(             OPT.subPath, OPT.Name, filenameext(file.logo));
     else
        href.logo = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, filenameext(file.logo));
     end     
     logo   = ['<Folder>' KMLlogo(OPT.logo,'fileName',0,'kmlName', 'logo',...
         'logoName',file.logo) '</Folder>'];
     logo = strrep(logo,['<Icon><href>' filenameext(file.logo)],...
                        ['<Icon><href>' href.logo]);
 end
    output = [KML_header(OPT_header) logo output];

 %% COLORBAR
 %  add png to directory of tiles (split png and href in KMLcolorbar)


    if OPT.colorbar

       % add to one level deeper
       file.CB = fullfile(OPT.basePath, OPT.Name, [OPT.Name]);

       % relative for local files
       if isempty(OPT.baseUrl)
          href.CB = fullfile(             OPT.subPath, OPT.Name, [OPT.Name]);
       else
          href.CB = fullfile(OPT.baseUrl, OPT.subPath, OPT.Name, [OPT.Name]);
       end
       

       clrbarstring = KMLcolorbar('CBcLim',clim(OPT.ha),...
                              'CBfileName',file.CB,...
                               'CBkmlName','colorbar',...
                              'CBcolorMap',colormap(OPT.ha),...
                            'CBcolorTitle',OPT.CBcolorbartitle,...
                      'CBcolorbarlocation',OPT.CBcolorbarlocation);
        
        % refer to one level deeper,  KMLcolorbar chops directory in <href>
        clrbarstring = strrep(clrbarstring,['<Icon><href>' filename(file.CB)],...
                                           ['<Icon><href>' href.CB]);
        output = [output clrbarstring];
    end
    
    if OPT.debug
    var2evalstr(href)
    var2evalstr(file)
    end

 %% FOOTER

    output = [output KML_footer];
    fprintf(OPT.fid,'%s',output);
    
    % close KML
    fclose(OPT.fid);
    multiWaitbar('fig2png_write_kml'   ,1,'label','Writing KML'    ,'color',[0.9 0.4 0.1])
%% restore

    set(OPT.ha,'DataAspectRatio',daspect); % restore
end
