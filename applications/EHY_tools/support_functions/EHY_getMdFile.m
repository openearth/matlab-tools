function mdFile=EHY_getMdFile(filename)
%% modelType=EHY_getMdFile(filename)
%
% This function returns the filename of the mdFile (master definition file)
% based on a filename/filename. Possibile mdFiles: .mdu / .mdf / siminp
%
% Example1: 	mdFile=EHY_getMdFile('D:\run01\')
% Example2: 	mdFile=EHY_getMdFile('D:\run01\r01.ext')
% Example3: 	mdFile=EHY_getMdFile('D:\run01\DFM_OUTPUT_r01\trih-r01.dat')
% All examples would return: mdFile = 'D:\run01\r01.mdu'
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if nargin==0 % no input was given
    disp('Open a file')
    [filename, pathname]=uigetfile('*.*','Open a file');
    if isnumeric(filename); disp('EHY_getMdFile stopped by user.'); return; end
    filename=[pathname filename];
end

%%
loop=3;
while loop>0
    loop=loop-1;
    %% determine mdFile
    % the mdFile itself was given
    [pathstr, name, ext] = fileparts(filename);
    if isempty(pathstr)
        filename=[pwd filesep name ext];
    end
    if ismember(ext,{'.mdu','.mdf'}) || ~isempty(strfind(lower(name),'siminp'))
        mdFile=filename;
    end
    
    % the run directory was given
    if ~exist('mdFile','var')
        mdFiles=[dir([filename filesep '*.mdu']); dir([filename filesep '*.mdf']); dir([filename filesep '*siminp*'])];
       
        % remove partitioned .mdu-files
        ind=find(~cellfun(@isempty,strfind({mdFiles.name},'.mdu')));
        if ~isempty(ind)
            deleteInd=[];
            for iF=1:length(mdFiles)
                if length(mdFiles(iF).name)>9 && all(ismember(mdFiles(iF).name(end-7:end-4),'0123456789'))
                    deleteInd(end+1)=iF;
                end
            end
            mdFiles(deleteInd)=[];
        end
        
        if ~isempty(mdFiles)
            [~,order] = sort([mdFiles.datenum]);
            mdFile=fullfile([filename filesep mdFiles(order(end)).name]); % use most recent
            if length(order)>1
                disp(['More than 1 mdf/mdu/siminp-file was found, now using ''' mdFiles(order(1)).name ''''])
            end
        end
    end
    
    % output file was given, try to get runid and mdFile
    if ~exist('mdFile','var') % dflowfm
        [~,name,ext]=fileparts(filename);
        fName=[name ext];
        id=strfind(fName,'_his.nc');
        runid=fName(1:id-1);
        if length(runid)>5 && ~isempty(str2num(runid(end-3:end))) && strcmp(runid(end-4),'_')
            runid=runid(1:end-5); % skip partitioning part
        end
        if ~isempty(runid)
            mdFiles=dir([fileparts(fileparts(filename)) filesep '*' runid '.mdu']);
            if length(mdFiles)==1
                mdFile=[fileparts(fileparts(filename)) filesep runid '.mdu'];
            end
        end
    end
    if ~exist('mdFile','var') % delft3d4
        id1=strfind(fName,'trih-');
        id2=strfind(fName,'.dat');
        runid=fName(id1+5:id2-1);
        if ~isempty(runid)
            mdFiles=dir([fileparts(filename) filesep '*' runid '.mdf']);
            if length(mdFiles)==1
                mdFile=[fileparts(filename) filesep runid '.mdf'];
            end
        end
    end
    
    % file in the run directory was given
    if ~exist('mdFile','var')
        filename=fileparts(filename);
    end
end

if ~exist('mdFile','var')
    disp('<strong>Could not determine mdFile</strong>')
    mdFile='';
end

