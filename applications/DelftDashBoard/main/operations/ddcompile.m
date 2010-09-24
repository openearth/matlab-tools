function ddcompile(varargin)

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

statspath='Y:\app\MATLAB2009b\toolbox\stats';
rmpath(statspath);

delete('exe\*');

fid=fopen('complist','wt');

fprintf(fid,'%s\n','-a');

fprintf(fid,'%s\n','DelftDashBoard.m');

exclude = varargin;

% Add models
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            % m files
            f=dir(['models\' flist(i).name '\main\*.m']);
            for j=1:length(f)
                fname=f(j).name;
                switch fname
                    case{'.','..','.svn'}
                    otherwise
                        fprintf(fid,'%s\n',fname);
                end
            end
            % xml files
            f=dir(['models\' flist(i).name '\xml\*.xml']);
            for j=1:length(f)
                fname=f(j).name;
                switch fname
                    case{'.','..','.svn'}
                    otherwise
                        fprintf(fid,'%s\n',fname);
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
            fname=flist(i).name;
            fprintf(fid,'%s\n',['ddb_' fname 'Toolbox.m']);
            fprintf(fid,'%s\n',['ddb_Plot' fname '.m']);
            fprintf(fid,'%s\n',['ddb_initialize' fname '.m']);
    end
end

% Add model specific toolbox functions
flist=dir('models');
for i=1:length(flist)
    switch flist(i).name
        case{'.','..','.svn'}
        case exclude
        otherwise
            flist2=dir(['models\' flist(i).name '\toolbox\']);
            for ij=1:length(flist2)
                switch flist2(ij).name
                    case{'.','..','.svn'}
                    case exclude
                    otherwise
                        f=dir(['models\' flist(i).name '\toolbox\' flist2(ij).name '\*.m']);
                        for j=1:length(f)
                            fname=f(j).name;
                            switch fname
                                case{'.','..','.svn'}
                                otherwise
                                    fprintf(fid,'%s\n',fname);
                            end
                        end
                end
            end
    end
end

fclose(fid);

try
    fid=fopen('earthicon.rc','wt');
    fprintf(fid,'%s\n','ConApp ICON settings\icons\Earth-icon32x32.ico');
    fclose(fid);
    system(['"' matlabroot '\sys\lcc\bin\lrc" /i "' pwd '\earthicon.rc"']);
end

mcc -m -d exe DelftDashBoard.m -B complist -a settings -a ..\..\io\netcdf\toolsUI-4.1.jar -M earthicon.res

% make about.txt file
Revision = '$Revision$';
eval([strrep(Revision(Revision~='$'),':','=') ';']);

dos(['copy ' fileparts(which('ddsettings')) '\main\menu\ddb_aboutDelftDashBoard.txt ' fileparts(which('ddsettings')) filesep 'exe']);
strfrep(fullfile(fileparts(which('ddsettings')),'exe','ddb_aboutDelftDashBoard.txt'),'$revision',num2str(Revision));


delete('complist');
delete('earthicon.rc');
delete('earthicon.res');
