function X_OK=solve9(X,Nine);
% solve9 solves a puzzle
%       solve9(Xinitial)
%       Fills a square NxN-matrix such that every column and
%       every row and the two diagonals contain the numbers one
%       through N. The input argument should be a square matrix

if nargin==0,
  error('One input argument expected');
elseif nargin==1, % user specified matrix
  % is X 2-dimensional and square?
  if ~isequal(size(X),size(X,1)*[1 1]),
    error('Input argument should be a square matrix');
  end;
  Nine=size(X,1);
  % remove out of range values
  X((X<1) | (X>Nine) | (X~=round(X)))=NaN;
  % check initial values for consistency
  for i=1:Nine,
    Xi=X==i;
    if any(sum(Xi,1)>2),
      C=find(sum(Xi,1)>2);
      Str=sprintf('Column %i contains already more than one %i.',C(1),i);
      error(Str);
    elseif any(sum(Xi,2)>2),
      R=find(sum(Xi,1)>2);
      Str=sprintf('Row %i contains already more than one %i.',R(1),i);
      error(Str);
    elseif sum(diag(Xi))>2,
      Str=sprintf('Main diagonal contains already more than one %i.',i);
      error(Str);
    elseif sum(diag(fliplr(Xi)))>2,
      Str=sprintf('Second diagonal contains already more than one %i.',i);
      error(Str);
    end;
  end;
% else, % recursive mode - no input checking necessary
end;

% find first value not set
[i,j]=find(isnan(X));

if isempty(i),
  X_OK=X;
  return;
else,
  Possible=ones(Nine,Nine,Nine);
  for k=1:length(i),
    Xi=X(i(k),:);
    Xi=Xi(Xi>0)';
    Xj=X(:,j(k));
    Xj=Xj(Xj>0);
    if i(k)==j(k),
      Xd1=X(1:(Nine+1):(Nine^2));
      Xd1=Xd1(Xd1>0)';
    else,
      Xd1=[];
    end;
    if i(k)==Nine+1-j(k),
      Xd2=X(Nine:(Nine-1):(Nine^2-1));
      Xd2=Xd2(Xd2>0)';
    else,
      Xd2=[];
    end;
    Used=unique([Xi; Xj; Xd1; Xd2]);
    Possible(i(k),j(k),Used)=0;
  end;
  ij=Nine*(j-1)+i;
  NPossible=sum(Possible,3);
  NPossible=NPossible(ij);
  [NPossible,Reorder]=sort(NPossible);
  i=i(Reorder(1));
  j=j(Reorder(1));
  if sum(Possible(i,j,:))==0,
    X_OK=[];
    return;
  else,
    for k=1:Nine,
      if Possible(i,j,k),
        X(i,j)=k;
        X_OK=solve9(X,Nine); % skip checking in recursive mode
        if ~isempty(X_OK),
          return;
        end;
      end;
    end;
    return;
  end;
end;