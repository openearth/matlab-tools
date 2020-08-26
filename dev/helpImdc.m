function helpImdc(aFile,outputFile)
% gives help messages for the library
% INPUT: aFile (optional): the filename or path for which help information should
% be printed. In case of a filename, all functions in that file are printed, in case of a path, all functions in all files are printed.
% In case no input argument is given. Info is printed for all
% files.
%  :   outputFile(optional): an output file where the info is put in the
%  format of the wiki

% open file for wiki


% see whether an input argument is given
if nargin ==  2
    fid  = fopen(outputFile,'w');
else
    fid = -1;
end

if nargin == 1
    if isdir(aFile)
        fileLoop(fid,aFile);
    else
        printHelp(fid,aFile);
    end
elseif nargin >2
    error('Wrong number of input arguments');
else
    % loop over all directories
    dirs = dir('*');
    for iDir = 3:length(dirs)
        theDir = dirs(iDir).name;
        if isdir(theDir)
            fileLoop(fid,theDir);
        end
    end
end

if fid >= 0
    fclose(fid);
end


function fileLoop(fid,theDir)
% loop over all files
files = dir(fullfile(theDir,'*.m'));
for iFile = 1:length(files)
    %determine function info
    theFile = fullfile(theDir,files(iFile).name);
    if fid>=0 && iFile==1
        fprintf(fid,'%s\n',['* ',theDir]);
    end
    printHelp(fid,theFile);
end


function printHelp(fid,theFile)
% prints all H1 information from a file to the screen

% constants
FUNC_LEN = 20;

% get info from a file
H1 = getH1(theFile);

if fid <0
    % write to screen
    disp filename
    disp('*****************************************');
    disp(theFile);
    disp('*****************************************');
    disp('');
    disp('');
    % display info
    for i=1:length(H1);
        disp(H1{i});
    end
    disp('');
    disp('');
else
    [~,theFile] = fileparts(theFile);
    fprintf(fid,'%s\n',['** ',theFile]);
    for i=1:length(H1);
        fprintf(fid,'%s\n',['*** ''''''',H1{i}(1:FUNC_LEN),'''''''',H1{i}(FUNC_LEN+1:end)]);
    end
end



function H1 = getH1(mFile)
% get H1 documentation form an m file

% constants
FUNC_LEN = 20;

H1 = {};

% open the file
fid = fopen(mFile);

if fid<0
    error(['File ' ,mFile, ' cannot be opened to process.']);
end

iFunction = 1;

% read each line in the file
aLine = fgetl(fid);
while ischar(aLine);
    % find function header
    aLine = strtrim(aLine);
    trimLine = strtrim(aLine);
    nrFunction = strfind(trimLine,'function');
    if ~isempty(nrFunction) && nrFunction(1)==1 && trimLine(9) == ' '
        % find function name
        nrIs = strfind(aLine,'=');
        if isempty(nrIs)
            nrIs = nrFunction(1)+8;
        end
        nrPar = strfind(aLine,'(');
        if isempty(nrPar)
            nrPar = length(aLine)+1;
        end
        functionName = aLine(nrIs+1:nrPar-1);
        
        % read following line
        aLine = fgetl(fid);
        nrPerc = strfind(aLine,'%');
        if ~isempty(nrPerc)
            descr = aLine(nrPerc+1:end);
        else
            descr = '';
        end
        % compose the string
        nrBlank = max(FUNC_LEN - length(functionName),0);
        H1{iFunction} = [functionName, blanks(nrBlank) , ' - ',descr];
        
        iFunction = iFunction + 1;
    end
    % continue
    aLine = fgetl(fid);
end

fclose(fid);
