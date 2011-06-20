function out=matdiff(fn1,fn2);
% MATDIFF Locates the differences between two MAT files.
%
%         MATDIFF(filename1,filename2) lists the differences
%         between the two specified mat-files.
%
%         different=MATDIFF(filename1,filename2) returns the
%         lowest appropriate number of the following list
%           0 if the data in the two files is identical,
%           1 if the variables contained in the files differ,
%           2 if the size, class, or bytes property of one of
%             the variables differs.
%           3 if the data contained in the variables differs.
%         The function does not show the differences as text.
%
%         See also: LOAD, WHOS, ISEQUAL

% Written on 8/8/2000 by
%    Bert Jagers, WL | Delft Hydraulics, The Netherlands
%                                        www.wldelft.nl
%    hrajagers@deja.com

if nargin<2,
  error('Not enough input arguments.');
elseif ~ischar(fn1) | ~ischar(fn2),
  error('Two filenames expected as input arguments.');
end;

if exist(fn1)~=2,
  fn1=strcat(fn1,'.mat');
  if exist(fn1)~=2,
    error('Cannot locate first MAT-file.');
  end;
end;
if exist(fn2)~=2,
  fn2=strcat(fn2,'.mat');
  if exist(fn2)~=2,
    error('Cannot locate second MAT-file.');
  end;
end;

verbose=nargout==0;
if verbose,
  fprintf('Comparing MAT-files ...\n');
  fprintf('File 1: %s\n',fn1);
  fprintf('File 2: %s\n\n',fn2);
end;

DiffFound=0;

try,
  vars1=whos('-file',fn1);
  vars2=whos('-file',fn2);
  V1={vars1.name};
  V2={vars2.name};

  var1NotIn2=setdiff(V1,V2);
  if ~isempty(var1NotIn2),
    DiffFound=1;
    if ~verbose, out=1; return; end;
    fprintf('The following variables are contained in File 1 and not in File 2:\n');
    fprintf('%s\n',var1NotIn2{:});
    fprintf('\n');
  end;
  var2NotIn1=setdiff(V2,V1);
  if ~isempty(var2NotIn1),
    DiffFound=1;
    if ~verbose, out=1; return; end;
    fprintf('The following variables are contained in File 2 and not in File 1:\n');
    fprintf('%s\n',var2NotIn1{:});
    fprintf('\n');
  end;
  
  [V,I1,I2]=intersect(V1,V2);
  
  for i=1:length(V),
    if ~isequal(vars1(I1(i)).class,vars2(I2(i)).class),
      % Differences in class ...
      DiffFound=1;
      if ~verbose, out=2; return; end;
      fprintf('The class of variable %s is %s in File 1 and %s in File 2.\n', ...
        V{i},vars1(I1(i)).class,vars2(I2(i)).class);
    elseif ~isequal(vars1(I1(i)).size,vars2(I2(i)).size),
      % Differences in size ...
      DiffFound=1;
      if ~verbose, out=2; return; end;
      sz1=vars1(I1(i)).size;
      sz2=vars2(I2(i)).size;
      fprintf('The size of variable %s is [%i',V{i},sz1(1));
      fprintf(' %i',sz1(2:end));
      fprintf('] in File 1 and [%i',sz2(1));
      fprintf(' %i',sz2(2:end));
      fprintf('] in File 2.\n');
    elseif ~isequal(vars1(I1(i)).bytes,vars2(I2(i)).bytes),
      % Differences in the number of bytes ...
      % Data is a structure or cell if this occurs.
      DiffFound=1;
      if ~verbose, out=2; return; end;
      fprintf('The number of bytes used by variable %s is %i in File 1 and %i in File 2.\n', ...
        V{i},vars1(I1(i)).bytes,vars2(I2(i)).bytes);
    else,
      % No obvious differences, so I have to load the data ...
      s1=load(fn1,V{i});
      s2=load(fn2,V{i});
      % Comparing structures is equivalent to comparing data fields ...
      if ~isequal(s1,s2),
        % different or containing NaNs.
        % to check the latter condition ... perform a detailed check
        DiffFound=detailedcheck(s1,s2);
        if DiffFound,
          if ~verbose, out=3; return; end;
          fprintf('The data of contained in variable %s are different in the two files.\n',V{i});
        end;
      end;
    end;
  end;

  if ~verbose, out=0; return; end;
  if DiffFound==0,
    fprintf('The data contained in these files are identical.\n');
  else,
    fprintf('\n... comparison finished.\n');
  end;
catch,
  error('An unexpected error occurred while comparing the files.');
end;


function DiffFound=detailedcheck(s1,s2),
DiffFound=0;
if ~isequal(class(s1),class(s2)), % different classes?
  DiffFound=1;
  return;
elseif ~isequal(size(s1),size(s2)), % different size?
  DiffFound=1;
  return;
elseif iscell(s1), % & s2 is also cell! if cell -> check per element
  for i=1:prod(size(s1)), % s2 has same size!
    DiffFound=detailedcheck(s1{i},s2{i});
    if DiffFound, return; end;
  end;
elseif isstruct(s1) | isobject(s1),
  if isobject(s1), % in case of objects convert into structures for detailed check
    s1=struct(s1); s2=struct(s2);
  end;
  fn1=fieldnames(s1);
  fn2=fieldnames(s2);
  if ~isequal(fn1,fn2), % fieldnames the same?
    DiffFound=1;
    return;
  end;
  s1=struct2cell(s1);
  s2=struct2cell(s2);
  for i=1:prod(size(s1)), % s2 has same size! (array size is the same and fields are the same)
    DiffFound=detailedcheck(s1{i},s2{i});
    if DiffFound, return; end;
  end;
else, % some numeric type
  if isa(s1,'double'),
    NaNorEqual=(isnan(s1) & isnan(s2)) | (s1==s2);
    DiffFound=~all(NaNorEqual(:));
  else,
    DiffFound=~isequal(s1,s2);
  end;
  if DiffFound, return, end;
end;
