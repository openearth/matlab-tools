function varargout = nc_multibeam_to_kml_tiled_png(varargin)
%NC_MULTIBEAM_TO_KML_TILED_PNG  Generate a tiled png from data in nc files
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_multibeam_to_kml_tiled_png(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_multibeam_to_kml_tiled_png
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 20 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.inputNc                 = [];
OPT.inputDir                = [];
OPT.outputDir               = [];
OPT.outputKml               = [];
OPT.deleteExistingOutputDir = false;

OPT.kmlName                 = [];
OPT.make                    = true;
OPT.make_kmz                = false;
OPT.lowestLevel             = 15;
OPT.tiledim                 = 256;

OPT.clim                    = [-50 25];
OPT.colorMap                = @(m) colormap_cpt('bathymetry_vaklodingen',m);
OPT.colorSteps              = 500;
OPT.colorbar                = true;
OPT.datatype                = 'multibeam';
OPT.description             = [];
OPT.lightAdjust             = [];
OPT.serverURL               = [];


if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin{:});
if ~OPT.make
    disp('generation of kml files skipped')
    varargout = {OPT};
    return
end

%% error checking
if isempty(OPT.inputDir)
    [OPT.inputDir, fname, ext]  = fileparts(OPT.inputNc);
    OPT.inputNc                 = [fname ext];
end

if isempty(OPT.inputDir)
    OPT.inputDir = pwd;
end

if isempty(OPT.inputNc)
    OPT.inputNc = '*.nc';
end

if isempty(OPT.outputKml)
    [ignore,fname,ignore] = fileparts(OPT.inputNc); %#ok<*NASGU>
    if strcmpi(fname,'*'); fname = OPT.datatype; end
    OPT.outputKml = fname;
else
    [ignore,OPT.outputKml,ignore] = fileparts(OPT.outputKml);
end

if isempty(OPT.outputDir)
    OPT.outputDir = OPT.inputDir;
end
fns = dir(fullfile(OPT.inputDir,OPT.inputNc));

disp('generating kml files... ')
%% initialize waitbars
multiWaitbar('kml_print_all_tiles' ,'close')
multiWaitbar('fig2png_print_tile'  ,'close')
multiWaitbar('merge_all_tiles'     ,'close')
multiWaitbar('fig2png_merge_tiles' ,'close')
multiWaitbar('fig2png_write_kml'   ,'close')

multiWaitbar('kml_print_all_tiles' ,0,'label','Printing tiles: total'       ,'color',[0.0 0.3 0.6])
multiWaitbar('fig2png_print_tile'  ,0,'label','Printing tiles: per file'    ,'color',[0.0 0.5 1.0])
multiWaitbar('merge_all_tiles'     ,0,'label','Merging tiles: total'        ,'color',[0.5 0.1 0.1])
multiWaitbar('fig2png_merge_tiles' ,0,'label','Merging tiles: per timestep' ,'color',[0.7 0.3 0.3])
multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML: total'          ,'color',[0.9 0.4 0.1])

if isempty(OPT.lightAdjust)
    OPT.lightAdjust = 2^(OPT.lowestLevel-16);
end

EPSG  = load('EPSG');

%% base figure (properties of which will be adjusted to print tiles)

figure('Visible','Off')
x = linspace(0,0.01,100);
[x,y] = meshgrid(x,x);
z = kron([10 1;5 1],peaks(50))-rand(100);
h = surf(x,y,z);
hl = light;material([0.7 0.2 0.15 100]);shading interp;lighting phong;axis off;
axis tight;view(0,90);lightangle(hl,180,65);
colormap(OPT.colorMap(OPT.colorSteps));clim(OPT.clim*OPT.lightAdjust);

%% create kml directory if it does not yet exist
if exist(fullfile(OPT.outputDir,OPT.outputKml),'dir')
    if OPT.deleteExistingOutputDir 
        rmdir(fullfile(OPT.outputDir,OPT.outputKml), 's')
    else
        error('the output directory is not empy, but ''deleteExistingOutputDir'' is set to false')
    end
