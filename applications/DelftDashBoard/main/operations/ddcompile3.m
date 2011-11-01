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

% Add models
flist=dir([inipath 'models']);
for j=1:length(flist)
    if flist(j).isdir
        model=flist(j).name;
        % Check if xml file exists and whether model is enabled
        xmlfile=[inipath 'models' filesep model filesep 'xml' filesep model '.xml'];
        if exist(xmlfile,'file')
            xml=xml_load(xmlfile);
            switch lower(xml.enable)
                case{'1','y','yes'}
                    % Model is enabled
                    % Add all m files
                    files=ddb_findAllFiles([inipath 'models' filesep model],'*.m');
                    for i=1:length(files)
                        fprintf(fid,'%s\n',files{i});
                    end
                    % Copy xml files and misc files
                    try
                        mkdir([inipath 'ddbsettings' filesep 'models' filesep model filesep 'xml']);
                        copyfile([inipath 'models' filesep model filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'models' filesep model filesep 'xml']);
                    end
                    try
                        if isdir([inipath 'models' filesep model filesep 'misc'])
                            mkdir([inipath 'ddbsettings' filesep 'models' filesep model filesep 'misc']);
                            copyfiles([inipath 'models' filesep model filesep 'misc'],[inipath 'ddbsettings' filesep 'models' filesep model filesep 'misc']);
                        end
                    end
            end
        end
    end
end

% Add toolboxes
flist=dir([inipath 'toolboxes']);
for j=1:length(flist)
    if flist(j).isdir
        toolbox=flist(j).name;
        % Check if xml file exists and whether toolbox is enabled
        xmlfile=[inipath 'toolboxes' filesep toolbox filesep 'xml' filesep toolbox '.xml'];
        if exist(xmlfile,'file')
            xml=xml_load(xmlfile);
            switch lower(xml.enable)
                case{'1','y','yes'}
                    % Model is enabled
                    files=ddb_findAllFiles([inipath 'toolboxes' filesep toolbox],'*.m');
                    for i=1:length(files)
                        fprintf(fid,'%s\n',files{i});
                    end                    
                    % Copy xml files and misc files
                    try
                        mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                        copyfile([inipath 'toolboxes' filesep toolbox filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                    end
                    try
                        if isdir([inipath 'toolboxes' filesep toolbox filesep 'misc'])
                            mkdir([inipath 'ddbsettings' filesep 'models' filesep toolbox filesep 'misc']);
                            copyfiles([inipath 'toolboxes' filesep toolbox filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
                        end
                    end
            end
        end
    end
end

% Add additional toolboxes
inifile=[inipath 'DelftDashBoard.ini'];
try
    additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
catch
    additionalToolboxDir=[];
end
if ~isempty(additionalToolboxDir)
    % Add toolboxes
    flist=dir(additionalToolboxDir);
    for j=1:length(flist)
        if flist(j).isdir
            toolbox=flist(j).name;
            % Check if xml file exists and whether toolbox is enabled
            xmlfile=[additionalToolboxDir filesep toolbox filesep 'xml' filesep toolbox '.xml'];
            if exist(xmlfile,'file')
                xml=xml_load(xmlfile);
                switch lower(xml.enable)
                    case{'1','y','yes'}
                        % Model is enabled
                        files=ddb_findAllFiles([additionalToolboxDir toolbox],'*.m');
                        for i=1:length(files)
                            fprintf(fid,'%s\n',files{i});
                        end
                        % Copy xml files and misc files
                        try
                            mkdir([inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                            copyfile([additionalToolboxDir filesep toolbox filesep 'xml' filesep '*.xml'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'xml']);
                        end
                        try
                            if isdir([additionalToolboxDir filesep toolbox filesep 'misc'])
                                mkdir([inipath 'ddbsettings' filesep 'models' filesep toolbox filesep 'misc']);
                                copyfiles([additionalToolboxDir filesep toolbox filesep 'misc'],[inipath 'ddbsettings' filesep 'toolboxes' filesep toolbox filesep 'misc']);
                            end
                        end
                end
            end
        end
    end
end

fclose(fid);

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
