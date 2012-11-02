function [Tokens, allMOR] =readmor(varargin)
%READMDF Reads the content of MOR files for Delft3D runs. 
%    [allMOR Tokens] = READMOR(morFilePath) 'MORFILEPATH' is a string with 
%    the full path of the mor file that is going to be read.
%
%    READMOR returns a cells array allMOR with the data without formatting
%    and a second cells array Tokens with the data formatted into three 
%    columns.
    
    if ~size(varargin), error('A path for the MOR file should be provided as an input'), end
    morFile = varargin{1};
    
    %Read the File
    
    if (morFile(end-3)~='.'), morFile=[morFile '.mor']; end

    disp(['Attempting to open: ',morFile]);
    allMOR = textread(morFile,'%s','whitespace','','delimiter',char(10));
    
    %Make the Tokens
    for i = 1:1:size(allMOR,1)
        if strcmp(allMOR{i}(1),'[') % Somebody thought it was clever to put subtitles in the file.
            Tokens(i,:) = {allMOR{i},'','',''};
        else
            Tokens(i,:) = {allMOR{i}(1:19),allMOR{i}(21:22),allMOR{i}(23:37),allMOR{i}(38:end)};
        end
    end