function ddcompile2(varargin)

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

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

exclude = varargin;

% Add models
flist=dir([inipath 'models']);
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            % m files
            flist2=dir([inipath 'models' filesep flist(i).name filesep '*']);
            for j=1:length(flist2)
                switch flist2(j).name
                    case{'.','..','.svn'}
                    case exclude
                    otherwise
                        if strcmpi(flist2(j).name,'toolbox')
                            flist3=dir([inipath 'models' filesep flist(i).name filesep 'toolbox']);
                            for n=1:length(flist3)
                                switch flist3(n).name
                                    case{'.','..','.svn'}
                                    case exclude
                                    otherwise
                                        f=dir(['models' filesep flist(i).name filesep 'toolbox' filesep flist3(n).name filesep '*.m']);
                                        for k=1:length(f)
                                            fname=f(k).name;
                                            fprintf(fid,'%s\n',fname);
                                        end
                                end
                            end
                        else
                            f=dir(['models' filesep flist(i).name filesep flist2(j).name filesep '*.m']);
                            for k=1:length(f)
                                fname=f(k).name;
                                fprintf(fid,'%s\n',fname);
                            end
                        end
                end
            end
    end
end

% Add toolboxes
flist=dir('toolboxes');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            flist2=dir(['toolboxes' filesep flist(i).name filesep '*.m']);
            for j=1:length(flist2)
                fname=flist2(j).name;
                fprintf(fid,'%s\n',fname);
            end
    end
end

fclose(fid);

% Make directory for compiled settings
mkdir('ddbsettings');
flist=dir('settings');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            mkdir(['ddbsettings' filesep flist(i).name]);
            copyfiles(['settings' filesep flist(i).name],['ddbsettings' filesep flist(i).name]);
    end
end

mkdir(['ddbsettings' filesep 'models' filesep 'xml']);
mkdir(['ddbsettings' filesep 'toolboxes' filesep 'xml']);

%% Copy xml files

% Models
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        otherwise
            try
                mkdir(['ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
                copyfile(['models' filesep flist(i).name filesep 'xml' filesep '*.xml'],['ddbsettings' filesep 'models' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir(['models' filesep flist(i).name filesep 'misc'])
                    mkdir(['ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
                    copyfiles(['models' filesep flist(i).name filesep 'misc'],['ddbsettings' filesep 'models' filesep flist(i).name filesep 'misc']);
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
                mkdir(['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
                copyfile(['toolboxes' filesep flist(i).name filesep 'xml' filesep '*.xml'],['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'xml']);
            end
            try
                if isdir(['toolboxes' filesep flist(i).name filesep 'misc'])
                    mkdir(['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
                    copyfiles(['toolboxes' filesep flist(i).name filesep 'misc'],['ddbsettings' filesep 'toolboxes' filesep flist(i).name filesep 'misc']);
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


mkdir('exe\data');
inipath=

ddb_copyAllFilesToDataFolder(inipath,ddbdir,additionalToolboxDir);


mcc -m -v -d exe DelftDashBoard.m -B complist -a ddbsettings -a ..\..\io\netcdf\toolsUI-4.1.jar -M earthicon.res

% make about.txt file
Revision = '$Revision$';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

dos(['copy ' fileparts(which('ddsettings')) '\main\menu\ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));

delete('complist');
delete('earthicon.rc');
delete('earthicon.res');

rmdir('ddbsettings','s');
