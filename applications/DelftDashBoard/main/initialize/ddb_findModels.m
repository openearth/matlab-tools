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
    handles.Model(i).Name=name{i};
    handles.Model(i).LongName=name{i};
    handles.Model(i).CallFcn=str2func(['ddb_select' name{i}]);
    handles.Model(i).IniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Model(i).PlotFcn=str2func(['ddb_plot' name{i}]);
    handles.Model(i).SaveFcn=str2func(['ddb_save' name{i}]);
    handles.Model(i).OpenFcn=str2func(['ddb_open' name{i}]);
    handles.Model(i).ClrFcn=str2func(['ddb_clear' name{i}]);
    handles.Model(i).CoordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
    handles.Model(i).GUI=[];
end

% Set Delft3D-FLOW
ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');
tt=handles.Model;
handles.Model(1)=tt(ii);
k=1;
for i=1:length(handles.Model)
    if ~strcmpi(tt(i).Name,'Delft3DFLOW')
        k=k+1;
        handles.Model(k)=tt(i);
    end
end

for i=1:nt
    f=handles.Model(i).IniFcn;
    handles=f(handles,'veryfirst');
end

% Read xml files
for i=1:nt
    handles=ddb_readModelXML(handles,i);
end

handles.ActiveModel.Name='Delft3DFLOW';
handles.ActiveModel.Nr=1;

setHandles(handles);
