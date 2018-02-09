function s = triana_readDflowfmStations(s);
    
s.model.data.statsAll = char2cell(ncread(s.model.file,'station_name')');

s.model.data.XAll = ncread(s.model.file,'station_x_coordinate'); s.model.data.XAll = s.model.data.XAll(:,1);
s.model.data.YAll = ncread(s.model.file,'station_y_coordinate'); s.model.data.YAll = s.model.data.YAll(:,1);

