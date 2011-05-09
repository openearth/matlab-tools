function filesplit(varargin)
%FILESPLIT Split/combine files
%    FILESPLIT(FileName,FileSize)
%    Splits the file into smaller files of the specified size.
%    If FileSize is a vector, file N will have the size
%    FileSize(max(N,length(FileSize(:)))). The files will be
%    in the same location as the original file. The files
%    will have the extension .000, .001, .002, etc. added to
%    the original name. The specified size are indicated in
%    megabytes (MB).
%    
%    FILESPLIT(DestFile,FileName1,FileName2,FileName3,...)
%    Combines the files (FileName*) into one file (DestFile).
%
%    FILESPLIT(FileName)
%    Combines the files created by FILESPLIT assuming that
%    they have the same base name (FileName) with added
%    extensions .000, .001, .002, etc.

h=waitbar(0,'Initializing ...');
MB1=1024^2;
if (nargin==2) & isnumeric(varargin{2}),
  % split
  FileName=varargin{1};
  FileSize=double(varargin{2}(:));
  if ~isequal(round(FileSize),FileSize),
    if ishandle(h), delete(h), end
    error('Invalid filesize specification (only integers allowed)');
  end
  fid1=fopen(FileName,'r');
  fseek(fid1,0,1);
  FSize=ftell(fid1);
  fseek(fid1,0,-1);
  FRem=FSize-sum(FileSize)*MB1;
  if FRem>0,
    NFiles=ceil(FRem/FileSize(end)/MB1)+length(FileSize);
    FileSize(length(FileSize)+1:NFiles)=FileSize(end);
  else
    FSuff=find(cumsum(FileSize*MB1)>FSize);
    NFiles=FSuff(1);
    FileSize=FileSize(1:NFiles);
  end
  FileSize(end)=ceil((FSize-sum(FileSize(1:end-1))*MB1)/MB1);
  if NFiles>1000
    if ishandle(h), delete(h), end
    error('More than 1000 files would be created.');
  end
  for i=1:NFiles,
    if ishandle(h),
      ax=findobj(h,'type','axes');
      set(findobj(ax,'type','patch'),'erasemode','normal');
      waitbar(0,h)
      set(findobj(ax,'type','patch'),'erasemode','none');
      set(get(ax,'title'),'string',sprintf('Creating file %i of %i (%iMB)',i,NFiles,FileSize(i)))
    end
    fid2=fopen(strcat(FileName,sprintf('.%3.3i',i-1)),'w');
    for mb=1:FileSize(i)
      if ishandle(h), waitbar(mb/FileSize(i),h), end
      Data=fread(fid1,[1 MB1],'*uint8');
      fwrite(fid2,Data,'*uint8');
    end
    fclose(fid2);
  end;
  fclose(fid1);
  if ishandle(h), delete(h), end
elseif nargin>0,
  % combine
  switch nargin,
  case {1,2},
    DestFile=varargin{1};
    FileName=varargin{end};
    if ~isempty(dir(DestFile)),
      if ishandle(h), delete(h), end
      error('File exists or invalid input arguments.');
    end;
    [fp,fn]=fileparts(FileName);
    Files=dir(strcat(FileName,'.*'));
    Files=sort({Files.name});
    [fp1,fn1,ext1]=fileparts(Files{1});
    if ~strcmp(ext1,'.000')
      if ishandle(h), delete(h), end
      error('Don''t know how to combine the files.');
    end;
    if isequal(fp1,fp)
      fp='';
    end;
  otherwise,
    DestFile=varargin{1};
    Files=varargin(2:end);
    fp='';
  end;
  fid1=fopen(DestFile,'w');
  NFiles=length(Files);
  for i=1:NFiles,
    FileName=fullfile(fp,Files{i});
    if ishandle(h),
      ax=findobj(h,'type','axes');
      set(findobj(ax,'type','patch'),'erasemode','normal');
      waitbar(0,h)
      set(findobj(ax,'type','patch'),'erasemode','none');
      set(get(ax,'title'),'string',sprintf('Adding file %i of %i: %s',i,NFiles,FileName))
    end
    fid2=fopen(FileName,'r');
    if fid2<0,
      if ishandle(h), delete(h), end
      error('Error opening file.');
    end;
    while ~feof(fid2),
      if ishandle(h), waitbar(mb/FileSize(i),h), end
      Data=fread(fid2,[1 MB1],'*uint8');
      fwrite(fid1,Data,'*uint8');
    end;
    fclose(fid2);
  end;
  fclose(fid1);
  if ishandle(h), delete(h), end
else,
  if ishandle(h), delete(h), end
  error('Not enough input arguments.');
end