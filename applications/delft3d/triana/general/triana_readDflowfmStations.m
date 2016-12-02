function s = triana_readDflowfmStations(s);
    
s.model.data.statsAll = char2cell(ncread(s.model.file,'station_name')');

s.model.data.XAll = ncread(s.model.file,'station_x_coordinate');
s.model.data.YAll = ncread(s.model.file,'station_y_coordinate');

