function cosmos_moveDataXBeach(hm,m)

rundir=[hm.jobDir hm.models(m).name  filesep ];

delete([rundir '*.exe']);
delete([rundir 'run.bat']);

archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];

inpdir=[cycledir 'input' filesep];
outdir=[cycledir 'output' filesep];

[status,message,messageid]=movefile([rundir hm.models(m).runid '*.sp2'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'params.txt'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'x.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'y.grd'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'xbeach.tim'],inpdir,'f');
[status,message,messageid]=movefile([rundir 't.t'],inpdir,'f');
[status,message,messageid]=movefile([rundir '*.dep'],inpdir,'f');
[status,message,messageid]=movefile([rundir 'RF_table.txt'],inpdir,'f');

delete([rundir '*.sp2']);

[status,message,messageid]=movefile([rundir '*'],outdir,'f');
