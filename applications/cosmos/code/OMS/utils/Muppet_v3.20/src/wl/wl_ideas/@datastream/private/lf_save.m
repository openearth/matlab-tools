function lf_save(EditedEntries,fid),
if nargin==1,
  [filename,pname]=uiputfile('*.lst','specify output file ...');
  if ischar(filename),
    filename=[pname filename];
    fid=fopen(filename,'w');
    if fid<0,
      uiwait(msgbox('Could not open output file.','modal'));
      return;
    end;
  end;
end;

for i=1:length(EditedEntries),
  fprintf(fid,'%s\n%s\n%s\n',EditedEntries(i).FileType, ...
                             EditedEntries(i).FileName, ...
                             EditedEntries(i).EntryName);
  fnames=fieldnames(EditedEntries(i).EntryParameters);
  for f=1:length(fnames),
    fvalue=getfield(EditedEntries(i).EntryParameters,fnames{f});
    if ischar(fvalue),
      fprintf(fid,'%s = ''%s''\n',fnames{f},fvalue);
    else,
      fprintf(fid,'%s = %s\n',fnames{f},xx_str(fvalue));
    end;
  end;
  if i<length(EditedEntries),
    fprintf(fid,'\n');
  end;
end;

if nargin==1,
  fclose(fid);
end;