else
    mkpath(fullfile(OPT.outputDir,OPT.outputKml))
end

%% get total file size
WB.bytesToDo = 0;
WB.bytesDone = 0;
for ii = 1:length(fns)
    WB.bytesToDo = WB.bytesToDo+fns(ii).bytes;
end

%% pre-allocate    
[minlat,minlon,maxlat,maxlon] = deal(nan);

%% MAKE TILES in this loop      
for ii = 1:length(fns);
    url = fullfile(OPT.inputDir,fns(ii).name); %#ok<*ASGLU>
    time = nc_varget(url,'time');
    
    multiWaitbar('kml_print_all_tiles'  ,WB.bytesDone/WB.bytesToDo,...
        'label',sprintf('Printing tiles: %s Timestep: %d/%d',fns(ii).name,1,size(time,1)))
    
    lon  = nc_varget(url, 'lon');
    lat  = nc_varget(url, 'lat');
    
    % expand lat and lon in each direction to create some overlap
    lon = [lon(:,1) + (lon(:,1)-lon(:,2))*.55  lon  lon(:,end) + (lon(:,end)-lon(:,end-1))*.55];
    lat = [lat(:,1) + (lat(:,1)-lat(:,2))*.55  lat  lat(:,end) + (lat(:,end)-lat(:,end-1))*.55];
    lon = [lon(1,:) + (lon(1,:)-lon(2,:))*.55; lon; lon(end,:) + (lon(end,:)-lon(end-1,:))*.55];
    lat = [lat(1,:) + (lat(1,:)-lat(2,:))*.55; lat; lat(end,:) + (lat(end,:)-lat(end-1,:))*.55];

    % convert time to years
    date          = time+datenum(1970,1,1);
    date(end+1,:) = date(end) + 1;
    
    % get dimension info of z
    z_dim_info = nc_getvarinfo(url,'z') ;
    time_dim = strcmp(z_dim_info.Dimension,'time');
    

    for jj = size(time,1):-1:1
        % load z data
        z = nc_varget(url,'z',...
            [ 0, 0, 0] + (jj-1)*time_dim,...
            [-1,-1,-1] + 2*time_dim);
        if sum(~isnan(z(:)))>=3
            disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%'])
            z = z([1 1 1:end end end],:); z = z(:,[1 1 1:end end end]); % expand z
            mask = ~isnan(z);
            mask = ...
                mask(1:end-2,1:end-2)+...
                mask(2:end-1,1:end-2)+...
                mask(3:end-0,1:end-2)+...
                mask(1:end-2,2:end-1)+...
                mask(3:end-0,2:end-1)+...
                mask(1:end-2,3:end-0)+...
                mask(2:end-1,3:end-0)+...
                mask(3:end-0,3:end-0);
            mask(~isnan(z(2:end-1,2:end-1)))=0;
            mask = mask>0;

            for kk = 2:size(z,1)-1
                for ll = 2:size(z,2)-1
                    if mask(kk-1,ll-1)
                        temp = z(kk-1:kk+1,ll-1:ll+1);
                        z(kk,ll) = nanmean(temp(:));
                    end
                end
            end

            z = z(2:end-1,2:end-1);
