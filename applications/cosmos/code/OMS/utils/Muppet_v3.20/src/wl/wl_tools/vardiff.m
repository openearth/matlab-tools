function out=vardiff(var1,var2);
% VARDIFF Determines the differences between two variables.
%
%         VARDIFF(var1,var2) lists the differences
%         between the two specified variables-files.
%
%         different=VARDIFF(var1,var2) returns the
%         lowest appropriate number of the following list
%           0   if the variables are identical (no NaNs found),
%           1   if the variables are identical (NaNs found),
%           2   if the variables are of different size, class or
%                  they are structures with different fields.
%           2+N if the data is different in the Nth level, for
%               matrices this will be at most 3, for cell arrays
%               and structures this can become higher than 3.
%               This basically indicates that you need N subscripts
%               to see the difference.
%         The function does not show the differences as text.
%
%         See also: ISEQUAL

% Written on 8/8/2000 by
%    Bert Jagers, WL | Delft Hydraulics, The Netherlands
%                                        www.wldelft.nl
%    hrajagers@deja.com

if nargin<2,
   error('Not enough input arguments.');
end;

verbose=nargout==0;
if verbose,
   printdiff('init',inputname(1),inputname(2)),
end;

DiffFound=0;

try,
   if isequal(var1,var2),
      if verbose,
         fprintf('The variables are identical and they don''t contain NaNs.\n');
      end;
   else,
      DiffFound=1+detailedcheck(var1,var2,verbose,'');
      if verbose,
         switch DiffFound,
            case 1,
               fprintf('The variables are identical, but they do contain NaNs.\n')
         end;
      end;
   end;
catch,
   error(sprintf('An unexpected error occurred while comparing the files:\n%s',lasterr));
end;
if nargout>0
   out=DiffFound;
end


%% -----------------------------------------------------------------------
%  Function used for printing ...
%% -----------------------------------------------------------------------
function printdiff(pflag,varargin),
persistent var1 var2
switch pflag,
   case 'init',  % varname1, varname2
      fprintf('Comparing variables ...\n');
      s1=varargin{1};
      s2=varargin{2};
      fprintf('Variable 1: ');
      if isempty(s1),
         var1='VAR1';
         fprintf('<expression> indicated as VAR1\n');
      else,
         var1=s1;
         fprintf('%s\n',var1);
      end;
      fprintf('Variable 2: ');
      if isempty(s2),
         var2='VAR2';
         fprintf('<expression> indicated as VAR2\n\n');
      else,
         var2=s2;
         fprintf('%s\n\n',var2);
      end;
   case 'class', % classvar1, classvar2, subscript string
      cls1=varargin{1};
      cls2=varargin{2};
      substr=varargin{3};
      fprintf('Class (%s) of %s%s differs from class (%s) of %s%s.\n',cls1,var1,substr,cls2,var2,substr);
   case 'size',  % classvar1, classvar2, subscript string
      sz1=varargin{1};
      sz2=varargin{2};
      substr=varargin{3};
      fprintf('Size of %s%s is [%i',var1,substr,sz1(1));
      fprintf(' %i',sz1(2:end));
      fprintf('], but size of %s%s is [%i',var2,substr,sz2(1));
      fprintf(' %i',sz2(2:end));
      fprintf('].\n');
   case 'data',  % subscript string
      substr=varargin{1};
      fprintf('Data of %s%s differs from data contained in %s%s.\n',var1,substr,var2,substr);
   case 'fieldnames' % fieldnames1,fieldnames2,subscript string
      fn1=varargin{1};
      fn2=varargin{2};
      substr=varargin{3};
      sfn1=setdiff(fn1,fn2);
      if ~isempty(sfn1)
         fprintf('%s%s contains the following fields not part of %s%s:\n',var1,substr,var2,substr);
         fprintf('  %s\n',sfn1{:});
      end
      sfn2=setdiff(fn2,fn1);
      if ~isempty(sfn2)
         fprintf('%s%s contains the following fields not part of %s%s:\n',var2,substr,var1,substr);
         fprintf('  %s\n',sfn2{:});
      end
   case 'fieldnamesorder' % fieldnames1,fieldnames2,subscript string
      substr=varargin{3};
      fprintf('The order of the fields of %s%s and %s%s is different.\n',var1,substr,var2,substr);
end;


%% -----------------------------------------------------------------------
%  Function used for recursive checking ...
%% -----------------------------------------------------------------------
function DiffFound=detailedcheck(s1,s2,verbose,substr),
DiffFound=0;
if ~isequal(class(s1),class(s2)), % different classes?
   DiffFound=1;
   if verbose, printdiff('class',class(s1),class(s2),substr); end;
elseif ~isequal(size(s1),size(s2)), % different size?
   DiffFound=1;
   if verbose, printdiff('size',size(s1),size(s2),substr); end;
elseif iscell(s1), % & s2 is also cell! if cell -> check per element
   sz1=size(s1);
   for i=1:prod(sz1), % s2 has same size!
      Diff=detailedcheck(s1{i},s2{i},verbose,sprintf('%s{%i}',substr,i));
      if Diff,
         if ~DiffFound,
            DiffFound=Diff;
         else,
            DiffFound=min(Diff,DiffFound);
         end;
      end;
   end;
   if DiffFound, DiffFound=DiffFound+1; end;
elseif isstruct(s1) | isobject(s1),
   if isobject(s1), % in case of objects convert into structures for detailed check
      s1=struct(s1); s2=struct(s2);
   end;
   fn1=fieldnames(s1);
   fn2=fieldnames(s2);
   nf=length(fn1);
   if ~isequal(sort(fn1),sort(fn2)), % fieldnames the same?
      DiffFound=1;
      if verbose, printdiff('fieldnames',fn1,fn2,substr); end;
      return;
   elseif ~isequal(fn1,fn2), % fieldnames the same?
      DiffFound=1;
      if verbose, printdiff('fieldnamesorder',fn1,fn2,substr); end;
      return;
   end;
   s1=struct2cell(s1);
   s2=struct2cell(s2);
   j=0;
   for i=1:prod(size(s1)), % s2 has same size! (array size is the same and fields are the same)
      j=j+1;
      if j>nf, j=1; end;
      if prod(size(s1))~=nf
         Nsubstr=sprintf('%s(%i).%s',substr,(i-j)/nf+1,fn1{j});
      else
         Nsubstr=sprintf('%s.%s',substr,fn1{j});
      end
      Diff=detailedcheck(s1{i},s2{i},verbose,Nsubstr);
      if Diff,
         if ~DiffFound,
            DiffFound=Diff;
         else,
            DiffFound=min(Diff,DiffFound);
         end;
      end;
   end;
   if DiffFound, DiffFound=DiffFound+1; end;
else, % some numeric type of equal size
   if isempty(s1), % same size, numeric, empty -> no difference
      return;
   elseif isa(s1,'double'),
      NaNorEqual=(isnan(s1) & isnan(s2)) | (s1==s2);
      DiffFound=~all(NaNorEqual(:));
   else,
      DiffFound=~isequal(s1,s2);
   end;
   if DiffFound & verbose, printdiff('data',substr); end;
end;