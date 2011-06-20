fid=fopen('c:\cfx5list.debug','w');
for i=1:length(A.Field)
  f=A.Field(i);
  fprintf(fid,'%s %-22s ',f.YN,f.What);
  if isstruct(f.DataType)
     fprintf(fid,'%s','STRC{');
     nl=5;
     for c=1:length(f.DataType)-1
        fprintf(fid,'%s:%i ',f.DataType(c).Type,f.DataType(c).Number);
        nl=nl+7+(f.DataType(c).Number>9);
     end
     nl=nl+7+(f.DataType(end).Number>9);
     fprintf(fid,'%s:%i}%s',f.DataType(end).Type,f.DataType(end).Number,repmat(' ',1,20-nl));
  else
     fprintf(fid,'%-20s',f.DataType);
  end
  fprintf(fid,' %7i %7i %5i %1i %8i',f.Offset,f.DataOffset,f.Number,f.Compressed,f.Number*f.DataTypeBytes);
  if f.Compressed
     Str='';
     
    if ~isempty(f.Attrib)
       j=strmatch('HOW',f.Attrib(1,:));
       Str=f.Attrib{2,j};
       if ~strcmp(Str,'RAW')
         j=strmatch('USERLEVEL',f.Attrib(1,:));
         Str=sprintf('%s %s',Str,f.Attrib{2,j});
         j=strmatch('DIMENSIONS',f.Attrib(1,:));
         Str=sprintf('%s (%s)',Str,f.Attrib{2,j});
       end
    end
    fprintf(fid,'%8i %s\n',length(f.Data),Str);
  else
    fprintf(fid,'\n');
  end
end
fclose(fid);
