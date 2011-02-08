function ddb_findToolboxes

handles=getHandles;

if isdeployed
    dr=[ctfroot filesep 'toolboxes'];
else
    ddb_root = fileparts(which('DelftDashBoard.ini'));
    dr=[ddb_root filesep 'toolboxes'];
end

handles.Toolbox(1).Name='dummy';


% Find standard toolboxes
flist=dir(dr);
k=0;
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                k=k+1;
                name{k}=flist(i).name;
                tp{k}='standard';
        end
    end
end

% Find additional toolboxes
dr2=handles.additionalToolboxDir;
if ~isempty(dr2)
    addpath(genpath(dr2));
end
flist=dir(dr2);
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                k=k+1;
                name{k}=flist(i).name;
                tp{k}='additional';
        end
    end
end

% Set names and functions
nt=k;
for i=1:nt
    handles.Toolbox(i).Name=name{i};
    handles.Toolbox(i).LongName=name{i};
    handles.Toolbox(i).CallFcn=str2func(['ddb_' name{i} 'Toolbox']);
    handles.Toolbox(i).IniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Toolbox(i).PlotFcn=str2func(['ddb_plot' name{i}]);
    handles.Toolbox(i).CoordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    if strcmpi(tp{i},'standard')
        handles.Toolbox(i).Dir=[dr filesep name{i}];
    else
        handles.Toolbox(i).Dir=[dr2 filesep name{i}];
    end
end

% Set ModelMaker to be the first toolbox
ii=strmatch('ModelMaker',{handles.Toolbox(:).Name},'exact');
tt=handles.Toolbox;
handles.Toolbox(1)=tt(ii);
k=1;
for i=1:length(handles.Toolbox)
    if ~strcmpi(tt(i).Name,'ModelMaker')
        k=k+1;
        handles.Toolbox(k)=tt(i);
    end
end

% Run very first initialize function
for i=1:nt
    f=handles.Toolbox(i).IniFcn;
    handles=f(handles,'veryfirst');
end

% Read xml files
for i=1:nt
    handles=ddb_readToolboxXML(handles,i);
end

handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;

setHandles(handles);
