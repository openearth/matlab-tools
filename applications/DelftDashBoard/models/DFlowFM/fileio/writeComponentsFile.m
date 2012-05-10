function writeComponentsFile(fname,bndPolygons,ii,jj)

fid=fopen(fname,'wt');

fprintf(fid,'%s\n',['* Delft3D-FLOW boundary segment name: ' bndPolygons(ii).name]);
fprintf(fid,'%s\n',['* ' bndPolygons(ii).nodes(jj).componentsFile]);
fprintf(fid,'%s\n','* COLUMNN=3');
fprintf(fid,'%s\n','* COLUMN1=Period (min) or Astronomical Componentname');
fprintf(fid,'%s\n','* COLUMN2=Amplitude (m)');
fprintf(fid,'%s\n','* COLUMN3=Phase (deg)');

for ip=1:length(bndPolygons(ii).nodes(jj).components)
    cmp=bndPolygons(ii).nodes(jj).components(ip).component;
    cmp=[repmat(' ',1,12-length(cmp)) cmp]; 
    amp=bndPolygons(ii).nodes(jj).components(ip).amplitude;
    phi=bndPolygons(ii).nodes(jj).components(ip).phase;
    fprintf(fid,'%s %11.4f %11.1f\n',cmp,amp,phi);
end

fclose(fid);
