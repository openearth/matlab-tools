function s = triana_readDelft3DData(s);

trih = qpfopen(s.model.file);


dummy = qpread(trih,'water level','data',0,s.modID);
s.model.data.WL = dummy.Val';

% store only the data at the selected stations
s.model.data.stats = s.model.data.statsAll(s.modID);
s.model.data.X =s.model.data.XAll(s.modID);
s.model.data.Y =s.model.data.YAll(s.modID);

s.model.data.Time = get_d3d_output_times(s.model.file);

% set interval of new timeseries
s.ana.new_interval = diff(s.model.data.Time(1:2))*1440;