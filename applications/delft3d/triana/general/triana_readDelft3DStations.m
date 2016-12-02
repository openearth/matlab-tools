function s = triana_readDelft3DStations(s);
    
trih = qpfopen(s.model.file);

s.model.data.statsAll = qpread(trih,'water level','stations');
dummy = qpread(trih,'water level','griddata',1,0);

s.model.data.XAll = dummy.X';
s.model.data.YAll = dummy.Y';
