function sfincs_write_coastline(filename,coastline)

fid=fopen(filename,'wt');
for ii=1:length(coastline.x)
    fprintf(fid,'%10.1f %10.1f %10.5f\n',coastline.x(ii),coastline.y(ii),coastline.slope(ii));
end
fclose(fid);
