function ddb_findModels

handles=getHandles;

if isdeployed
    dr=[ctfroot filesep 'models'];
else
    ddb_root = fileparts(which('DelftDashBoard.ini'));
    dr=[ddb_root filesep 'models'];
end

flist=dir(dr);

k=0;
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                k=k+1;
                name{k}=flist(i).name;
        end
    end
end
nt=k;

for i=1:nt
    handles.Model(i).dir=[dr filesep name{i} filesep];
    handles.Model(i).name=name{i};
    handles.Model(i).longName=name{i};
    handles.Model(i).iniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Model(i).plotFcn=str2func(['ddb_plot' name{i}]);
    handles.Model(i).saveFcn=str2func(['ddb_save' name{i}]);
    handles.Model(i).openFcn=str2func(['ddb_open' name{i}]);
    handles.Model(i).clrFcn=str2func(['ddb_clear' name{i}]);
    handles.Model(i).coordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    handles.Model(i).GUI=[];
end

% Set Delft3D-FLOW
ii=strmatch('Delft3DFLOW',{handles.Model.name},'exact');
tt=handles.Model;
handles.Model(1)=tt(ii);
k=1;
for i=1:length(handles.Model)
    if ~strcmpi(tt(i).name,'Delft3DFLOW')
        k=k+1;
        handles.Model(k)=tt(i);
    end
end

for i=1:nt
    f=handles.Model(i).iniFcn;
    handles=f(handles,'veryfirst');
end

% Read xml files
for i=1:nt
    handles=ddb_readModelXML(handles,i);
end

handles.activeModel.name='Delft3DFLOW';
handles.activeModel.nr=1;

setHandles(handles);
