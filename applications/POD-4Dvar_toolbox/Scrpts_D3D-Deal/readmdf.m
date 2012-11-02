function [Tokens, allMDF] =readmdf(varargin)
%READMDF Reads the content of MDF files for Delft3D runs. 
%    [allMDF Tokens] = READMDF(mdfFilePath) 'MDFFILEPATH' is a string with 
%    the full path of the mdf file that is going to be read.
%
%    READMDF returns a cells array allMDF with the data without formatting
%    and a second cells array Tokens with the data formatted into three 
%    columns.
    
    if ~size(varargin), error('A path for the mdf file should be provided as an input'), end
    mdfFile = varargin{1};
    
    %Read the File
    if (mdfFile(end-3)~='.'), mdfFile=[mdfFile '.mdf']; end

    disp(['Attempting to open: ',mdfFile]);
    allMDF = textread(mdfFile,'%s','whitespace','','delimiter',char(10));
    
    %Make the Tokens
    for i = 1:1:size(allMDF,1), Tokens(i,:) = {allMDF{i}(1:6),allMDF{i}(7:9),allMDF{i}(9:end)};end