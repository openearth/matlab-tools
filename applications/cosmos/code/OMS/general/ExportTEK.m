function ExportTEK(prediction,times,fname,blname)

fid=fopen(fname,'w');

fprintf(fid,'%s\n','* column 1 : Date');
fprintf(fid,'%s\n','* column 2 : Time');
fprintf(fid,'%s\n','* column 3 : WL');
fprintf(fid,'%s\n',blname);
n=length(prediction);
fprintf(fid,'%i %i\n',n,3);
for i=1:n
    datstr=datestr(times(i),'yyyymmdd HHMMSS');
    fprintf(fid,'%s %0.8g\n',datstr,prediction(i));
end
fclose(fid);

     
