function varargout=sbk_csv(filename),
% SBK_CSV read Sobek CSV file
%    [Time,Stat,Data,Quantity]=sbk_csv(filename);

fid=fopen(filename,'r');
for i=1:5,
  Line{i}=fgetl(fid);
end;
fclose(fid);
if strmatch('Timestep',Line{4})
  T=sscanf(Line{4}(11:end),'%d%*[-/]%d%*[-/]%d %d:%d:%d');
  Time=datenum(T(1),T(2),T(3),T(4),T(5),T(6));
  N=length(findstr(',',Line{5})); % count number of commas in Parameter line
  X(1:N)={', %f'};
  FormatStr=sprintf('%s','%[^,]',X{1:N});
  [Stat X{1:N}]=textread(filename,FormatStr,'headerlines',5);
  Data=[X{1:N}];
  Qty=multiline(Line{5},',','cell'); Qty=Qty(2:end);
  varargout={Time Stat Data Qty};
else
  T=[];
  N=length(findstr(',',Line{4})); % count number of commas in Parameter line
  X(1:N)={', %f'};
  FormatStr=sprintf('%s','%d%*[-/]%d%*[-/]%d %d:%d:%d',X{1:N});
  [Y M D h m s X{1:N}]=textread(filename,FormatStr,'headerlines',5);
  Time=datenum(Y,M,D,h,m,s);
  Data=[X{1:N}];
  Qty=multiline(Line{4},',','cell'); Qty=Qty(2:end);
  Stat=multiline(Line{5},',','cell'); Stat=Stat(2:end);
  varargout={Time Stat Data Qty};
end

