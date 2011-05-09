function [i,j,c]=boundary(x);
%BOUNDARY determines the boundary points of a group of non-zero values
%      [I,J,C]=BOUNDARY(X) returns the indices of the non-zero elements
%      of the matrix X that have neighbouring elements that are zero.
%      It returns also the type of boundary point, i.e.
%         C=1 for a right boundary point,                _4_
%         C=2 for a lower boundary point,               |   |
%         C=3 for a left boundary point,               3|   |1
%         C=4 for an upper boundary point.              |___|
%      M=BOUNDARY(X) returns I,J and C in one matrix.     2
%      [M,C]=BOUNDARY(X) returns I and J in one matrix.
%      The coordinates of distinct boundaries are separated by a NaN
%      value in I and J (resp. first two columns of M) and a -1 or -2
%      value in C (resp. third column of M). The value is -1 if the
%      next boundary is an outer boundary and -2 if the next boundary
%      is an inner boundary.

% (c) Copyright 1997, H.R.A. Jagers.
%     University of Twente / Delft Hydraulics

[N,M]=size(x);

% Removing internal points no longer necessary
% x=(filter2([1 1 1;1 0 1;1 1 1],x)<8)&x;

% IMPORTANT NOTICE
% When scanning internal boundaries in a clockwise order,
% the combinations of edge type (1,2,3, and 4) and
% scan direction (up, down, left, and right) is switched
% when compared to external bouyndaries. See second important
% comment.

% For EXTERNAL boundaries the scan directions are
% a right boundary (1) is scanned from top to bottom,
% a left  boundary (3) is scanned from bottom to top,
% an upper boundary (4) is scanned from left to right, and
% a lower boundary (2) is scanned from right to left.

