function ddb_findToolboxes

handles=getHandles;

if isdeployed
    dr=[ctfroot filesep 'toolboxes'];
else
    ddb_root = fileparts(which('DelftDashBoard.ini'));
    dr=[ddb_root filesep 'toolboxes'];
end

handles.Toolbox(1).name='dummy';

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
end

% Set names and functions
nt=k;
for i=1:nt
    handles.Toolbox(i).name=name{i};
    handles.Toolbox(i).longName=name{i};
    handles.Toolbox(i).callFcn=str2func(['ddb_' name{i} 'Toolbox']);
    handles.Toolbox(i).iniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Toolbox(i).plotFcn=str2func(['ddb_plot' name{i}]);
    handles.Toolbox(i).coordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
%     if isdeployed
%         % Executable
%         if strcmpi(tp{i},'standard')
%             handles.Toolbox(i).dir=[dr filesep name{i} filesep];
%             handles.Toolbox(i).xmlDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'xml' filesep];
%             handles.Toolbox(i).miscDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'misc' filesep];
%             handles.Toolbox(i).dataDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep];
%         else
%             handles.Toolbox(i).dir=[dr2 filesep name{i} filesep];
%             handles.Toolbox(i).xmlDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'xml' filesep];
%             handles.Toolbox(i).miscDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep 'misc' filesep];
%             handles.Toolbox(i).dataDir=[handles.settingsDir filesep 'toolboxes' filesep name{i} filesep];
%         end
%     else
%         % From Matlab
        if strcmpi(tp{i},'standard')
            handles.Toolbox(i).dir=[dr filesep name{i} filesep];
            handles.Toolbox(i).xmlDir=[handles.Toolbox(i).dir 'xml' filesep];
            handles.Toolbox(i).miscDir=[handles.Toolbox(i).dir 'misc' filesep];
            handles.Toolbox(i).dataDir=[handles.toolBoxDir name{i} filesep];
        else
            handles.Toolbox(i).dir=[dr2 filesep name{i} filesep];
            handles.Toolbox(i).xmlDir=[handles.Toolbox(i).dir 'xml' filesep];
            handles.Toolbox(i).miscDir=[handles.Toolbox(i).dir 'misc' filesep];
            handles.Toolbox(i).dataDir=[handles.toolBoxDir name{i} filesep];
        end
%     end
end

% Set ModelMaker to be the first toolbox
ii=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');
tt=handles.Toolbox;
handles.Toolbox(1)=tt(ii);
k=1;
for i=1:length(handles.Toolbox)
    if ~strcmpi(tt(i).name,'ModelMaker')
        k=k+1;
        handles.Toolbox(k)=tt(i);
    end
end

% % Run very first initialize function
% for i=1:nt
%     f=handles.Toolbox(i).iniFcn;
%     handles=f(handles,'veryfirst');
% end

% Read xml files
for i=1:nt
    handles=ddb_readToolboxXML(handles,i);
end

handles.activeToolbox.name='ModelMaker';
handles.activeToolbox.nr=1;

setHandles(handles);
