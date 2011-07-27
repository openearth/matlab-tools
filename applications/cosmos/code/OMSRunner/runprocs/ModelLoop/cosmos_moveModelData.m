function cosmos_moveModelData(hm,m)

dr=hm.Models(m).Dir;

MakeDir(dr,'lastrun');

switch lower(hm.Models(m).Type)
    case{'delft3dflow','delft3dflowwave','ww3','xbeach'}
        
        [status,message,messageid]=rmdir([dr 'lastrun' filesep 'input'],'s');
        [status,message,messageid]=rmdir([dr 'lastrun' filesep 'output'],'s');
        [status,message,messageid]=rmdir([dr 'lastrun' filesep 'figures'],'s');
        
        delete([dr 'lastrun' filesep 'input' filesep '*']);
        delete([dr 'lastrun' filesep 'output' filesep '*']);
        delete([dr 'lastrun' filesep 'figures' filesep '*']);
        
        MakeDir(dr,'restart');
end

MakeDir(dr,'lastrun','input');
MakeDir(dr,'lastrun','output');
MakeDir(dr,'lastrun','figures');

switch lower(hm.Models(m).Type)
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

[status,message,messageid]=rmdir([hm.JobDir hm.Models(m).Name], 's');
