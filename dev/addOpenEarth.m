function addOpenEarth(openEarthPath)
% add OpenEarth to your path
%
% addOpenEarth(openEarthPath)
%
% INPUT: openEarthPath (optional).  Default 's:\FREE\OpenEarth\trunk\matlab'
%
if nargin  < 1
    openEarthPath = 's:\FREE\OpenEarth\trunk\matlab';
end
if ~exist('convertCoordinates','file')
    
    thePath = pwd;
    cd(openEarthPath) ;
    addpathfast(openEarthPath,'patterns',{'.mexnc','.nctools',[filesep,'.svn']});
    cd(thePath)
else
    disp('Open Earth is already in the path');
end