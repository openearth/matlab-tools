function saveBndPolygons(dr,bndPolygons)

for ipol=1:length(bndPolygons)
    fid=fopen([dr filesep bndPolygons(ipol).fileName],'wt');
    fprintf(fid,'%s\n',bndPolygons(ipol).name);
    fprintf(fid,'%i %i\n',length(bndPolygons(ipol).x),2);
    for ip=1:length(bndPolygons(ipol).x)
        fprintf(fid,'%14.6e %14.7e %s\n',bndPolygons(ipol).x(ip),bndPolygons(ipol).y(ip),[' ''' bndPolygons(ipol).componentsFile{ip} '''']);
    end
    fclose(fid);
end