%% MAKE TILES
            KMLfig2pngNew(h,lat,lon,z*OPT.lightAdjust,'highestLevel',10,'lowestLevel',OPT.lowestLevel,...
                'timeIn',date(jj),'timeOut',date(jj+1),...
                'fileName',[datestr(date(jj),29) '.kml'],'timeFormat','yyyy-mm-dd',...
                'drawOrder',round(date(jj)),'joinTiles',false,...
                'makeKML',false,'mergeExistingTiles',true,...
                'basePath',fullfile(OPT.outputDir,OPT.outputKml),'dim',OPT.tiledim);

            minlat = min(minlat,min(lat(:)));
            minlon = min(minlon,min(lon(:)));
            maxlat = max(maxlat,max(lat(:)));
            maxlon = max(maxlon,max(lon(:)));

        else
            disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%, no file created'])
        end
        WB.bytesDone =  WB.bytesDone + fns(ii).bytes/size(time,1);
        multiWaitbar('kml_print_all_tiles'  ,WB.bytesDone/WB.bytesToDo,...
            'label',sprintf('Printing tiles: %s Timestep: %d/%d',fns(ii).name,jj,size(time,1)))
    end
end
multiWaitbar('fig2png_print_tile','close')
multiWaitbar('kml_print_all_tiles',1,'label','Printing tiles')

%% JOIN TILES
fns = dir(fullfile(OPT.outputDir,OPT.outputKml));
multiWaitbar('merge_all_tiles'     ,0,'label','Merging tiles: total')
for ii = 3:length(fns)
    multiWaitbar('merge_all_tiles' ,(ii-3)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-3,length(fns)-2))
    if fns(ii).isdir
        OPT2 = KMLfig2pngNew(h,lat,lon,z,'highestLevel',6,'lowestLevel',OPT.lowestLevel,...
            'timeIn',datenum(fns(ii).name),'timeOut',datenum(fns(ii).name)+1,...
            'basePath',fullfile(OPT.outputDir,OPT.outputKml),'fileName',fullfile([fns(ii).name '.kml']),...
            'timeFormat','yyyy-mm-dd','drawOrder',round(datenum(fns(ii).name)),...
            'printTiles',false,'joinTiles',true,'makeKML',false,'dim',OPT.tiledim);
    end
    multiWaitbar('merge_all_tiles' ,(ii-2)/(length(fns)-2),'label',sprintf('Merging tiles: %d/%d',ii-2,length(fns)-2))
end
multiWaitbar('fig2png_merge_tiles','close')
multiWaitbar('merge_all_tiles',1,'label','Merging tiles')

%% make kml files
multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML - Getting unique png file names...','color',[0.9 0.4 0.1])
OPT2.highestLevel  = inf;
OPT2.lowestLevel   = OPT.lowestLevel;
folderName = OPT.datatype;
try %#ok<*TRYNC>
    rmdir([folderName filesep 'KML'], 's')
end

dates = findAllFiles('basepath',fullfile(OPT.outputDir,OPT.outputKml),'recursive',false);
datenums = datenum(dates,'yyyy-mm-dd');

tilefull = findAllFiles('basepath',fullfile(OPT.outputDir,OPT.outputKml),'pattern_incl','*.png');
tilefull2 = tilefull;
for ii = 1:length(tilefull)
    tilefull2{ii} = tilefull2{ii}(end-40:end);
end


tilefull = findAllFiles('basepath',fullfile(OPT.outputDir,OPT.outputKml),'pattern_incl','*.png');

tiles = cell(size(tilefull));
[path, fname] = fileparts(tilefull{1}); %#ok<NASGU>
id = strfind(tilefull{1},'_'); id = id(end)-length(path);

for ii = 1:length(tilefull)
    [path, fname] = fileparts(tilefull{ii});
    tiles{ii} = fname(id:end);
    OPT2.highestLevel = min(length(tiles{ii}),OPT2.highestLevel);
    OPT2.lowestLevel  = max(length(tiles{ii}),OPT.lowestLevel);
end
mkdir(fullfile(OPT.outputDir,OPT.outputKml,'KML'));

