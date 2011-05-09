function hm=getTideStations(hm)

flist=dir([hm.MainDir 'data' filesep 'tidestations' filesep '*.mat']);

for i=1:length(flist)
    fname=[hm.MainDir 'data' filesep 'tidestations' filesep flist(i).name];
    load(fname);
    hm.TideStations{i}=s;
    hm.TideDatabases{i}=lower(s.DatabaseName);
end
