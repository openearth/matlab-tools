function OPT = KMLmerge_files(varargin)
%KMLMERGE_FILES   merges all KML files in a certain directory
%
%   KMLmerge_files(<keyword,value>)
%
% Merges all KML files in a certain directory.
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLmerge_files()
%
%See also: googleplot

%% set properties

   OPT.fileName          = '';
   OPT.kmlName           = '';
   OPT.sourceFiles       = {};
   OPT.foldernames       = {}; % TO DO check for existing folder names
   OPT.description       = '';
   OPT.deleteSourceFiles = false;

   [OPT, Set, Default] = setproperty(OPT, varargin{:});
   
   if nargin==0 & nargout==1
       return
   end

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
   
   if ~length(OPT.foldernames)==length(OPT.sourceFiles) & ~isempty(OPT.foldernames)
      error('length of foldernames does ot match number of files.')
   end

%% filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
       [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','merged_files.kmz');
       OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
       [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

%% Write the new file

   fid0=fopen(OPT.fileName,'w');
   OPT_header = struct(...
          'name',OPT.kmlName,...
   'description',OPT.description);
   fprintf(fid0,'%s',KML_header(OPT_header));
   
   for ii = 1:length(OPT.sourceFiles)
   if exist(OPT.sourceFiles{ii})
       contents = textread(OPT.sourceFiles{ii},'%s','delimiter','\n','bufsize',1e6);
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
       if ~isempty(OPT.foldernames)
       fprintf(fid0,'<name>%s</name>',OPT.foldernames{ii});
       end
       fprintf(fid0,'   %s\n',contents{:});
       fprintf(fid0,'%s','</Folder>');
   else
      disp(['Does not exist:',OPT.sourceFiles{ii}])
   end
   end

%% close KML

   fprintf(fid0,'%s',KML_footer);
   fclose(fid0);% close KML

%% delete old files?

   if OPT.deleteSourceFiles
    delete(OPT.sourceFiles{:})
   end

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end
   
%% EOF   

