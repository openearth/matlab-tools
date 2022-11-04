function points=sfincs_read_discharge_points(filename)

s=load(filename);

for ip=1:size(s,1)
    points(ip).x=s(ip,1);
    points(ip).y=s(ip,2);
end
