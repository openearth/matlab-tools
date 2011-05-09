function B = subsref(Obj,S)
%FUNSUBS/SUBSREF reference output of a function
%       Get a part of a function output.
%
%       Usage:
%          S{function call}reference
%            Applies the reference to the output argument of the
%            function.
%          S{'function',N,i,Arg1,Arg2,...}reference
%            Applies the reference to the i-th output argument
%            of the function when evaluated using N output arguments
%            and the specified input arguments Arg1, Arg2, ... .
%
%       Note:
%          * When the reference contains the keyword END once in the
%            reference expression, the function call is evaluated twice.
%            Depending on the locations where additional occurences of
%            the keyword END are located in the reference expression, the
%            number of function evaluations increases by one or more; in
%            the worst case it doubles for every additional occurence!
%            This is the caused by the way in which Matlab handles the
%            keyword END. There is no work-arounnd. The usage of the
%            keyword END in combination with function evaluation is
%            therefore not recommended.
%          * Unfortunately it is not possible to return comma separated lists. 
%            Evaluations that should return a comma separated list return
%            a cell array instead if the number of elements returned is
%            larger than one.
%
%       Examples:
%
%          S=funsubs; % define S as a funsubs object
%
%          % return the upper left corner of the magic matrix
%          % X=magic(8); Y=X(1:4,1:4); clear('X');
%          Y=S{magic(8)}(1:4,1:4)
%
%          % get the first three eigenvalues of magic(8)
%          % E=eig(magic(8)); Y=E(1:3); clear('E');
%          Y=S{eig(magic(8))}(1:3)
%
%          % get the first three eigenvectors of magic(8)
%          % [V,D]=eig(magic(8)); Y=V(:,1:3); clear('V','D');
%          Y=S{'eig',2,1,magic(8)}(:,1:3)
%
%          % get the last three eigenvectors of a matrix X
%          % [V,D]=eig(X); Y=V(:,1:3); clear('V','D');
%          X=rand(8);
%          Y=S{'eig',2,1,X}(:,end-2:end)
%
%          % get the files and directories in the current directory
%          % D=dir; Y={D.name}; if length(Y)==1, Y=Y{1}; end;
%          Y=S{dir}.name
%          % if the directory contains only one file then Y will be
%          % a string, and not a cell array containing one string!
%
%       See also: SUBSREF, FUNSUBS

% Copyright (c), April 14th, 1999
% H.R.A. Jagers, bert.jagers@wldelft.nl
% University of Twente, The Netherlands, http://www.utwente.nl/uk
% WL | Delft Hydraulics, The Netherlands, http://www.wldelft.nl

switch S(1).type
case '{}',
  switch length(S(1).subs),
  case 1, % {function output} ...output reference...
%    fprintf(1,'Evaluating function.\n');
    if length(S)>1,
      A=S(1).subs{1};
      B=eval(['{A' Local_ref2str(S(2:end)) '}']);
      if length(B)==1,
        B=B{1};
      end;
    else,
      B=S(1).subs{1};
    end;
  case 2,
    error('Invalid number of arguments for function reference.');
  otherwise, % {'function', NFO, NFR, Arg1, Arg2, ...} ...output reference...
    Function=S(1).subs{1};
    NFO=S(1).subs{2};
    NFR=S(1).subs{3};
    InputArgs=S(1).subs(4:end);
    if ~ischar(Function),
      error('First argument should be a string containing a function name.');
    end;
    if ~isequal(size(NFO),[1 1]) | NFO~=round(NFO) | NFO<1,
      error('Second argument should be a valid number of output arguments.');
    end;
    if ~isequal(size(NFR),[1 1]) | NFR~=round(NFR) | NFR<1 | NFR>NFO,
      error('Third argument should be a valid output argument number');
    end;
    try,
      % fprintf(1,'Evaluating function.\n');
      [Q{1:NFO}]=feval(Function,InputArgs{:});
    catch,
      error(lasterr);
    end;
    if length(S)>1,
      A=Q{NFR};
      B=eval(['{A' Local_ref2str(S(2:end)) '}']);
      % eval needed to get comma separated list
      if length(B)==1,
        B=B{1};
      end;
    else,
      B=Q{NFR};
    end;
  end;
case '()'
  error('Function reference requires curly brackets: {}.');
case '.'
  error('Invalid reference to function output.');
end;


function B=mysubsref(A,S),
if isempty(S),
  B=A;
else,
  B=subsref(A,S);
end;


function str=Local_ref2str(ref),
% REF2STR creates a string from a reference list
%
%     See also SUBSINDEX

%     Copyright (c)  H.R.A. Jagers  12-05-1996

if nargin>1,
  fprintf(1,' * Too many input arguments\n');
elseif nargin==1,
  if isempty(ref) | isstruct(ref),
    str='';
    for k=1:length(ref),
      switch ref(k).type,
      case '.',
        str=[str '.' ref(k).subs];
      otherwise, % (), {}
        switch ref(k).type,
        case '()',
          str=[str '('];
        case '{}',
          str=[str '{'];
        end;
        for  l=1:length(ref(k).subs),
          if l~=1,
            str=[str ','];
          end;
          if ischar(ref(k).subs{l}),
            str=[str ref(k).subs{l}];
          else,
            str=[str '[' num2str(ref(k).subs{l}) ']'];
          end;
        end;
        switch ref(k).type,
        case '()',
          str=[str ')'];
        case '{}',
          str=[str '}'];
        end;
      end;
    end;
  else,
    fprintf(1,' * Expected a reference list as input.\n');
  end;
else
  fprintf(1,' * Too few input arguments\n');
end;