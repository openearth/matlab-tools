function AdjustInputXBeach(hm,m)

tmpdir=hm.TempDir;

parfile=[tmpdir 'params.txt'];

findreplace(parfile,'TSTOPKEY',num2str(hm.Models(m).RunTime*60));
findreplace(parfile,'MORFACKEY',num2str(hm.Models(m).MorFac));
findreplace(parfile,'DEPKEY',[hm.Models(m).Name '.dep']);

findreplace(parfile,'REFDATEKEY',datestr(hm.Cycle,'yyyymmdd'));
findreplace(parfile,'REFTIMEKEY',datestr(hm.Cycle,'HHMMSS'));
