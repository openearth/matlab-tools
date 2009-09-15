function outargs = argsinname(fname)

%% process filename
if ischar(fname)
    %% extract function name
    fname = which(fname);
    [pt fn ext] = fileparts(fname);
    if ~strcmp(ext,'.m')
        error('ArgOut:NoMFile','Function should be an mfile');
    end
    %% open file
    fid = fopen(fname);
    if fid==-1
        error('ArgOut:WrongFilename','File could not be found');
    end
else
    error('ArgOut:WrongFilename','Input must be a filename');
end

%% read file contents
str = fread(fid,'*char')';
fclose(fid);

%% find function call (usually at position 1)
id = min(strfind(str,'function'));
if isempty(id)
    disp('No function call');
end

%% remove all strings before the function call
str = strtrim(str(id+8:end));

%% fund function name in call
fnid = strfind(str,fn);

%% output arguments
outargs = [];
if ~isempty(strfind(str(1:fnid),'='))
    % There is output defined
    outargstemp = strtrim(strread(strrep(strrep(strtrim(str(1:min(strfind(str(1:fnid),'='))-1)),'[',''),']',''),'%s',-1,'delimiter',','));
    
    for iargs = 1:length(outargstemp)
        outargs = cat(1,outargs,strtrim(strread(outargstemp{iargs},'%s',-1,'delimiter',' ')));
    end
end