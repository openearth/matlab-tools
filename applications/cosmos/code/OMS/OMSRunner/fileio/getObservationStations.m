function hm=getObservationStations(hm)

flist=dir([hm.MainDir 'data' filesep 'observations' filesep '*.mat']);

for i=1:length(flist)
    fname=[hm.MainDir 'data' filesep 'observations' filesep flist(i).name];
    load(fname);
    hm.ObservationStations{i}=s;
    hm.ObservationDatabases{i}=lower(s.DatabaseName);
end
