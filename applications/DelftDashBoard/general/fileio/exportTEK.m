function exportTEK(data,times,fname,blname,comments)

fid=fopen(fname,'w');

if nargin==4
    fprintf(fid,'%s\n','* column 1 : Date');
    fprintf(fid,'%s\n','* column 2 : Time');
    fprintf(fid,'%s\n','* column 3 : WL');
else
    for ij=1:length(comments)
        fprintf(fid,'%s\n',comments{ij});
    end
end

fprintf(fid,'%s\n',blname);
n=size(data,1);
fprintf(fid,'%i %i\n',n,2+size(data,2));
fclose(fid);

datstr=datestr(times,'yyyymmdd HHMMSS');
wl=num2str(data,'%10.3f');
spc=repmat(' ',length(times),1);
str=[datstr spc wl];
dlmwrite(fname,str,'delimiter','','-append');

