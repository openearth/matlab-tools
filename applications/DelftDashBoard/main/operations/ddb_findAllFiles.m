function files=ddb_findAllFiles(dr,filterspec)
% Find all files inside directory and sub directories with file extension

files=[];

if strcmpi(dr(end),filesep)
    dr=dr(1:end-1);
end

% All file in this folder
flist=dir([dr filesep filterspec]);
for i=1:length(flist)
    files{i}=[dr filesep flist(i).name];
end

% And the rest of the folders
flist=dir(dr);
for i=1:length(flist)
    filesInFolder=[];
    if isdir([dr filesep flist(i).name])
        switch flist(i).name
            case{'.','..','.svn'}
            otherwise
                filesInFolder=ddb_findAllFiles([dr filesep flist(i).name],filterspec);
        end
    end
    n=length(files);
    nf=length(filesInFolder);
    for j=1:nf
        n=n+1;
        files{n}=filesInFolder{j};
    end    
end
