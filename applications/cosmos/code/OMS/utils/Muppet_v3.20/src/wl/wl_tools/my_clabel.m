function hh = clabel(cs,arg2,arg3)
%CLABEL Contour plot elevation labels.
%   ADAPTED: Fixed: Correction for rotation of axes. H.R.A.Jagers 8/8/1999
%
%   CLABEL(CS,H) adds height labels to the current contour
%   plot.  The labels are rotated and inserted within the contour
%   lines.  CS and H are the contour matrix output and object handle
%   outputs from CONTOUR, CONTOUR3, or CONTOURF.
%
%   CLABEL(CS,H,V) labels just those contour levels given in
%   vector V.  The default action is to label all known contours.
%   The label positions are selected randomly.
%
%   CLABEL(CS,H,'manual') places contour labels at the locations
%   clicked on with a mouse.  Pressing the return key terminates
%   labeling.  Use the space bar to enter contours and the arrow
%   keys to move the crosshair if no mouse is available.
%
%   CLABEL(CS) or CLABEL(CS,V) or CLABEL(CS,'manual') places
%   contour labels as above, except that the labels are drawn as
%   plus signs on the contour with a nearby height value.
%
%   H = CLABEL(...) returns handles to the TEXT (and possibly LINE)
%   objects created.  The UserData property of the TEXT objects contain
%   the height value for each label.
%
%   Uses code by R. Pawlowicz to handle inline contour labels.
%
%   Example
%      subplot(1,2,1), [cs,h] = contour(peaks); clabel(cs,h)
%      subplot(1,2,2), cs = contour(peaks); clabel(cs)
%
%   See also CONTOUR, CONTOUR3, CONTOURF.

%   Thanks to R. Pawlowicz (IOS) rich@ios.bc.ca for the algorithm used
%   in 'inline_labels' so that clabel can produce inline labeling.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$

if nargin == 0
    error('Not enough input arguments.')
end
if min(size(cs)) > 2
    error('First input must be a valid contour description matrix.')
end
threeD = IsThreeD(gca);

if nargin==1,
  h = plus_labels(threeD,cs);
elseif nargin==2,
  if ~isempty(arg2) & ishandle(arg2(1)) & ...
    (strcmp(get(arg2(1),'type'),'line') | strcmp(get(arg2(1),'type'),'patch'))
    h = inline_labels(cs,arg2);
  elseif ~isstr(arg2) | strcmp(arg2,'manual'),
    h = plus_labels(threeD,cs,arg2);
  else
    error('Invalid arguments.');
  end
elseif nargin==3,
  if ~isempty(arg2) & ~ishandle(arg2(1))
    error('H must contain valid handles.');
  end
  h = inline_labels(cs,arg2,arg3);
end

if nargout>0, hh = h; end
if ~ishold, 
  if threeD, view(3), else view(2), end
end

%--------------------------------------------------------------
function H = inline_labels(CS,h,v)
%
% Draw the labels along the contours and rotated to match the local slope.
%

% To open up space in the contours, we rely on the order in which
% the handles h are created in CONTOUR3.  If CONTOUR3 changes you
% might need to change the algorithm below.

% Author: R. Pawlowicz IOS rich@ios.bc.ca
%         12/12/94

nin = nargin;
if nargin==3 & isstr(v)
  manual = 1; nin = nin-1;
else
  manual = 0;
end

if strcmp(get(h(1),'type'),'patch') & ~strcmp(get(h(1),'facecolor'),'none'),
  isfilled = 1;
else
  isfilled = 0;
end

lab_int=72*2;  % label interval (points)

% Compute scaling to make sure printed output looks OK. We have to go via
% the figure's 'paperposition', rather than the the absolute units of the
% axes 'position' since those would be absolute only if we kept the 'units'
% property in some absolute units (like 'points') rather than the default
% 'normalized'.

UN=get(gca,'units');
if (UN(1:3)=='nor'),
  UN=get(gcf,'paperunits');
  set(gcf,'paperunits','points');
  PA=get(gcf,'paperposition');
  set(gcf,'paperunits',UN);
  PA=PA.*[get(gca,'position')];
else
  set(gca,'units','points');
  PA=get(gca,'pos');
  set(gca,'units',UN); 
end

% Find beginning of all lines

lCS=size(CS,2);

if ~isempty(get(gca,'children')),
  XL=get(gca,'xlim');
  YL=get(gca,'ylim');
else
  iL=[];
  k=1;
  XL=[Inf -Inf];
  YL=[Inf -Inf];
  while (k<lCS),
    x=CS(1,k+(1:CS(2,k)));
    y=CS(2,k+(1:CS(2,k)));
    XL=[ min([XL(1),x]) max([XL(2),x]) ];
    YL=[ min([YL(1),y]) max([YL(2),y]) ]; 
    iL=[iL k];
    k=k+CS(2,k)+1;
  end;
  set(gca,'xlim',XL,'ylim',YL);
