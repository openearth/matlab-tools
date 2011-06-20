function OK=splitinc(FileInfo,Mask,basename),
% SPLITINC Split an incremental file using masks
%        OK = splitinc(FileData,Mask,BaseName);
%           where FileData is obtained from the FLS function
%           and Mask contains a Mask for every domain.
%           The data for a point (m,n) is written to the
%           file BaseName.I.inc where I is the mask value
%           of point (m,n). The data of points with a mask
%           value 0 are not written to any file.
%
%           See also: FLS

% Created by H.R.A. Jagers, WL | Delft Hydraulics, The Netherlands
%            Sun. 11 March 2001

OK=0;

NOutput=0;
if ~iscell(Mask)
  Mask={Mask};
end
for dmn=1:length(Mask),
  Mask{dmn}=fliplr(Mask{dmn});
  NOutput=max(NOutput,max(Mask{dmn}(:)));
end;
if NOutput==0,
  OK=1;
  warning('No active points, no files created.');
  return
end

for oid=1:NOutput
  filename=cat(2,basename,sprintf('.%i',oid),'.inc');
  ofid(oid)=fopen(filename,'w');
  if ofid(oid)<0,
    error(sprintf('Cannot open output file: %s.',filename));
  end
end

fid=fopen(FileInfo.FileName,'r');
if fid<0,
  error(sprintf('Cannot open input file: %s.',FileInfo.FileName));
end;

while 1,
  Line=fgetl(fid);
  for oid=1:NOutput
    fprintf(ofid(oid),'%s\n',Line);
  end
  if strcmp(Line,'ENDCLASSES')
    break;
  end
end

InterpartTime=0;
dmn=1;
while 1,
  if FileInfo.Sobek,
    [X,nr]=fscanf(fid,'%f %i %i %i',4);
    if feof(fid), break, end
    for oid=1:NOutput
      fprintf(ofid(oid),'%.5f %i %i %i\n',InterpartTime+X(1),X(2:4));
    end
    dmn=X(4);
  else,
    [X,nr]=fscanf(fid,'%f %i %i',3);
    if feof(fid), break, end
    for oid=1:NOutput
      fprintf(ofid(oid),'%.5f %i %i\n',InterpartTime+X(1),X(2:3));
    end
  end;
  % read changes and track offset
  [X,nr]=fscanf(fid,'%i',[3 inf]);
  i=1:floor(nr/3);
  if ~isempty(i),
    Ind=sub2ind([FileInfo.Domain(dmn).NRows,FileInfo.Domain(dmn).NCols],X(1,i),X(2,i));
    for oid=1:NOutput
     ind=Mask{dmn}(Ind)==oid;
     fprintf(ofid(oid),'%i %i %i\n',X(:,ind));
    end
  end;
  if floor(nr/3)~=nr/3,
    InterpartTime=X(nr);
  else
    InterpartTime=0;
  end
end;

fclose(fid);
for oid=1:NOutput
  fclose(ofid(oid));
end

OK=1;