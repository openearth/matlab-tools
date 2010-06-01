function fixedmaps_2_png(inputDir, outputDir, serverURL, EPSGcode, lowestLevel, datatype)
%FIXEDMAPS_2_PNG   make kml files with vaklodingen as georeferenced pngs
%
%See also: jarkusgrids2png, vaklodingen2kml, vaklodingen_overview
if nargin == 0
    inputDir                = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\nc_files\elevation_data\multibeam\';
    outputDir               = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\kml_files\elevation_data\multibeam\';
    EPSGcode                = 28992;
    lowestLevel = 16;
end

figure('Visible','Off')
x = linspace(0,0.01,100);
[x,y] = meshgrid(x,x);
z = kron([10 1;5 1],peaks(50))-rand(100)    ;
h = surf(x,y,z);

hl = light;
%%
material([0.7 0.2 0.15 100]);
%%
shading interp;
lighting phong
axis off;axis tight;view(0,90);lightangle(hl,180,65)
colormap(colormap_cpt('bathymetry_vaklodingen',500));clim([-50 25]);

try
    rmdir(outputDir, 's')
end

% create kml directory if it does not yet exist
if ~exist(outputDir,'dir')
    mkdir(outputDir)
end

EPSG                    = load('EPSG');

url = findAllFiles( ...
    'pattern_excl', {[filesep,'.svn']}, ...
    'pattern_incl', '*.nc', ...
    'basepath', inputDir ...
    );

minlat = nan;
minlon = nan;
maxlat = nan;
maxlon = nan;

for ii = 1:length(url);
    [path, fname] = fileparts(url{ii});
    x    = nc_varget(url{ii},   'x');
    y    = nc_varget(url{ii},   'y');
    time = nc_varget(url{ii},'time');
    
    % expand x and y in each direction to create some overlap
    x = [x(1) + (x(1)-x(2))*.55; x; x(end) + (x(end)-x(end-1))*.55];
    y = [y(1) + (y(1)-y(2))*.55; y; y(end) + (y(end)-y(end-1))*.55];
    
    % coordinates:
    [X,Y] = meshgrid(x,y);
    [lon,lat] = convertCoordinates(X,Y,...
        EPSG,'CS1.code',EPSGcode,'CS2.name','WGS 84','CS2.type','geo');
    
    % convert time to years
    date          = time+datenum(1970,1,1);
    date(end+1,:) = date(end) + 1; %#ok<AGROW>
    
    for jj = size(time,1):-1:1%size(time,1)+1 - min(size(time,1),3)   ;
        fileName = fullfile(outputDir,[datestr(date(jj),29) '.kml']);
        if ~exist(fileName,'file')
            % display progress
            disp([num2str(ii) '/' num2str(length(url)) ' ' fname ' ' datestr(date(jj),29)]);
            % load z data
            z = nc_varget(url{ii},'z',[jj-1,0,0],[1,-1,-1]);
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
                KMLfig2pngNew(h,lat,lon,z,'highestLevel',10,'lowestLevel',lowestLevel,...
                    'timeIn',date(jj),'timeOut',date(jj+1),...
                    'fileName',fileName,'timeFormat','yyyy-mm-dd',...
                    'drawOrder',round(date(jj)),'joinTiles',false,'makeKML',false,'mergeExistingTiles',true);

                minlat = min(minlat,min(lat(:)));
                minlon = min(minlon,min(lon(:)));
                maxlat = max(maxlat,max(lat(:)));
                maxlon = max(maxlon,max(lon(:)));
                
            else
                disp(['data coverage is ' num2str(sum(~isnan(z(:)))/numel(z)*100) '%, no file created'])
            end
        else
            disp([fileName ' already created']);
        end
    end
end

%% join tiles: voeg tiles van verschillende tijdstippen bij elkaar
fns = dir(outputDir);

for ii = 3:length(fns)
    if fns(ii).isdir
        fileName = fullfile(outputDir,[fns(ii).name '.kml']);
        OPT =  KMLfig2pngNew(h,lat,lon,z,'highestLevel',6,'lowestLevel',lowestLevel,...
            'timeIn',datenum(fns(ii).name),'timeOut',datenum(fns(ii).name)+1,...
            'fileName',fileName,'timeFormat','yyyy-mm-dd',...
            'drawOrder',round(datenum(fns(ii).name)),'printTiles',false,'joinTiles',true,'makeKML',false);
    end
end

%% make kml files
OPT.highestLevel  = inf;
OPT.lowestLevel   = lowestLevel;
folderName = datatype;
try %#ok<*TRYNC>
    rmdir([folderName filesep 'KML'], 's')
end

dates = findAllFiles('basepath',outputDir,'recursive',false);
datenums = datenum(dates,'yyyy-mm-dd');

tilefull = findAllFiles('basepath',outputDir,'pattern_incl','*.png');
tilefull2 = tilefull;
for ii = 1:length(tilefull)
    tilefull2{ii} = tilefull2{ii}(end-40:end);
end
    
    
tilefull = findAllFiles('basepath',outputDir,'pattern_incl','*.png');

