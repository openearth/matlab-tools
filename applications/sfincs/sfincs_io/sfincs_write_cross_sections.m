function sfincs_write_cross_sections(filename,cross_sections)
% Cross-section file
%%%%%
%.crs
% NAME
% 3 2  % size data
% xloc1X1 yloc1X1  % start polyline 1
% xloc1X2 yloc1X2  % 
% xloc1X3 yloc1X3  % end polyline 1
%
% NAME
% 3 2  % size data
% xloc2X1 yloc2X1  % start polyline 2
% xloc2X2 yloc2X2  % 
% xloc2X3 yloc2X3  % end polyline 2
%%%%%

fid=fopen(filename,'wt');

for ip = 1:length(cross_sections) % number of thin dams
    fprintf(fid,'%s\n',['BL' num2str(ip)]);
    fprintf(fid,'%i %i\n',length(cross_sections(ip).x),2);        
    
    for ij = 1:length(cross_sections(ip).x) % number of points per cross-section
        fprintf(fid,'%10.1f %10.1f\n',cross_sections(ip).x(ij),thindams(ip).y(ij));
    end
end
fclose(fid);
