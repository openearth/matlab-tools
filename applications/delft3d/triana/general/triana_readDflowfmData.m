function s = triana_readDflowfmData(s);

s.model.data.WL = ncread(s.model.file,'waterlevel');

% store only the data at the selected stations
s.model.data.WL = s.model.data.WL(s.modID,:);
s.model.data.stats = s.model.data.statsAll(s.modID,:);
s.model.data.X =s.model.data.XAll(s.modID);
s.model.data.Y =s.model.data.YAll(s.modID);

s.model.data.Time = nc_cf_time(s.model.file);

% set interval of new timeseries
s.ana.new_interval = diff(s.model.data.Time(1:2))*1440;