tiles = cell(size(tilefull));
[path, fname] = fileparts(tilefull{1});
id = strfind(tilefull{1},'_'); id = id(end)-length(path);

for ii = 1:length(tilefull)
    [path, fname] = fileparts(tilefull{ii});
    tiles{ii} = fname(id:end);
    OPT.highestLevel = min(length(tiles{ii}),OPT.highestLevel);
    OPT.lowestLevel  = max(length(tiles{ii}),OPT.lowestLevel);
end
mkdir([outputDir filesep 'KML'])

for level = OPT.highestLevel:OPT.lowestLevel
    tileCodes = nan(length(tiles),level);
    for ii = 1:length(tiles)
        if length(tiles{ii}) == level
            tileCodes(ii,:) = tiles{ii};
        end
    end
    
    tileCodes(any(isnan(tileCodes),2),:) = [];
    tileCodes = char(tileCodes);
    tilesOnLevel = unique(tileCodes(:,1:end),'rows');
    if level == OPT.highestLevel
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
    
    if level == OPT.highestLevel
        minLod = OPT.minLod0;
    else
        minLod = OPT.minLod;
    end
    
    if level == OPT.lowestLevel
        maxLod = OPT.maxLod0;
    else
        maxLod = OPT.maxLod;
    end
    
    for nn = 1:size(tilesOnLevel,1)
        output = '';
        %% add png to kml+
        B = KML_fig2pngNew_code2boundary(tilesOnLevel(nn,:));
        
        for iDate = 1: length(dates)
            pngFile = [dates{iDate} filesep dates{iDate} '_' tilesOnLevel(nn,:) '.png'];
            temp = fullfile(outputDir, pngFile);
            if any(strcmp(temp(end-40:end),tilefull2))
                OPT.timeIn = datenums(iDate);
                OPT.timeOut = OPT.timeIn+1;
                OPT.drawOrder = datenum(iDate);
                
                OPT.timeSpan = sprintf([...
                    '<TimeSpan>\n'...
                    '<begin>%s</begin>\n'...OPT.timeIn
                    '<end>%s</end>\n'...OPT.timeOut
                    '</TimeSpan>\n'],...
                    datestr(OPT.timeIn,OPT.timeFormat),datestr(OPT.timeOut,OPT.timeFormat));
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
                    OPT.drawOrder+level,OPT.timeSpan,...
                    pngFile,...
                    B.N,B.S,B.W,B.E)];
            end
        end
        %% networklinks to children files
        if level ~= OPT.lowestLevel
            %look for children PNG files
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
          
        fid=fopen(fullfile(outputDir,'KML',[tilesOnLevel(nn,:) '.kml']),'w');
        OPT_header = struct(...
            'name',tilesOnLevel(nn,:),...
            'open',0);
        output = [KML_header(OPT_header) output];
        
        % FOOTER
        output = [output KML_footer];
        fprintf(fid,'%s',output);
        
        % close KML
        fclose(fid);
    end
end

%% generate a locally readable kml file
if ~isempty(OPT.url)
    if ~strcmpi(OPT.url(end),'/');
        OPT.url = [OPT.url '\'];
    end
end

OPT.kmlName = datatype;
OPT.description = '';

output = sprintf([...
    '<NetworkLink>'...
    '<name>%s</name>'...                                                                                             % name
    '<Link><href>%s</href><viewRefreshMode>onRegion</viewRefreshMode></Link>'...                                     % link
    '</NetworkLink>'],...
    OPT.kmlName,...
    fullfile(datatype , 'KML', [fileID '.kml']));

OPT.fid=fopen(fullfile(outputDir, 'doc.kml'),'w');
OPT_header = struct(...
    'name',OPT.kmlName,...
    'open',0,...
    'description',OPT.description);

output = [KML_header(OPT_header) output];

%% COLORBAR

if OPT.colorbar
    clrbarstring = KMLcolorbar('CBcLim',clim,'CBfileName', fullfile(outputDir,'KML','colorbar') ,'CBcolorMap',colormap,'CBcolorbarlocation','W');
    clrbarstring = strrep(clrbarstring,'<Icon><href>colorbar_',['<Icon><href>' [datatype filesep 'KML' filesep 'colorbar'] '_']);
    output = [output clrbarstring];
end

%% FOOTER

output = [output KML_footer];
fprintf(OPT.fid,'%s',output);

%% close KML
fclose(OPT.fid);

copyfile(fullfile(outputDir, 'doc.kml'),fullfile(fileparts(outputDir), [datatype '_localmachine.kml']))
copyfile(fullfile(outputDir, 'doc.kml'),fullfile(fileparts(outputDir), [datatype '_server.kml']))
strrep_in_files(fullfile(fileparts(outputDir), [datatype '_server.kml']),'<href>', ['<href>' serverURL])
strrep_in_files(fullfile(fileparts(outputDir), [datatype '_server.kml']),'\', '/')
% zip(fullfile(fileparts(outputDir), datatype), outputDir)
% movefile(fullfile(fileparts(outputDir), [datatype '.zip']), fullfile(fileparts(outputDir), [datatype '.kmz']))
% delete(fullfile(outputDir, 'doc.kml'))