%% MAKE KML  
multiWaitbar('fig2png_write_kml'   ,0,'label','Writing KML...','color',[0.9 0.4 0.1])
for level = OPT2.highestLevel:OPT2.lowestLevel

    WB.a = 0.25.^(OPT.lowestLevel - level)*.25;
    WB.b = 0.25.^(OPT.lowestLevel - level)*.75;
    
    tileCodes = nan(length(tiles),level);
    for ii = 1:length(tiles)
        if length(tiles{ii}) == level
            tileCodes(ii,:) = tiles{ii};
        end
    end

    tileCodes(any(isnan(tileCodes),2),:) = [];
    tileCodes = char(tileCodes);
    tilesOnLevel = unique(tileCodes(:,1:end),'rows');
    if level == OPT2.highestLevel
        fileID = tilesOnLevel;
    end

    tileCodesNextLevel = nan(length(tiles),level+1);
    for ii = 1:length(tiles)
        if length(tiles{ii}) == level+1
            tileCodesNextLevel(ii,:) = tiles{ii};
        end
    end
    tileCodesNextLevel(any(isnan(tileCodesNextLevel),2),:) = [];
    tileCodesNextLevel = char(tileCodesNextLevel);
    tilesOnNextLevel = unique(tileCodesNextLevel(:,1:end),'rows');

    addCode = ['01';'23'];

    if level == OPT2.highestLevel
        minLod = OPT2.minLod0;
    else
        minLod = OPT2.minLod;
    end

    if level == OPT.lowestLevel
        maxLod = OPT2.maxLod0;
    else
        maxLod = OPT2.maxLod;
    end

    for nn = 1:size(tilesOnLevel,1)
        output = '';
        %% networklinks to children files
        if level ~= OPT2.lowestLevel
            for ii = 1:2
                for jj = 1:2
                    code = [tilesOnLevel(nn,:) addCode(ii,jj)];
                    B = KML_fig2pngNew_code2boundary(code);
                    if  any(ismember(tilesOnNextLevel,num2str(code),'rows'))
                        output = [output sprintf([...
                            '<NetworkLink>\n'...
                            '<name>%s</name>\n'...name
                            '<Region>\n'...
                            '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                            '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                            '</Region>\n'...
                            '<Link><href>%s.kml</href><viewRefreshMode>onRegion</viewRefreshMode></Link>\n'...kmlname
                            '</NetworkLink>\n'],...
                            code,...
                            minLod,-1,...
                            B.N,B.S,B.W,B.E,...
                            code)];
                    end
                end
            end
        end
        %% add png icon links to kml 
        B = KML_fig2pngNew_code2boundary(tilesOnLevel(nn,:));
        for iDate = 1: length(dates)
            pngFile = [dates{iDate} filesep dates{iDate} '_' tilesOnLevel(nn,:) '.png'];
            temp = fullfile(OPT.outputDir, OPT.outputKml, pngFile);
            if any(strcmp(temp(end-40:end),tilefull2))
                OPT2.timeIn = datenums(iDate);
                OPT2.timeOut = OPT2.timeIn+1;
                OPT2.drawOrder = datenum(iDate);
                OPT2.timeSpan = sprintf(...
                    '<TimeSpan><begin>%s</begin><end>%s</end></TimeSpan>\n',...OPT2.timeIn,OPT2.timeOut
                    datestr(OPT2.timeIn,OPT2.timeFormat),datestr(OPT2.timeOut,OPT2.timeFormat));
                output = [output sprintf([...
                    '<Region>\n'...
                    '<Lod><minLodPixels>%d</minLodPixels><maxLodPixels>%d</maxLodPixels></Lod>\n'...minLod,maxLod
                    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                    '</Region>\n'...
                    '<GroundOverlay>\n'...
                    '<name>%s</name>\n'...kml_id
                    '<drawOrder>%d</drawOrder>\n'...drawOrder
                    '%s'...timeSpan
                    '<Icon><href>..\\%s</href></Icon>\n'...%file_link
                    '<LatLonAltBox><north>%3.8f</north><south>%3.8f</south><west>%3.8f</west><east>%3.8f</east></LatLonAltBox>\n' ...N,S,W,E
                    '</GroundOverlay>\n'],...
                    minLod,maxLod,B.N,B.S,B.W,B.E,...
                    tilesOnLevel(nn,:),...
                    OPT2.drawOrder+level,OPT2.timeSpan,...
                    pngFile,...
                    B.N,B.S,B.W,B.E)];
            end
        end
        fid=fopen(fullfile(OPT.outputDir,OPT.outputKml,'KML',[tilesOnLevel(nn,:) '.kml']),'w');
        OPT_header = struct(...
            'name',tilesOnLevel(nn,:),...
            'open',0);
        output = [KML_header(OPT_header) output];

        % FOOTER
        output = [output KML_footer]; %#ok<*AGROW>
        fprintf(fid,'%s',output);

        % close KML
        fclose(fid);
        
        if mod(nn,5)==1;
            multiWaitbar('fig2png_write_kml' ,WB.a + WB.b*nn/size(tilesOnLevel,1),'label','Writing KML...')
        end
    end
