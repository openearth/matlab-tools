function cosmos_moveModelData(hm,m)


model=hm.models(m);
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];
dr=model.dir;

mkdir(cycledir);

switch lower(model.type)
    case{'delft3dflow','delft3dflowwave','ww3','xbeach'}
        
        [status,message,messageid]=rmdir([cycledir 'input'],'s');
        [status,message,messageid]=rmdir([cycledir 'output'],'s');
        [status,message,messageid]=rmdir([cycledir 'figures'],'s');
        
        delete([cycledir 'input' filesep '*']);
        delete([cycledir 'output' filesep '*']);
        delete([cycledir 'figures' filesep '*']);
        
        MakeDir(dr,'restart');
end

MakeDir(cycledir,'input');
MakeDir(cycledir,'output');
MakeDir(cycledir,'figures');

switch lower(model.type)
    case{'delft3dflow','delft3dflowwave'}
        MakeDir(dr,'restart','hot');
        MakeDir(dr,'restart','tri-rst');
        cosmos_moveDataDelft3D(hm,m);
    case{'ww3'}
        cosmos_moveDataWW3(hm,m);
    case{'xbeach'}
        cosmos_moveDataXBeach(hm,m);
    case{'xbeachcluster'}
        cosmos_moveDataXBeachCluster(hm,m);
end

[status,message,messageid]=rmdir([hm.jobDir model.name], 's');
