function Initialize(varargin)

recourseDir = 'C:\Inetpub\wwwroot\ZMMatlab\bin\Resources\';
if nargin > 0
    recourseDir = varargin{1};
end

jarFilePath = fullfile(recourseDir,'toolsUI-4.1.jar');

if ~exist(jarFilePath,'file')
    warning('InterpolateToLine:NoJava',['Could not find path to java library: "' jarFilePath '". Try searching for the file']);
    jarFilePath = which('toolsUI-4.1.jar');
    if isempty(jarFilePath)
        error('could not find java library');
    end
end

if ~any(ismember(javaclasspath,jarFilePath))
   javaaddpath(jarFilePath);
end

if ~any(ismember(javaclasspath,jarFilePath))
    error(['Java library was not added', char(10),...
        'At this moment we only know:', char(10),...
        javaclasspath]);
end

setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse

