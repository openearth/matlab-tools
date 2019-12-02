function sfincs_write_thin_dams(filename,thindams)
% Thin dam file
%%%%%
%.thd
% NAME
% 2 2  % size data
% xloc1a yloc1a  % start polyline
% xloc1b yloc1b  % end polyline
%%%%%

fid=fopen(filename,'wt');

for ip = 1:thindams.length
    fprintf(fid,'%s\n',thindams.name{ip});
    fprintf(fid,'%i %i\n',2,2);        
    fprintf(fid,'%10.1f %10.1f\n',thindams.x1(ip),thindams.y1(ip));
    fprintf(fid,'%10.1f %10.1f\n',thindams.x2(ip),thindams.y2(ip));    
end
fclose(fid);
