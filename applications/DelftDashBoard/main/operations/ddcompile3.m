function ddcompile3(varargin)

% To exclude models or toolboxes in the compiled program, use:
% ddcompile('model1','model2','toolbox1') with model1, model2 and toolbox the models/toolboxes to exclude.

% exclude={''};
%
% for i=1:length(varargin)
%     switch lower(varargin{i})
%         case{'exclude'}
%             if ~iscell(varargin{i+1})
%                 exclude={varargin{i+1}};
%             else
%                 exclude=varargin{i+1};
%             end
%     end
% end

inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

mkdir('exe\data');
mkdir('exe\bin');

statspath='Y:\app\MATLAB2009b\toolbox\stats';
rmpath(statspath);

delete('exe\*');

fid=fopen([inipath 'complist'],'wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

exclude = varargin;

% Add models
files=ddb_findAllFiles([inipath 'models'],'*.m');
for i=1:length(files)
    fprintf(fid,'%s\n',files{i});
end

% Add toolboxes
files=ddb_findAllFiles([inipath 'toolboxes'],'*.m');
for i=1:length(files)
    fprintf(fid,'%s\n',files{i});
end

% Add additional toolboxes
inifile=[inipath 'DelftDashBoard.ini'];
try
    additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
catch
    additionalToolboxDir=[];
end
if ~isempty(additionalToolboxDir)
    files=ddb_findAllFiles(additionalToolboxDir,'*.m');
    for i=1:length(files)
        fprintf(fid,'%s\n',files{i});
    end
end

fclose(fid);

% Make directory for compiled settings
mkdir([inipath 'ddbsettings']);
flist=dir([inipath 'settings']);
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            mkdir([inipath 'ddbsettings' filesep flist(i).name]);
            copyfiles([inipath 'settings' filesep flist(i).name],[inipath 'ddbsettings' filesep flist(i).name]);
    end
end

mkdir([inipath 'ddbsettings' filesep 'models' filesep 'xml']);
mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep 'xml']);

%% Copy xml and misc files
% Models
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            try
                mkdir([inipath 'ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
                copyfile([inipath 'models' filesep flist(i).name filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir([inipath 'models' filesep flist(i).name filesep 'misc'])
                    mkdir([inipath 'ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
                    copyfiles([inipath 'models' filesep flist(i).name filesep 'misc'],[inipath 'ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
                end
            end
    end
end

% Toolboxes
flist=dir('toolboxes');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            try
                mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
                copyfile([inipath 'toolboxes' filesep flist(i).name filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir([inipath 'toolboxes' filesep flist(i).name filesep 'misc'])
                    mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                    copyfiles([inipath 'toolboxes' filesep flist(i).name filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                end
            end
    end
end
if ~isempty(additionalToolboxDir)
    flist=dir(additionalToolboxDir);
    for i=1:length(flist)
        switch flist(i).name
            case{'.','..','.svn'}
            otherwise
                try
                    mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
                    copyfile([additionalToolboxDir filesep flist(i).name filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
                end
                try
                    if isdir([additionalToolboxDir filesep flist(i).name filesep 'misc'])
                        mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                        copyfiles([additionalToolboxDir filesep flist(i).name filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                    end
                end
        end
    end
end

%% Include icon
try
    fid=fopen('earthicon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON settings\icons\Earth-icon32x32.ico');
    fclose(fid);
    system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd '\earthicon.rc"']);
end

%% Generate data folder in exe folder
ddb_copyAllFilesToDataFolder(inipath,[inipath filesep 'exe' filesep 'data' filesep],additionalToolboxDir);

mcc -m -v -d exe\bin DelftDashBoard.m -B complist -a ddbsettings -a ..\..\io\netcdf\toolsUI-4.1.jar -M earthicon.res

% make about.txt file
Revision = '$Revision$';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

dos(['copy ' fileparts(which('ddsettings')) '\main\menu\ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));

delete('complist');
delete('earthicon.rc');
delete('earthicon.res');

rmdir('ddbsettings','s');
