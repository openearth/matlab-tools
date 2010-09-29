function ddb_findToolboxes

handles=getHandles;

if isdeployed
    dr=[ctfroot filesep 'toolboxes'];
else
    ddb_root = fileparts(which('DelftDashBoard.ini'));
    dr=[ddb_root filesep 'toolboxes'];
end

handles.Toolbox(1).Name='dummy';

flist=dir(dr);

k=0;
for i=1:length(flist)
    if flist(i).isdir
        switch lower(flist(i).name)
            case{'.','..','.svn'}
            otherwise
                inifcn=str2func(['ddb_initialize' flist(i).name]);
%                 try
%                     handles=inifcn(handles,'veryfirst');
                    k=k+1;
                    name{k}=flist(i).name;
%                 catch
%                     if ~isdeployed
%                 end
        end
    end
end
nt=k;

for i=1:nt
    handles.Toolbox(i).Name=name{i};
    handles.Toolbox(i).LongName=name{i};
    handles.Toolbox(i).CallFcn=str2func(['ddb_' name{i} 'Toolbox']);
    handles.Toolbox(i).IniFcn=str2func(['ddb_initialize' name{i}]);
    handles.Toolbox(i).PlotFcn=str2func(['ddb_plot' name{i}]);
    handles.Toolbox(i).CoordConvertFcn=str2func(['ddb_coordConvert' name{i}]);
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

for i=1:nt
    f=handles.Toolbox(i).IniFcn;
    handles=f(handles,'veryfirst');
end

handles.activeToolbox.Name='ModelMaker';
handles.activeToolbox.Nr=1;

setHandles(handles);
