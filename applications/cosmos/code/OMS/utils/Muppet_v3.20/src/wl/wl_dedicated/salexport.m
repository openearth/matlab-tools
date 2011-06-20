function salexport(filename,x,y)
if nargin==1
  x=get(gco,'xdata'); y=get(gco,'ydata');
end
C=cellstr([datestr(x) repmat(' ',length(y),1) num2str(y')]);
fid=fopen([filename '.txt'],'wt');
fprintf(fid,'%s\n',C{:});
fclose(fid);
