function hh = errorxy(arg1,arg2,arg3,arg4,arg5)
%ERRORXY Error bar plot for errors in both x and y direction.
%   ERRORXY(X,Y,{EXL EXU},{EYL EYU}) plots the graph of vector
%   X vs. vector Y with error bars specified by the vectors
%   EXL, EXU and EYL, EYU. EXL and EXU (respectively EYL and EYU)
%   contain the lower and upper error ranges in x (respectively y)
%   direction for each point in (X,Y). Each error bar is EYL(i)+EYU(i)
%   long in the y direction and is drawn a distance of EYU(i) above
%   and EYL(i) below the points in (X,Y). Each error bar is EXL(i)+EXU(i)
%   long in the x direction and is drawn a distance of EXU(i) right
%   and EXL(i) left of the points in (X,Y). The vectors X,Y,EXL,EXU,
%   EYL,EYU must all be the same length. If X,Y,EXL,EXU,EYL,EYU are
%   matrices then each column produces a separate line.
%
%   If EX is specified instead of {EXL EXU} it is assumed that EXL=EXU=EX.
%   If EY is specified instead of {EYL EYU} it is assumed that EYL=EYU=EY.
%
%   If the third argument is the empty matrix [] then no errorbars are
%   drawn in x direction; similarly, if the fourth argument is the empty
%   matrix [] then no errorbars are drawn in the y direction.
%
%   ERRORXY(X,Y,{EYL EYU}) or ERRORXY(X,Y,EY) plots (X,Y) with
%   error bars [Y-EYL Y+EYU] where in the latter case EYL=EYU=EY.
%   ERRORXY(Y,{EYL EYU}) or ERRORXY{Y,EY) plots Y with error bars
%   [Y-EYL Y+EYU] assuming X=1:length(E).
%
%   ERRORXY(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   H = ERRORXY(...) returns a vector of line handles.
%
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorxy(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   Based on the errorbar function:
%     L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%     Copyright (c) 1984-98 by The MathWorks, Inc.
%     $Revision$  $Date$

%   Adaptations made by
%     H.R.A. Jagers, 21 July 1998
%     MICS, T&M, University of Twente, Enschede, The Netherlands
%     REN, WL|Delft Hydraulics, Delft, The Netherlands

if nargin == 2, % ERRORXY(Y,EY)
  if iscell(arg2), % ERRORXY(Y,{EYL EYU})
    eyl = arg2{1};
    eyu = arg2{2};
  else, % ERRORXY(Y,EY)
    eyl = arg2;
    eyu = arg2;
  end;
  y = arg1;
  x(:) = transpose(1:npt)*ones(1,n);
  exl = [];
  exu = [];
  symbol = '-';
elseif nargin == 3, % ERRORXY(X,Y,EY) or ERRORXY(Y,EY,LineSpec)
  if iscell(arg3), % ERRORXY(X,Y,{EYL EYU})
    eyl = arg3{1};
    eyu = arg3{2};
    y = arg2;
    x = arg1;
    symbol = '-';
  elseif ischar(arg3), % ERRORXY(Y,EY,LineSpec) or ERRORXY(Y,{EYL EYU},LineSpec)
    if iscell(arg2), % ERRORXY(Y,{EYL EYU},LineSpec)
      eyl = arg2{1};
      eyu = arg2{2};
    else, % ERRORXY(Y,EY,LineSpec)
      eyl = arg2;
      eyu = arg2;
    end;
    y = arg1;
    x(:) = transpose(1:npt)*ones(1,n);
    symbol = arg3;
  else, % ERRORXY(X,Y,EY)
    eyl = arg3;
    eyu = arg3;
    y = arg2;
    x = arg1;
    symbol = '-';
  end;
  exl = [];
  exu = [];
elseif nargin == 4, % ERRORXY(X,Y,EX,EY), ERRORXY(X,Y,EY,LineSpec)
  if iscell(arg4), % ERRORXY(X,Y,EX,{EYL EYU}) or ERRORXY(X,Y,{EXL EXU},{EYL EYU})
    eyl = arg4{1};
    eyu = arg4{2};
    if iscell(arg3), % ERRORXY(X,Y,{EXL EXU},{EYL EYU})
      exl = arg3{1};
      exu = arg3{2};
    else, % ERRORXY(X,Y,EX,{EYL EYU})
      exl = arg3;
      exu = arg3;
    end;
    symbol = '-';
  elseif ischar(arg4), % ERRORXY(X,Y,EY,LineSpec) or ERRORXY(X,Y,{EYL EYU},LineSpec)
    if iscell(arg3), % ERRORXY(X,Y,{EYL EYU},LineSpec)
      eyl = arg3{1};
      eyu = arg3{2};
    else, % ERRORXY(X,Y,EY,LineSpec)
      eyl = arg3;
      eyu = arg3;
    end;
    exl = [];
    exu = [];
    symbol = arg4;
  else, % ERRORXY(X,Y,EX,EY) or ERRORXY(X,Y,{EXL EXU},EY)
    eyl = arg4;
    eyu = arg4;
    if iscell(arg3), % ERRORXY(X,Y,{EXL EXU},EY)
      exl = arg3{1};
      exu = arg3{2};
    else, % ERRORXY(X,Y,EX,EY)
      exl = arg3;
      exu = arg3;
    end;
    symbol = '-';
  end;
  y = arg2;
  x = arg1;
elseif nargin == 5, % ERRORXY(X,Y,EX,EY,LineSpec)
  if iscell(arg4), % ERRORXY(X,Y, ... ,{EYL EYU},LineSpec)
    eyl = arg4{1};
    eyu = arg4{2};
  else, % ERRORXY(X,Y, ... ,EY,LineSpec)
    eyl = arg4;
    eyu = arg4;
  end;
  if iscell(arg3), % ERRORXY(X,Y,{EXL EXU}, ... ,LineSpec)
    exl = arg3{1};
    exu = arg3{2};
  else, % ERRORXY(X,Y,EX, .... ,LineSpec)
    exl = arg3;
    exu = arg3;
  end;
  y = arg2;
  x = arg1;
  symbol = arg5;
end;

exl = abs(exl);
exu = abs(exu);
eyl = abs(eyl);
eyu = abs(eyu);
    
if ~isnumeric(x) |  ~isnumeric(y) |  ~isnumeric(exl) |  ~isnumeric(exu) |  ~isnumeric(eyl) |  ~isnumeric(eyu)
  error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~(isequal(size(x),size(exl)) | isempty(exl)) ...
                             | ~(isequal(size(x),size(exu)) | isempty(exu)) ...
                             | ~(isequal(size(x),size(eyl)) | isempty(eyl)) ...
                             | ~(isequal(size(x),size(eyu)) | isempty(eyu)),
  error('The sizes of X, Y, EXL, EXU, EYL and EYU must be the same.');
end

if size(x,1)==1,
  x = transpose(x);
  y = transpose(y);
  exu = transpose(exu);
  exl = transpose(exl);
  eyu = transpose(eyu);
  eyl = transpose(eyl);
end;
[m,n]=size(x);

% Plot graph and bars
hold_state = ishold;
cax = newplot;
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
teeX = (max(x(:))-min(x(:)))/100;  % make tee .01 x-distance for error bars
if ~isempty(exl),
  teeY = (max(y(:))-min(y(:)))/100;  % make tee .01 y-distance for error bars
  teeX = max(teeX,teeY);
  teeY = teeX;
end;

if isempty(eyl),
  xb=[];
  yb=[];
else,
  Txl = x - teeX;
  Txr = x + teeX;
  ytop = y + eyu;
  ybot = y - eyl;
  n = size(y,2);

  xb = zeros(m*9,n);
  xb(1:9:end,:) = x;
  xb(2:9:end,:) = x;
  xb(3:9:end,:) = NaN;
  xb(4:9:end,:) = Txl;
  xb(5:9:end,:) = Txr;
  xb(6:9:end,:) = NaN;
  xb(7:9:end,:) = Txl;
  xb(8:9:end,:) = Txr;
  xb(9:9:end,:) = NaN;
  
  yb = zeros(m*9,n);
  yb(1:9:end,:) = ytop;
  yb(2:9:end,:) = ybot;
  yb(3:9:end,:) = NaN;
  yb(4:9:end,:) = ytop;
  yb(5:9:end,:) = ytop;
  yb(6:9:end,:) = NaN;
  yb(7:9:end,:) = ybot;
  yb(8:9:end,:) = ybot;
  yb(9:9:end,:) = NaN;
end;

if isempty(exl),
  xb2=[];
  yb2=[];
else,
  xlef = x - exl;
  xrig = x + exu;
  Tyt = y + teeY;
  Tyb = y - teeY;
  n = size(y,2);

  xb2 = zeros(m*9,n);
  xb2(1:9:end,:) = xlef;
  xb2(2:9:end,:) = xrig;
  xb2(3:9:end,:) = NaN;
  xb2(4:9:end,:) = xlef;
  xb2(5:9:end,:) = xlef;
  xb2(6:9:end,:) = NaN;
  xb2(7:9:end,:) = xrig;
  xb2(8:9:end,:) = xrig;
  xb2(9:9:end,:) = NaN;
  
  yb2 = zeros(m*9,n);
  yb2(1:9:end,:) = y;
  yb2(2:9:end,:) = y;
  yb2(3:9:end,:) = NaN;
  yb2(4:9:end,:) = Tyt;
  yb2(5:9:end,:) = Tyb;
  yb2(6:9:end,:) = NaN;
  yb2(7:9:end,:) = Tyt;
  yb2(8:9:end,:) = Tyb;
  yb2(9:9:end,:) = NaN;
end;

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot([xb;xb2],[yb;yb2],esymbol); hold on
h = [h;plot(x,y,symbol)]; 

if ~hold_state, hold off; end

if nargout>0, hh = h; end
