function pmfile(func,varargin)
%PMFILE Generate p-code and appropriate m-file with help information.
%
%     PMFILE(Function,DestDirectory)
%     Generate p-code for one function. Function name only, e.g.
%       PMFILE('pmfile','d:\').
%     The full path of the destination directory should be specified.
%
%     PMFILE(SourceDirectory,DestDirectory)
%     Generate p-code for a whole directory and all subdirectories.
%     The full path of the source and destination directories should
%     be specified.
%       PMFILE('dir','d:\mfiles\source','d:\mfiles\target')
%
%     PMFILE('dir',SourceDirectory,DestDirectory)
%     This syntax can be used for directories on the Matlab search path,
%     only the last part of the source directory name should be specified.
%       PMFILE('dir','specgraph','d:\spec')
%
%     NOTES:
%     * In all cases the destination directory should exist.
%     * Although examples are given for PC platform, this function
%       should work similarly for UNIX systems.
%
%     See also PCODE.

% (c) 2001, H.R.A. Jagers, bert.jagers@wldelft.nl
%     WL | Delft Hydraulics, The Netherlands

% 13/10/2000 : created 
% 31/07/2001 : updated

if nargin<2,
  error('Too few input arguments.');
end;

verbose=0;
if strcmp(lower(func),'dir') | exist(func)==7
  if exist(func)==7
    dest=varargin{1};
    if nargin>2, verbose=isequal(varargin{2},'-verbose'); end
  else
    func=varargin{1};
    dest=varargin{2};
    if nargin>3, verbose=isequal(varargin{3},'-verbose'); end
  end
  MP=matlabpath;
  mp=find(MP==pathsep);
  Start=[1 mp+1];
  End=[mp-1 length(MP)];
  P=[];
  for i=1:length(Start),
    if ~isempty(findstr(func,MP(Start(i):End(i))))
      P(end+1)=i;
    end
  end
  if length(P)==1,
    p=MP(Start(P):End(P));
  elseif exist(func)==7 % dir
    p=func;
  else
    error('Cannot uniquely determine directory.')
  end
  pmcodedir(p,dest,1,verbose)
else
  dest=varargin{1};
  if nargin>2, verbose=isequal(varargin{2},'-verbose'); end
  [p,n,e,v] = fileparts(func);
  if strcmp(lower(e),'.m')
    fullmfile=which(func);
    mfile=strcat(n,e);
  elseif isempty(e)
    fullmfile=which(func);
    mfile=strcat(func,'.m');
  else
    error(sprintf('%s is not an m-file.',func))
  end
  %fprintf('%s -> %s\\%s\n',fullmfile,dest,mfile);
  if ~exist(dest)
    error(sprintf('Destination directory %s does not exist.',dest))
  end
  %
  %[ok,emsg]=copyfile(fullmfile,dest,'writable');
  %
  if isunix
    unix(['cp "',fullmfile,'" "',dest,'"']);
  else
    dos(['copy "',fullmfile,'" "',dest,'" | exit']);
  end;
  here=pwd;
  try,
    cd(dest);
    if ~strcmp(dest,cd)
      error(sprintf('Could not switch to: %s.',dest));
    end
    pmcodeonefunc(mfile)
  catch,
    warning(lasterr);
  end;
  cd(here);
end

function pmcodedir(p,dest,makecopy,verbose)
here=pwd;
try,
  cd(dest)
  d=dir(p);
  if makecopy
    if isunix
      unix(['cp -r "',p,'/*" .']);
    else
      dos(['xcopy "',p,'\*.*" "',dest,'" /E | exit']);
    end
  end
  for i=1:length(d)
    [p,n,e,v] = fileparts(d(i).name);
    if isequal(d(i).name,'.') | isequal(d(i).name,'..')
      %don't do anything
    elseif d(i).isdir
      pmcodedir('.',d(i).name,0,verbose);
      %fprintf('Skipping subdir %s.\n',d(i).name)
    else
      if strcmp(lower(e),'.m')
        disp(d(i).name)
        pmcodeonefunc(d(i).name)
      else
      end
    end
  end
catch
  warning(lasterr);
end;
cd(here);

function pmcodeonefunc(mfile)
% fprintf('Converting ... %s\n',mfile);
Txt = textread(mfile,'%s','delimiter','\n','whitespace','');
i=1;
while i<=length(Txt) & ~strcmp(lower(strtok(Txt{i})),'function'),
  i=i+1;
end;
if i>length(Txt)
  %warning('No function statement found in file!');
  return
else
  try,
    pcode(mfile)
  catch
    fprintf('%s could not be pcoded.\n',mfile);
    return
  end
  fcn=Txt{i};
end
i=1;
while i<=length(Txt) & (isempty(Txt{i}) | Txt{i}(1)~='%'),
  i=i+1;
end;
[fid,emsg]=fopen(mfile,'w');
if fid<0, error(emsg); end
if ~isempty(fcn),
  fprintf(fid,'%s\n',fcn);
end
if i>length(Txt),
  [p,n]=fileparts(mfile);
  fprintf(fid,'%%%s No help available.\n',upper(n));
else,
  i1=i;
  while i<=length(Txt) & ...
    (isempty(Txt{i}) | ((~isempty(Txt{i}) & Txt{i}(1)=='%'))),
    i=i+1;
  end;
  i2=i-1;
  fprintf(fid,'%s\n',Txt{i1:i2});
end;
if ~isempty(fcn)
  fprintf(fid,'\n%s%s\n', ...
      'error(sprintf(''Missing p-file for %s,', ...
            ' contact supplier of code.'',mfilename))');
end
fclose(fid);
