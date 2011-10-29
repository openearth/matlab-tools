function ddb_saveAstroMapFile(fname,x,y,comp,amp,phi)

x(isnan(x))=-999;
y(isnan(y))=-999;

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','* column 1 : x');
fprintf(fid,'%s\n','* column 2 : y');
for i=1:length(amp)
    fprintf(fid,'%s\n',['* column ' num2str(i*2+1) ' : Amplitude ' comp{i}]);
    fprintf(fid,'%s\n',['* column ' num2str(i*2+2) ' : Phase ' comp{i}]);
end
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i %i %i\n',size(x,1)*size(x,2),length(amp)*2+2,size(x,1),size(x,2));
for j=1:size(x,2)
    for i=1:size(x,1)
        zz=[];
        for k=1:length(amp)
            zz(k*2-1)=amp{k}(i,j);
            zz(k*2)=phi{k}(i,j);
        end
        zz(isnan(zz))=-999;
        fprintf(fid,['%12.4e %12.4e' repmat(' %12.4e',1,2*length(amp)) '\n'],x(i,j),y(i,j),zz);
    end
end
fclose(fid);
