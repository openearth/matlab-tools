function OK=reclassinc(InFile,OutFile,ReclassVec),
% RECLASSINC Reclassify incremental file
%        OK = reclassinc(infile,outfile,classvec);
%
%           See also: FLS

% Created by H.R.A. Jagers, WL | Delft Hydraulics, The Netherlands
%            Thu. 10 May 2001
%            Fri. 11 May 2001: revised classification boundaries

OK=0;

ofid=fopen(OutFile,'w');
if ofid<0,
  error(sprintf('Cannot open output file: %s.',OutFile));
end

if ischar(InFile)
  FileInfo=fls('open',InFile);
else
  FileInfo=InFile;
end
fid=fopen(FileInfo.FileName,'r');
if fid<0,
  error(sprintf('Cannot open input file: %s.',FileInfo.FileName));
end;

while 1,
  Line=fgetl(fid);
  if strmatch('CLASSES',Line)
    fprintf(ofid,'%s\n',Line);
    Classes=fscanf(fid,'%f',[5 inf])';
    NClasses=size(Classes,1);
    if NClasses~=length(ReclassVec)
      fclose(fid);
      fclose(ofid);
      error(sprintf('Invalid length of reclassification vector (length actual:%i, expected:%i)',length(ReclassVec),NClasses));
    end
    Classes=Classes(logical([1 diff(ReclassVec)]),:);
    fprintf(ofid,'                                   %8.2f%8.2f%8.2f%8.2f%8.2f\n',Classes');
  else
    fprintf(ofid,'%s\n',Line);
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
    fprintf(ofid,'%.5f %i %i %i\n',InterpartTime+X(1),X(2:4));
    dmn=X(4);
  else,
    [X,nr]=fscanf(fid,'%f %i %i',3);
    if feof(fid), break, end
    fprintf(ofid,'%.5f %i %i\n',InterpartTime+X(1),X(2:3));
  end;
  % read changes and track offset
  [X,nr]=fscanf(fid,'%i',[3 inf]);
  i=1:floor(nr/3);
  if ~isempty(i),
    zero=X(3,i)==0; X(3,zero)=1;
    X(3,i)=ReclassVec(X(3,i));
    X(3,zero)=0;
    fprintf(ofid,'%i %i %i\n',X(:,i));
  end;
  if floor(nr/3)~=nr/3,
    InterpartTime=X(nr);
  else
    InterpartTime=0;
  end
end;

fclose(fid);
fclose(ofid);

OK=1;