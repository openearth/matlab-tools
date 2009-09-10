function KMLmerge_files(varargin)
%
% Merges all KML files in a certain directory
%
%See also: googlePLot

OPT.fileName          = [];
OPT.kmlName           = [];
OPT.sourceFiles       = [];
OPT.deleteSourceFiles = false;

%% set properties
[OPT, Set, Default] = setProperty(OPT, varargin{:});

%% source files
if isempty(OPT.sourceFiles)
    [sourceName,sourcePath] = uigetfile('*.kml','Select KML files to merge','MultiSelect','on');
    if ischar(sourceName)
        OPT.sourceFiles{1} = fullfile(sourcePath,sourceName);
    else
        for ii = 1:length(sourceName)
            OPT.sourceFiles{ii,1} = fullfile(sourcePath,sourceName{ii});
        end
    end
end

%% filename
% gui for filename, if not set yet
if isempty(OPT.fileName)
    [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','movingArrows.kmz');
    OPT.fileName = fullfile(filePath,fileName);
end
% set kmlName if it is not set yet
if isempty(OPT.kmlName)
    [ignore OPT.kmlName] = fileparts(OPT.fileName);
end

%% Write the new file
fid0=fopen(OPT.fileName,'w');
OPT_header = struct(...
    'name',OPT.kmlName);
fprintf(fid0,'%s',KML_header(OPT_header));

for ii = 1:length(OPT.sourceFiles)
    contents = textread(OPT.sourceFiles{ii},'%s','delimiter','\n');
    cutoff = strfind(contents,'Document');
 
    flag = true;
    for jj = 1:length(contents)
        other_flag = true;
        if ~isempty(cutoff{jj})
            contents{jj} = strrep(contents{jj},'<Document>','');
            contents{jj} = strrep(contents{jj},'</Document>','');
            flag = ~flag;
            other_flag = false;
        end
        if flag&&other_flag
            contents{jj} = [];
        end  
    end
    
    fprintf(fid0,'%s','<Folder>');
    fprintf(fid0,'   %s\n',contents{:});
    fprintf(fid0,'%s','</Folder>');
end

% FOOTER
fprintf(fid0,'%s',KML_footer);
% close KML
fclose(fid0);

%% delete old files?
if OPT.deleteSourceFiles
    delete(OPT.sourceFiles{:})
end

%% compress to kmz?
if strcmpi(OPT.fileName(end),'z')
    movefile(OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
    zip(OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
    movefile([OPT.fileName '.zip'],OPT.fileName)
    delete([OPT.fileName(1:end-3) 'kml'])
end

