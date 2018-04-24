function s = triana_readDelft3DStations(s);
    



trih = qpfopen(s.model.file);
s.model.data.statsAll = qpread(trih,'water level','stations');

% workaround: dummy = qpread(trih,'water level','griddata',1,0); doesn't seem the return the right X,Y coordinates

[flowDir,trihFileName] = fileparts(s.model.file);
mdfName = trihFileName(6:end);

mdfData = delft3d_io_mdf('read',[flowDir,filesep,mdfName,'.mdf']);
grd = delft3d_io_grd('read',[flowDir,filesep,mdfData.keywords.filcco]);
obs = delft3d_io_obs('read',[flowDir,filesep,mdfData.keywords.filsta],grd);

s.model.data.XAll = obs.x';
s.model.data.YAll = obs.y';
