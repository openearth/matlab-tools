function sct = kmz2struct(inFile,tmpDir)
% reads kmz (and kml as well)
%
%sct = kmz2struct(inFile,tmpDir)
%
% MORE Info in kml2struct
[~,~,ext] = fileparts(inFile);
if strcmpi(ext,'.kmz')
    if nargin == 1
        tmpDir = fileparts(inFile);
    end
    unzip(inFile,tmpDir);
    tmpFile = fullfile(tmpDir,'doc.kml');
    delTmp = 1;
else
    tmpFile = inFile;
    delTmp = 0;
end

sct = kml2struct(tmpFile);

% delete temporary file
if delTmp
    delete(tmpFile);
end