function [Tokens, allmdw] =readmdw(varargin)
%READMDF Reads the content of MOR files for Delft3D runs. 
%    [allMOR Tokens] = READMOR(morFilePath) 'MORFILEPATH' is a string with 
%    the full path of the mor file that is going to be read.
%
%    READMOR returns a cells array allMOR with the data without formatting
%    and a second cells array Tokens with the data formatted into three 
%    columns.
    
    if ~size(varargin), error('A path for the mdw file should be provided as an input'), end
    mdwFile = varargin{1};
    
    %Read the File
    
    if (mdwFile(end-3)~='.'), mdwFile=[mdwFile '.mdw']; end

    disp(['Attempting to open: ',mdwFile]);
    allmdw = textread(mdwFile,'%s','whitespace','','delimiter',char(10));
    
    %Make the Tokens
    for i = 1:1:size(allmdw,1)
        if strcmp(allmdw{i}(1),'[') % Somebody though it was clever to put subtitles in the file.
            Tokens(i,:) = {allmdw{i},'',''};
        else
            Tokens(i,:) = {allmdw{i}(1:24),allmdw{i}(25:26),allmdw{i}(27:end)};
        end
    end