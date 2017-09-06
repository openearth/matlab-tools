function coastline=sfincs_read_coastline(filename)

s=load(filename);
coastline.x=s(:,1);
coastline.y=s(:,2);
coastline.slope=s(:,3);