end;

Aspx=PA(3)/diff(XL);  % To convert data coordinates to paper (we need
                      % to do this
Aspy=PA(4)/diff(YL);  % to get the gaps for text the correct size)

H=[];

% Set up a dummy text object from which you can get text extent info
H1=text(XL(1),YL(1),'dummyarg','units','points','visible','off');

% Decompose contour data structure if manual mode.

if manual
   disp(' '), disp('    Please wait a moment...')
   x = []; y = []; ilist = []; klist = []; plist = [];
   ii = 0; k = 0; n = 0;
   while (1)
      k = k + 1;
      ii = ii + n + 1; if ii > lCS, break, end
      c = CS(1,ii); n = CS(2,ii); nn = 2 .* n -1;
      xtemp = zeros(nn, 1); ytemp = zeros(nn, 1);
      xtemp(1:2:nn) = CS(1, ii+1:ii+n);
      xtemp(2:2:nn) = (xtemp(1:2:nn-2) + xtemp(3:2:nn)) ./ 2;
      ytemp(1:2:nn) = CS(2, ii+1:ii+n);
      ytemp(2:2:nn) = (ytemp(1:2:nn-2) + ytemp(3:2:nn)) ./ 2;
      x = [x; xtemp]; y = [y; ytemp];   % Keep these.
      ilist = [ilist; ii(ones(nn,1))];
      klist = [klist; k(ones(nn,1))];
      plist = [plist; (1:.5:n)'];
   end
   ax = axis; 
   xmin = ax(1); xmax = ax(2); ymin = ax(3); ymax = ax(4);
   xrange = xmax - xmin; yrange = ymax - ymin;
   xylist = (x .* yrange + sqrt(-1) .* y .* xrange);
   view(2)
   disp(' ');
   disp('   Carefully select contours for labeling.')
   disp('   When done, press RETURN while the Graph window is the active window.')
end

% Get labels all at once to get the length of the longest string.  
% This allows us to call extent only once, thus speeding up this routine
if ~manual, 
  labels = getlabels(CS);
  % Get the size of the label
  set(H1,'string',repmat('9',1,size(labels,2)),'visible','on')
  EX=get(H1,'extent'); set(H1,'visible','off')
  len_lab=EX(3)/2;
end

ii=1; k = 0;
while (ii<lCS),
  if manual
    [xx, yy, button] = ginput(1);
    if isempty(button) | isequal(button,13), break, end
    if xx < xmin | xx > xmax, break, end
    if yy < ymin | yy > ymax, break, end
    xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
    dist = abs(xylist - xy);
    [dum,f] = min(dist);
    if ~isempty(f)
      f = f(1);
      ii  = ilist(f);
      k   = klist(f);
      p   = floor(plist(f));
    end
  else
    k = k+1;
  end

  if ~isfilled & k>length(h), error('Not enough contour handles.'); end

  l=CS(2,ii);
  x=CS(1,ii+(1:l));
  y=CS(2,ii+(1:l));

  lvl=CS(1,ii);

  if manual
    lab=num2str(lvl);
    % Get the size of the label
    set(H1,'string',lab,'visible','on')
    EX=get(H1,'extent'); set(H1,'visible','off')
    len_lab=EX(3)/2;
  else
    lab=deblank(labels(k,:));
  end
  
  sx=x*Aspx;
  sy=y*Aspy;
  d=cumsum([0 sqrt(diff(sx).^2 +diff(sy).^2) ]);
      
  if ~manual
    psn=[max(len_lab,lab_int+lab_int*(rand(1)-.5)):lab_int:d(l)-len_lab];
  else
    psn = min(max(max(d(p),d(2)+eps*d(2)),d(1)+len_lab),d(end)-len_lab);
  end
  lp=size(psn,2);
  
  if (lp>0) & isfinite(lvl)  & ...
     (nin<3 | any(abs(lvl-v)/max(eps+abs(v)) < .00001)),
 
    Ic=sum( d(ones(1,lp),:)' < psn(ones(1,l),:) );
    Il=sum( d(ones(1,lp),:)' <= psn(ones(1,l),:)-len_lab );
    Ir=sum( d(ones(1,lp),:)' < psn(ones(1,l),:)+len_lab );
 
    Ir = max(0,min(Ir,length(d)-1));
    Il = max(0,min(Il,length(d)-1));
    Ic = max(0,min(Ic,length(d)-1));

    % Endpoints of text in data coordinates
    wl=(d(Il+1)-psn+len_lab)./(d(Il+1)-d(Il));
    wr=(psn-len_lab-d(Il)  )./(d(Il+1)-d(Il));
    xl=x(Il).*wl+x(Il+1).*wr;
    yl=y(Il).*wl+y(Il+1).*wr;
   
    wl=(d(Ir+1)-psn-len_lab)./(d(Ir+1)-d(Ir));
    wr=(psn+len_lab-d(Ir)  )./(d(Ir+1)-d(Ir));
    xr=x(Ir).*wl+x(Ir+1).*wr;
    yr=y(Ir).*wl+y(Ir+1).*wr;
   
    trot=atan2( (yr-yl)*Aspy, (xr-xl)*Aspx )*180/pi;
    backang=abs(trot)>90;
    trot(backang)=trot(backang)+180;
    cuv=get(get(h(1),'parent'),'cameraupvector'); % H.R.A.Jagers 8/8/1999:
    if ~isequal(cuv(1:2),[0 0]),                  % exception only possible for 3D
      trot=trot+180*atan2(cuv(1),cuv(2))/pi;      % <--- match axes rotation
    end;                                          %
    
    % Text location in data coordinates 

    wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
    wr=(psn-d(Ic)  )./(d(Ic+1)-d(Ic));    
    xc=x(Ic).*wl+x(Ic+1).*wr;
    yc=y(Ic).*wl+y(Ic+1).*wr;

    % Shift label over a little if in a curvy area
    shiftfrac=.5;
    
    xc=xc*(1-shiftfrac)+(xr+xl)/2*shiftfrac;
    yc=yc*(1-shiftfrac)+(yr+yl)/2*shiftfrac;
    
    % Remove data points under the label...
    % First, find endpoint locations as distances along lines
  
    dr=d(Ir)+sqrt( ((xr-x(Ir))*Aspx).^2 + ((yr-y(Ir))*Aspy).^2 );
    dl=d(Il)+sqrt( ((xl-x(Il))*Aspx).^2 + ((yl-y(Il))*Aspy).^2 );
  
    % Now, remove the data points in those gaps using that
    % ole' Matlab magic
    
    f1=zeros(1,l); f1(Il)=ones(1,lp);
    f2=zeros(1,l); f2(Ir)=ones(1,lp);
    irem=find(cumsum(f1)-cumsum(f2))+1;
    x(irem)=[];
    y(irem)=[];
    d(irem)=[];
    l=l-size(irem,2);
    
    % Put the points in the correct order...
    
    xf=[x(1:l),xl,repmat(NaN,size(xc)),xr];
    yf=[y(1:l),yl,yc,yr];

    [df,If]=sort([d(1:l),dl,psn,dr]);
  
    % ...and draw.
    %
    % Here's where we assume the order of the h(k).  
    %

    z = get(h(k),'zdata');
    if ~isfilled, % Only modify lines or patches if unfilled
      set(h(k),'xdata',[xf(If) NaN],'ydata',[yf(If) NaN])

      % Handle contour3 case (z won't be empty).
      if ~isempty(z), 
        set(h(k),'zdata',[]) % Work around for bug in face generation

        % Set z to a constant while preserving the location of NaN's
        set(h(k),'zdata',z(1)+0*get(h(k),'xdata'))
      end

      if strcmp(get(h(k),'type'),'patch')
        set(h(k),'cdata',lvl+[0*xf(If) 0])
      end
    end

    for jj=1:lp,
      % Handle contour3 case (z won't be empty).
      if ~isempty(z),
        H = [H;text(xc(jj),yc(jj),z(1),lab,'rotation',trot(jj), ...
             'verticalAlignment','middle','horizontalAlignment','center',...
             'clipping','on','userdata',lvl)];
      else
        H = [H;text(xc(jj),yc(jj),lab,'rotation',trot(jj), ...
             'verticalAlignment','middle','horizontalAlignment','center',...
             'clipping','on','userdata',lvl)];       
      end
    end;
  else
    if ~isfilled, % Only modify lines or patches if unfilled
      %
      % Here's another place where we assume the order of the h(k)
      %
      set(h(k),'xdata',[x NaN],'ydata',[y NaN])
      if strcmp(get(h(k),'type'),'patch')
         set(h(k),'cdata',lvl+[0*x 0])
      end
    end
  end;
  
  if ~manual
    ii=ii+1+CS(2,ii);
  end
end;
  
% delete dummy string
delete(H1);
%-------------------------------------------------------

%-------------------------------------------------------
function h = plus_labels(threeD,cs,v)
%
% Draw the labels as plus symbols next to text (v4 compatible)
%

%    Clay M. Thompson 6-7-96
%    Charles R. Denham, MathWorks, 1988, 1989, 1990.
cax = gca;
manual = 0;
choice = 0;

if nargin > 2
  if isstr(v)
    manual = strcmp(v, 'manual');
    if ~manual
      error('Invalid argument.');
    end
  else
    choice = 1;
    v = sort(v(:));
  end
end

[mcs, ncs] = size(cs);

% Find range of levels.
k = 1; i = 1;
while k <= ncs
   levels(i) = cs(1,k);
   i = i + 1;
   k = k + cs(2,k) + 1;
end
cmin = min(levels);
cmax = max(levels);
crange = max(abs(levels));
cdelta = abs(diff(levels)); 
cdelta = min(cdelta(cdelta > eps))/max(eps,crange); % Minimum significant change
if isempty(cdelta), cdelta = 0; end

% Decompose contour data structure if manual mode.

if manual
   disp(' '), disp('    Please wait a moment...')
   x = []; y = []; clist = []; k = 0; n = 0;
   while (1)
      k = k + n + 1; if k > ncs, break, end
      c = cs(1,k); n = cs(2,k); nn = 2 .* n -1;
      xtemp = zeros(nn, 1); ytemp = zeros(nn, 1);
      xtemp(1:2:nn) = cs(1, k+1:k+n);
      xtemp(2:2:nn) = (xtemp(1:2:nn-2) + xtemp(3:2:nn)) ./ 2;
      ytemp(1:2:nn) = cs(2, k+1:k+n);
      ytemp(2:2:nn) = (ytemp(1:2:nn-2) + ytemp(3:2:nn)) ./ 2;
      x = [x; xtemp]; y = [y; ytemp];   % Keep these.
      clist = [clist; c .* ones(2*n-1, 1)];
   end
   ax = axis; 
   xmin = ax(1); xmax = ax(2); ymin = ax(3); ymax = ax(4);
   xrange = xmax - xmin; yrange = ymax - ymin;
   xylist = (x .* yrange + sqrt(-1) .* y .* xrange);
   view(2)
   disp(' ');
   disp('   Carefully select contours for labeling.')
   disp('   When done, press RETURN while the Graph window is the active window.')
end

k = 0; n = 0; flip = 0; h = [];

while (1)

% Use GINPUT and select nearest point if manual.

   if manual
      [xx, yy, button] = ginput(1);
      if isempty(button) | isequal(button,13), break, end
      if xx < xmin | xx > xmax, break, end
      if yy < ymin | yy > ymax, break, end
      xy = xx .* yrange + sqrt(-1) .* yy .* xrange;
      dist = abs(xylist - xy);
      [dum,f] = min(dist);
      if length(f) > 0
         f = f(1); xx = x(f); yy = y(f); c = clist(f);
         okay = 1;
        else
         okay = 0;
      end
   end

% Select a labeling point randomly if not manual.

   if ~manual
      k = k + n + 1; if k > ncs, break, end
      c = cs(1, k); n = cs(2, k);
      if choice
         f = find(abs(c-v)/max(eps+abs(v)) < .00001);
         okay = length(f) > 0;
      else
         okay = 1;
      end
      if okay
         r = rand;
         j = fix(r.* (n - 1)) + 1;
         if flip, j = n - j; end
         flip = ~flip;
         if n == 1    % if there is only one point
           xx = cs(1, j+k); yy = cs(2, j+k);
         else
           x1 = cs(1, j+k); y1 = cs(2, j+k);
           x2 = cs(1, j+k+1); y2 = cs(2, j+k+1);
           xx = (x1 + x2) ./ 2; yy = (y1 + y2) ./ 2;  % Test was here; removed.
         end
      end
   end

% Label the point.

   if okay
      % Set tiny labels to zero.
      if abs(c) <= 10*eps*crange, c = 0; end
      % Determine format string number of digits
      if cdelta > 0, 
        ndigits = max(3,ceil(-log10(cdelta)));
      else
        ndigits = 3;
      end
      s = num2str(c,ndigits);
      hl = line('xdata',xx,'ydata',yy,'marker','+','erasemode','none');
      ht = text(xx, yy, s, 'verticalalignment', 'bottom', ...
             'horizontalalignment', 'left','erasemode','none', ...
             'clipping','on','userdata',c);
      if threeD, 
        set(hl,'zdata',c);
        set(ht,'position',[xx yy c]);
      end
      h = [h;hl];
      h = [h;ht];
   end
end
%-------------------------------------------------------

%-------------------------------------------------------
function labels = getlabels(CS)
%GETLABELS Get contour labels
v = []; i =1;
while i < size(CS,2), 
  v = [v,CS(1,i)];
  i = i+CS(2,i)+1;
end
labels = num2str(v');

%---------------------------------------------------
function threeD = IsThreeD(cax)
%ISTHREED  True for a contour3 plot
hp = findobj(cax,'type','patch');
if isempty(hp), hp = findobj(gca,'type','line'); end
if ~isempty(hp),
  % Assume a contour3 plot if z data not empty
  threeD = ~isempty(get(hp(1),'zdata'));
else
  threeD = 0;
end

