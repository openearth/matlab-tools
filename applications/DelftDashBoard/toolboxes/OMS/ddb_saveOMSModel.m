function ddb_saveOMSModel(handles)

dr=[handles.Toolbox(tb).Directory '\'];

if ~exist([dr handles.Toolbox(tb).ShortName],'dir')
    mkdir(dr,handles.Toolbox(tb).ShortName);
end

dr=[dr handles.Toolbox(tb).ShortName '\'];

if ~exist([dr 'input'],'dir')
    mkdir(dr,'input');
end
if ~exist([dr 'nesting'],'dir')
    mkdir(dr,'nesting');
end
if ~exist([dr 'lastrun'],'dir')
    mkdir(dr,'lastrun');
end
if ~exist([dr 'archive'],'dir')
    mkdir(dr,'archive');
end
if ~exist([dr 'restart'],'dir')
    mkdir(dr,'restart');
end

ddb_saveOMSModelData(handles);

ddb_saveMDFOMS(handles,ad);

if handles.Model(md).Input(ad).Waves
    ddb_saveMDWOMS(handles);
end

inpdir=[dr 'input\'];

name=handles.Toolbox(tb).ShortName;
% try
%     copyfile([handles.Toolbox(tb).Runid '.mdf'],inpdir);
% end
% try
%     copyfile([handles.Toolbox(tb).Runid '.mdw'],inpdir);
% end

extensions={'bnd','bch','bca','grd','enc','dep','dry','thd','ini'};

for i=1:length(extensions)
    try
        copyfile([name '.' extensions{i}],inpdir);
    end
end

if handles.Model(md).Input(ad).Waves
    ddb_writeDioConfig(inpdir);
end

if handles.Model(md).Input(ad).Wind
    fid=fopen([inpdir 'dummy.wnd'],'wt');
    fprintf(fid,'%s\n',' 0.0000000e+000  0.0000000e+000  0.0000000e+000');
    fprintf(fid,'%s\n',' 2.0000000e+006  0.0000000e+000  0.0000000e+000');
    fclose(fid);
end
