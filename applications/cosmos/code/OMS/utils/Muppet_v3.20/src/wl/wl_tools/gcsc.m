function Sc=gcsc(Ax)
%GCSC Get current scaling of axes on paper
%     SC=GCSC(AxesHandle)
%     Default axes object is the current axes.
%     SC is a 1x3 vector containing the scale of the x-axis,
%     y-axis and z-axis. The scale is expressed as dataunits
%     per cm.

% (c) 2002, H.R.A.Jagers, bert.jagers@wldelft.nl
%     WL | Delft Hydraulics, The Netherlands

% Created: March 9, 2002.

if nargin==0
  Ax=gca;
end
P=get(Ax);
Sc=[NaN NaN NaN];

if strcmp(P.Projection,'orthographic') & strcmp(P.XScale,'linear') & strcmp(P.YScale,'linear') & strcmp(P.ZScale,'linear')
  switch P.Units
  case 'inches'
    cmPos=P.Position*2.53807;
  case 'centimeters'
    cmPos=P.Position;
  case 'normalized'
    Fg=get(Ax,'parent');
    Fpu=get(Fg,'paperunits');
    set(Fg,'paperunits','centimeters')
    FGcmPos=get(Fg,'paperposition');
    set(Fg,'paperunits',Fpu)
    cmPos=P.Position.*FGcmPos([3 4 3 4]);
  case 'points'
    cmPos=P.Position*0.03525097222222;
  case {'pixels','characters'}
    error(sprintf('The axes units ''%s'' not supported.',P.Units))
  end
  
  if isfield(P,'WarpToFill')
    WtF=strcmp(P.WarpToFill,'on');
  else
    WtF=0;
  end
  P.View=mod(P.View,360);
  if all(ismember(P.View,[0 90 180 270])) % 2D (more general interpretation of 2D than Matlab normally does)
    XYZ='XYZ';
    switch P.View(1)*1000+P.View(2)
    case {000000,000180,180000,180180}
      x=1;
      y=3;
    case {000090,000270,180090,180270}
      x=1;
      y=2;
    case {090000,090180,270000,270180}
      x=2;
      y=3;
    case {090090,090270,270090,270270}
      x=2;
      y=1;
    end
    xlimfixed=strcmp(getfield(P,[XYZ(x) 'LimMode']),'on');
    xlim=getfield(P,[XYZ(x) 'Lim']);
    xdiff=diff(xlim);
    ylimfixed=strcmp(getfield(P,[XYZ(y) 'LimMode']),'on');
    ylim=getfield(P,[XYZ(y) 'Lim']);
    ydiff=diff(ylim);
    if ~strcmp(P.DataAspectRatioMode,'auto') & ~WtF
      dar=P.DataAspectRatio;
      if xdiff*dar(y)/(ydiff*dar(x))>cmPos(3)/cmPos(4) % x limiting
        nPos=cmPos(3)*ydiff*dar(x)/(xdiff*dar(y));
        cmPos(2)=cmPos(2)+(cmPos(4)-nPos)/2;
        cmPos(4)=nPos;
      else % y limiting
        nPos=cmPos(4)*xdiff*dar(y)/(ydiff*dar(x));
        cmPos(1)=cmPos(1)+(cmPos(3)-nPos)/2;
        cmPos(3)=nPos;
      end
    elseif ~strcmp(P.PlotBoxAspectRatioMode,'auto') & ~WtF
      pbar=P.PlotBoxAspectRatio;
      if pbar(x)/pbar(y)>cmPos(3)/cmPos(4) % x limiting
        nPos=cmPos(3)*pbar(y)/pbar(x);
        cmPos(2)=cmPos(2)+(cmPos(4)-nPos)/2;
        cmPos(4)=nPos;
      else % y limiting
        nPos=cmPos(4)*pbar(x)/pbar(y);
        cmPos(1)=cmPos(1)+(cmPos(3)-nPos)/2;
        cmPos(3)=nPos;
      end
    end
    Sc(1,1:3)=inf;
    Sc(x)=xdiff/cmPos(3);
    Sc(y)=ydiff/cmPos(4);
    %  aaa=axes('parent',P.Parent,'units','centimeter','position',cmPos,'color','none','box','on','xcolor','r','ycolor','r','zcolor','r');
  else
    x = [0  1  1  0  0  0  1  1  0  0  1  1  1  1  0  0];
    y = [0  0  1  1  0  0  0  1  1  0  0  0  1  1  1  1];
    z = [0  0  0  0  0  1  1  1  1  1  1  0  0  1  1  0];
    xlim=P.XLim; xrange=diff(xlim); x=xlim(1)+x*xrange;
    ylim=P.YLim; yrange=diff(ylim); y=ylim(1)+y*yrange;
    zlim=P.ZLim; zrange=diff(zlim); z=zlim(1)+z*zrange;
    A=get(Ax,'xform');
    [m,n] = size(x);
    x4d = [x(:),y(:),z(:),ones(m*n,1)]';
    x2d = A*x4d;
    x2 = zeros(m,n); y2 = zeros(m,n);
    x2(:) = x2d(1,:)./x2d(4,:);
    y2(:) = x2d(2,:)./x2d(4,:);
    %  aaa=axes('parent',P.Parent,'units','centimeter','position',cmPos,'color','none','box','on','xcolor','r','ycolor','r','zcolor','r');
    %  line(x2,y2,'parent',aaa)
    %  set(aaa,'xlim',[min(x2(:)) max(x2(:))],'ylim',[min(y2(:)) max(y2(:))],'vis','off')
    %  if (strcmp(P.DataAspectRatioMode,'manual') | strcmp(P.PlotBoxAspectRatioMode,'manual')) & ~WtF
    %    set(aaa,'da',[1 1 1]);
    %  end
    x2diff=diff([min(x2(:)) max(x2(:))]);
    y2diff=diff([min(y2(:)) max(y2(:))]);
    if (strcmp(P.DataAspectRatioMode,'manual') | strcmp(P.PlotBoxAspectRatioMode,'manual')) & ~WtF
      if x2diff/y2diff>cmPos(3)/cmPos(4) % x limiting
        nPos=cmPos(3)*y2diff/x2diff;
        cmPos(2)=cmPos(2)+(cmPos(4)-nPos)/2;
        cmPos(4)=nPos;
      else % y limiting
        nPos=cmPos(4)*x2diff/y2diff;
        cmPos(1)=cmPos(1)+(cmPos(3)-nPos)/2;
        cmPos(3)=nPos;
      end
    end
    Sc(1,1:3)=inf;
    iSc2x=cmPos(3)/x2diff;
    iSc2y=cmPos(4)/y2diff;
    % Scale X
    xdx=abs(x2(2)-x2(1));
    ydx=abs(y2(2)-y2(1));
    cmdx=sqrt((iSc2x*xdx)^2+(iSc2y*ydx)^2);
    if cmdx~=0, Sc(1)=xrange/cmdx; end
    % Scale Y
    xdy=abs(x2(4)-x2(1));
    ydy=abs(y2(4)-y2(1));
    cmdy=sqrt((iSc2x*xdy)^2+(iSc2y*ydy)^2);
    if cmdy~=0, Sc(2)=yrange/cmdy; end
    % Scale Z
    xdz=abs(x2(6)-x2(1));
    ydz=abs(y2(6)-y2(1));
    cmdz=sqrt((iSc2x*xdz)^2+(iSc2y*ydz)^2);
    if cmdz~=0, Sc(3)=zrange/cmdz; end
  end
end