% handle external boundaries
[x,sz]=logicalregions(x,4);
TP=[];
for SEG=1:size(sz,1),
  %                            Find first row that contains a boundary point
  [m,J]=max((x==SEG)');
  I=find(m>0);
  I=I(1);
  %                            Find first boundary point in that row
  J=J(I);
  %                            Determine total number of boundary points NP
  NP=sum(sum(x==SEG));
  %                            Create space for the boundary point coordinates
  P=zeros(2*NP,3);             % In special cases (small areas, e.g. single pixels)
                               % the reserved space may not be enough!
  %                            Initiate search direction D=4 - i.e. going right
  D=4;
  %                            Initiate boundary point counter k
  k=0;
  while x(I,J)>0,
    %                          Increase boundary point counter k
    k=k+1;
    %                          Store boundary point characteristics
    P(k,:)=[I J D];
    %                          Check on first point
    if x(I,J)==inf,
      if D==2,
        % coming into first point going left
        if (I<N) & (x(min(N,I+1),J)>0),
        %                      there is a thin branch going down
        %                      use normal if-statements to deal with this case.
        else,
        %                      make two final turns
          D=3;
          k=k+1;
          P(k,:)=[I J D]; % -------> start of left side
          k=k+1;
          P(k,:)=[I J D]; % -------> end of left side
          D=4;
          k=k+1;
          P(k,:)=[I J D]; % -------> start of top side
          x(I,J)=SEG; %        remove indicator of first point
          break;
        end; 
      else, % D==3
        % make final turn from going up to going right
        D=4;
        k=k+1;
        P(k,:)=[I J D]; % ---------> start of top side
        x(I,J)=SEG; %          remove indicator of first point
        break;
      end;
    else,
      %                        Change value of boundary point
      if k==1,
        x(I,J)=inf; % -------------> indicate first point
      end;
    end;
    if D==4,
      %                        If going right
      if (I>1) & (x(max(1,I-1),J)>0),
        %                      Check going up
        D=3;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of left side
        I=I-1;
      elseif (J<M) & (x(I,min(M,J+1))>0),
        %                      Check going right
        J=J+1;
        % -------------------------> just going on with top side
        %
      elseif (I<N) & (x(min(N,I+1),J)>0),
        %                      Check going down
        if k==1, %             Check for situation that first point is top of spike
          k=k+1;
          P(k,:)=[I,J,D]; % -------> start/end of top side
        end;
        D=1;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of right side
        I=I+1;
      elseif (J>1) & (x(I,max(1,J-1))>0),
        %                      Check going back
        D=1;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of right side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of right side
        D=2;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of bottom side
        J=J-1;
      else,
        %                      An isolated point (can only be first point)
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start/end of top side
        D=1;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of right side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of right side
        D=2;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of bottom side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of bottom side
        D=3;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of left side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of left side
        D=4;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of top side
      end;
    elseif D==3,
      %                        If going up
      if (J>1) & (x(I,max(1,J-1))>0),
        %                      Check going left
        D=2;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of bottom side
        J=J-1;
      elseif (I>1) & (x(max(1,I-1),J)>0),
        %                      Check going up
        I=I-1;
        % -------------------------> just going on with left side
        %
      elseif (J<M) & (x(I,min(M,J+1))>0),
        %                      Check going right
        D=4;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of top side
        J=J+1;
      else,
        %                      Cannot be an isolated point, so go back down
        D=4;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of top side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of top side
        D=1;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of right side
        I=I+1;
      end;
    elseif D==2,
      %                        If going left
      if (I<N) & (x(min(N,I+1),J)>0),
        %                      Check going down
        D=1;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of right side
        I=I+1;
      elseif (J>1) & (x(I,max(1,J-1))>0),
        %                      Check going left
        J=J-1;
        % -------------------------> just going on with bottom side
        %
      elseif (I>1) & (x(max(1,I-1),J)>0),
        %                      Check going up
        D=3;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of left side
        I=I-1;
      else,
        %                      Cannot be an isolated point, so go back right
        D=3;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of left side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of left side
        D=4;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of top side
        J=J+1;
      end;
    else, % D==1,
      %                        Going down
      if (J<M) & (x(I,min(M,J+1))>0),
        %                      Check going right
        D=4;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of top side
        J=J+1;
      elseif (I<N) & (x(min(N,I+1),J)>0),
        %                      Check going down
        I=I+1;
        % -------------------------> just going on with right side
        %
      elseif (J>1) & (x(I,max(1,J-1))>0),
        %                      Check going left
        D=2;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of bottom side
        J=J-1;
      else,
        %                      Cannot be an isolated point, so go back up
        D=2;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of bottom side
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> end of bottom side
        D=3;
        k=k+1;
        P(k,:)=[I,J,D]; % ---------> start of left side
        I=I-1;
      end;
    end;
  end;
  if ~isempty(TP),
    TP=[TP;NaN NaN -1;P(1:k,:)];
  else,
    TP=[NaN NaN -1;P(1:k,:)];
  end;
end;

% IMPORTANT NOTICE
% When scanning internal boundaries in a clockwise order,
% the combinations of edge type (1,2,3, and 4) and
% scan direction (up, down, left, and right) is switched
% when compared to external bouyndaries:
% a right boundary (1) is scanned from bottom to top,
% a left  boundary (3) is scanned from top to bottom,
% an upper boundary (4) is scanned from right to left, and
% a lower boundary (2) is scanned from left to right.

% handle internal boundaries
[x,sz]=logicalregions(~x,8);
for SEG=1:size(sz,1),
  outeredge=0;
  if any(x(:,1)==SEG) | any(x(:,size(x,2))==SEG) | any(x(1,:)==SEG) | any(x(size(x,1),:)==SEG),
    outeredge=1;
  end;
  if ~outeredge,
    %                            Find first row that contains a boundary point
    [m,J]=max((x==SEG)');
    I=find(m>0);
    I=I(1);
    %                            Find first boundary point in that row
    J=J(I);
    %                            Move to neighbouring cell on the upper left
    I=I-1;
    J=J-1;
    %                            Determine total number of boundary points NP
    NP=sum(sum(x==SEG));
    %                            Create space for the boundary point coordinates
    P=zeros(2*NP,3);             % In special cases (small areas, e.g. single pixels)
                                 % the reserved space may not be enough!
    %                            Initiate search direction D=4 - i.e. going right
    D=2;
    %                            Initiate boundary point counter k
    k=0;
    while x(I,J)<1,
      %                          Increase boundary point counter k
      k=k+1;
      %                          Store boundary point characteristics
      P(k,:)=[I J D];
      %                          Check on first point
      if x(I,J)==-inf,
        % can only come in starting point with D=1 ... i.e. going up
        % make final turn from going up to going right
        D=2;
        k=k+1;
        P(k,:)=[I J D]; % -----------> start of top side
        x(I,J)=0; %              remove indicator of first point
        break;
      else,
        %                        Change value of boundary point
        if k==1,
          x(I,J)=-inf; % ------------> indicate first point
        end;
      end;
      if D==2,
        %                        If going right
        if (k>1) & (x(I+1,J)<1),
          %                      Check going down
          D=3;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of left side
          I=I+1;
        elseif (x(I,J+1)<1),
          %                      Check going right
          J=J+1;
          % -------------------------> just going on with lower side
          %
        elseif x(I-1,J)<1,
          %                      Check going up
          D=1;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of right side
          I=I-1;
        else,
          %                      Cannot be an isolated point, so go back left
          D=1;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of right side
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> end of right side
          D=4;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of top side
          J=J-1;
        end;
      elseif D==3,
        %                        If going down
        if (x(I,J-1)<1),
          %                      Check going left
          D=4;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of upper side
          J=J-1;
        elseif (x(I+1,J)<1),
          %                      Check going down
          I=I+1;
          % -------------------------> just going on with left side
          %
        elseif x(I,J+1)<1,
          %                      Check going right
          D=2;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of lower side
          J=J+1;
        else,
          %                      Cannot be an isolated point, so go back up
          D=2;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of lower side
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> end of lower side
          D=1;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of right side
          I=I-1;
        end;
      elseif D==4,
        %                        If going left
        if (x(I-1,J)<1),
          %                      Check going up
          D=1;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of right side
          I=I-1;
        elseif (x(I,J-1)<1),
          %                      Check going left
          J=J-1;
          % -------------------------> just going on with upper side
          %
        elseif x(I+1,J)<1,
          %                      Check going down
          D=3;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of left side
          I=I+1;
        else,
          %                      Cannot be an isolated point, so go back right
          D=3;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of left side
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> end of left side
          D=2;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of lower side
          J=J+1;
        end;
      else, % D==1,
        %                        Going up
        if (x(I,J+1)<1),
          %                      Check going right
          D=2;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of lower side
          J=J+1;
        elseif (x(I-1,J)<1),
          %                      Check going up
          I=I-1;
          % -------------------------> just going on with right side
          %
        elseif x(I,J-1)<1,
          %                      Check going left
          D=4;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of upper side
          J=J-1;
        else,
          %                      Cannot be an isolated point, so go back down
          D=4;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of upper side
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> end of upper side
          D=3;
          k=k+1;
          P(k,:)=[I,J,D]; % ---------> start of left side
          I=I+1;
        end;
      end;
    end;
  end;
  if ~isempty(TP),
    TP=[TP;NaN NaN -2;P(1:k,:)];
  else,
    TP=[NaN NaN -2;P(1:k,:)];
  end;
end;

% determine output
if nargout<2,
  i=TP;
elseif nargout==2,
  i=TP(:,1:2);
  j=TP(:,3);
else,
  i=TP(:,1);
  j=TP(:,2);
  c=TP(:,3);
end;