function cosmos_moveDataXBeach(hm,m)

rundir=[hm.JobDir hm.Models(m).Name  filesep ];

delete([rundir '*.exe']);
delete([rundir 'run.bat']);

dr=hm.Models(m).Dir;
inpdir=[dr 'lastrun' filesep 'input' filesep];
outdir=[dr 'lastrun' filesep 'output' filesep];

[status,message,messageid]=movefile([rundir hm.Models(m).Runid '*.sp2'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'params.txt'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'x.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'y.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'xbeach.tim'],inpdir,'f');
[status,message,messageid]=movefile([rundir 't.t'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.dep'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'RF_table.txt'],inpdir,'f');

delete([rundir '*.sp2']);

[status,message,messageid]=movefile([rundir '*'],outdir,'f');