end

%% generate a locally readable kml file
if ~isempty(OPT2.baseUrl)
    if ~strcmpi(OPT2.baseUrl(end),'/');
        OPT2.baseUrl = [OPT2.baseUrl '\'];
    end
end

OPT2.kmlName = OPT.datatype;
OPT2.description = '';


output = sprintf([...
    '<NetworkLink>'...
    '<name>%s</name>'...                                                                                             % name
    '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
    '</NetworkLink>'],...
    OPT2.kmlName,...
    fullfile(OPT.outputKml, 'KML', [fileID '.kml']));

OPT2.fid=fopen(fullfile(OPT.outputDir,OPT.outputKml, 'doc.kml'),'w');
OPT_header = struct(...
    'name',         OPT.kmlName,...
    'open',         0,...
    'description',  OPT.description,...
    'lon',          mean([maxlon minlon]),...
    'lat',          mean([maxlat minlat]),...
    'z',            1e4,...
    'timeIn',       min(datenums),...
    'timeOut',      max(datenums));

output = [KML_header(OPT_header) output];

%% COLORBAR

if OPT.colorbar
    clrbarstring = KMLcolorbar('CBcLim',OPT.clim,'CBfileName', fullfile(OPT.outputDir,OPT.outputKml,'KML','colorbar') ,...
        'CBcolorMap',OPT.colorMap,'CBcolorSteps',OPT.colorSteps,'CBcolorbarlocation','W');
    clrbarstring = strrep(clrbarstring,'<Icon><href>colorbar_',['<Icon><href>' [OPT.outputKml filesep 'KML' filesep 'colorbar'] '_']);
    output = [output clrbarstring];
end

%% FOOTER

output = [output KML_footer];
fprintf(OPT2.fid,'%s',output);

%% close KML
fclose(OPT2.fid);
multiWaitbar('fig2png_write_kml' ,1,'label','Writing KML')

%% generate different vversions of the KML
copyfile(fullfile(OPT.outputDir,OPT.outputKml, 'doc.kml'),fullfile(OPT.outputDir, [OPT.outputKml '_localmachine.kml']))
copyfile(fullfile(OPT.outputDir,OPT.outputKml, 'doc.kml'),fullfile(OPT.outputDir, [OPT.outputKml '_server.kml']))
strrep_in_files(fullfile(OPT.outputDir, [OPT.outputKml '_server.kml']),'<href>', ['<href>' OPT.serverURL])
strrep_in_files(fullfile(OPT.outputDir, [OPT.outputKml '_server.kml']),'\', '/')
if OPT.make_kmz
    zip(fullfile(OPT.outputDir, OPT.outputKml), OPT.outputDir)
    movefile(fullfile(OPT.outputDir, [OPT.outputKml '.zip']), fullfile(OPT.outputDir, [OPT.outputKml '_portable.kmz']))
end
delete(fullfile(OPT.outputDir,OPT.outputKml, 'doc.kml'))

disp('generation of kml files completed')

varargout = {OPT};
