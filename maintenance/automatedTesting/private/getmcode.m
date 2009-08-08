function textCellArray = getmcode(filename, bufferSize)
%GETMCODE  Returns a cell array of the text in a file
%   textCellArray = getmcode(filename)
%   textCellArray = getmcode(filename, bufferSize)
% Throws an error if the file is binary (specifically,
% contains bytes with value zero).

% Copyright 1984-2007 The MathWorks, Inc.

if nargin < 2
    bufferSize = 30000;
end

fid = fopen(filename,'r');
if fid < 0
    error('MATLAB:codetools:fileReadError','Unable to read file %s', filename)
end
% Now check for bytes with value zero.  For performance reasons,
% scan a maximum of 10,000 bytes.  Prevent any "interpretation"
% of data by reading uint8s and keeping them in that form.
data = fread(fid,10000,'uint8=>uint8');
isbinary = any(data==0);
if isbinary
    fclose(fid);
    error('MATLAB:codetools:getmcode',...
        'File contains binary data: %s',filename);
end
% No binary data found.  Reset the file pointer to the beginning of
% the file and scan the text.
fseek(fid,0,'bof');
txt = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',bufferSize);
fclose(fid);

textCellArray = txt{1};
