function handles=ddb_findToolboxes(handles)

if isdeployed
    dr=[fileparts(which('DelftDashBoard.m')) filesep];
    dr=[dr(1:end-39) filesep 'bin' filesep 'DelftDashBoard_mcr' filesep 'toolboxes'];
else
    dr='toolboxes';
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
