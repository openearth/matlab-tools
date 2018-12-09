function typeOfModelFile=EHY_getTypeOfModelFile(fileInp)
%% typeOfModelFile=EHY_getTypeOfModelFile(filename)
%
% This function returns the typeOfModelFile based on a filename
% typeOfModelFile can be:
% grid
% network
% mdFile
% outputfile
%
% Example1: 	typeOfModelFile=EHY_getTypeOfModelFile('D:\model.mdu')
% Example2: 	typeOfModelFile=EHY_getTypeOfModelFile('D:\model.obs')
% Example3: 	typeOfModelFile=EHY_getTypeOfModelFile('D:\trih-r01.dat')
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if nargin==0 % no input was given
    disp('Open a file')
    [fileInp, pathname]=uigetfile('*.*','Open a file');
    if isnumeric(fileInp); disp('EHY_getTypeOfModelFile stopped by user.'); return; end
    fileInp=[pathname fileInp];
end

%%
[pathstr, name, ext] = fileparts(lower(fileInp));
typeOfModelFile='';

% grid
if isempty(typeOfModelFile)
    if ismember(ext,'.grd')
        typeOfModelFile = 'grid';
    end
end

% network
if isempty(typeOfModelFile)
    if ~isempty(strfind([name ext],'_net.nc'))
        typeOfModelFile = 'network';
    end
end

% mdFile
if isempty(typeOfModelFile)
    if ismember(ext,{'.mdu','.mdf'}) || ~isempty(strfind([name ext],'siminp'))
        typeOfModelFile = 'mdFile';
    end
end

% outputfile
if isempty(typeOfModelFile)
    if ~isempty(strfind([name ext],'_his.nc'))  || ~isempty(strfind([name ext],'_map.nc')) || ...
            ~isempty(strfind([name ext],'trih-'))  || ~isempty(strfind([name ext],'trim-')) || ...
            ~isempty(strfind([name],'sds')) || ~isempty(strfind([name ext],'_fou.nc')) || ...
             ~isempty(strfind([name ext],'_waqgeom.nc')) 
        typeOfModelFile = 'outputfile';
    end
end
