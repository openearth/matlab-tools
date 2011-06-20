function xx_counter(Hcounter,Value);
% XX_COUNTER draws a counter with two decimals for the specified Value.
%   XX_COUNTER(AxesHandle,Value)
%     Plots the specified Value in the specified Axes
%     The Value should be a number, e.g. time in hours.

if nargin<1,
  error('not enough input parameters.');
elseif nargin<2,
  Value=0;
end;

B=findobj(Hcounter,'tag','BackgroundPlateClock');

if isempty(B),
  
  set(Hcounter,'visible','off','dataaspectratio',[1 3 1],'xlim',[-1 1],'ylim',[-1 1]);

  % Threshold value should be about 0.49 when used in combination with %.0f
  ST=inputdlg({'Threshold value:','Format:'},'',[1;1],{'0.0','%5.2f'});
  UD.Format=ST{2};
  ST=eval(ST{1},'NaN');
  if ~isequal(size(ST),[1 1]) | ~isfinite(ST) | ~isreal(ST),
    fprintf(1,'Using default: 0.0');
    ST=0.0;
  end;
  UD.StartTime=ST;

  % background plate
  B=patch([-1 1 1 -1],[-1 -1 1 1],-ones(1,4),'facecolor','w','parent',Hcounter,'tag','BackgroundPlateClock','clipping','off');
  
  TT=text(0,0,sprintf(UD.Format,999), ...
     'color','k', ...
     'fontunits','normalized', ...
     'fontsize',1, ...
     'horizontalalignment','center', ...
     'verticalalignment','middle', ...
     'parent',Hcounter, ...
     'clipping','off', ...
     'tag','ValueText');
  xt=get(TT,'extent');
  set(TT,'fontsize',min(2/xt(3),2/xt(4)));
  if xt(3)>xt(4)
    set(B,'ydata',[-1 -1 1 1]*xt(4)/xt(3));
  else
    set(B,'xdata',[-1 1 1 -1]*xt(3)/xt(4));
  end
  set(B,'userdata',UD);
else,
  TT=findobj(Hcounter,'tag','ValueText');
  UD=get(B,'userdata');
  ST=UD.StartTime;
end;

if Value>ST,
  val=Value-ST;
else,
  val=0;
end;
Frmt='%5.2f';
if isfield(UD,'Format'), Frmt=UD.Format; end
set(TT,'string',sprintf(Frmt,val));
