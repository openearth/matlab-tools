function thindams=sfincs_read_thin_dams(filename)

info = tekal('open',filename);

thindams=[];

for ii=1:length(info.Field)
    data = tekal('read',info,ii);
    thindams(ii).x=data(:,1);
    thindams(ii).y=data(:,2);
end



