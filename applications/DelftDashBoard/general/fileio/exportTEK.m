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
for i=1:n
    datstr=datestr(times(i),'yyyymmdd HHMMSS');
%     fprintf(fid,['%s ' repmat('%0.8g',1,size(data,2))
%     '\n'],datstr,data(i,:));
    fprintf(fid,['%s ' repmat('%12.4g',1,size(data,2)) '\n'],datstr,data(i,:));
end
fclose(fid);

     
