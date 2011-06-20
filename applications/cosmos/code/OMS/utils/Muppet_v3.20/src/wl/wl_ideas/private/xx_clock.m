function xx_clock(Hclock,Time);
% XX_CLOCK draws a clock for the specified time.
%   XX_CLOCK(AxesHandle,Time)
%     Plots the specified Time in the specified Axes
%     The Time can be either a vector of length three
%     [Hour Minutes Seconds] or a vector of length six
%     [? ? ? Hour Minutes Seconds]. The last vector is
%     compatible with the clock command.
%     If the Axes already contain a clock that clock
%     is updated with the specified Time.
%   XX_CLOCK(AxesHandle)
%     Assumes XX_CLOCK(AxesHandle,clock) i.e. uses
%     the current time.
%   XX_CLOCK
%     Assumes XX_CLOCK(gca,clock) i.e. plots the time
%     in the current axes.

if nargin==0,
  Hclock=gca;
end;
if nargin<2,
  Time=clock;
elseif length(Time(:))==1,
  Time=datevec(Time);
end;
if length(Time(:))==6,
  second=Time(6);
  minute=Time(5);
  hour=Time(4);
elseif length(Time(:))==3,
  second=Time(3);
  minute=Time(2);
  hour=Time(1);
end;

B=findobj(Hclock,'tag','BackgroundPlateClock');

if isempty(B),  
  set(Hclock,'visible','off','dataaspectratio',[1 1 1],'xlim',[-1 1],'ylim',[-1 1]);
  
  % background plate
  X=sin(0:.1:(2*pi));
  Y=cos(0:.1:(2*pi));
  B=patch(X,Y,-ones(size(X)),'facecolor','w','parent',Hclock,'tag','BackgroundPlateClock','clipping','off');
  
  % hour ticks
  XH=sin((1:12)*(2*pi)/12);
  YH=cos((1:12)*(2*pi)/12);
  HT=line([.9*XH; .85*XH],[.9*YH;.85*YH],'color','k','parent',Hclock,'clipping','off');
  
  %hands and indicators
  SH=line(0.8*[0 0],0.8*[0 1], ...
     'color','r', ...
     'parent',Hclock, ...
     'clipping','off', ...
     'tag','SecondsHand');
  MH=line(0.9*[0 0],0.9*[0 1], ...
     'color','k', ...
     'parent',Hclock, ...
     'clipping','off', ...
     'tag','MinutesHand');
  HH=line(0.5*[0 0],0.5*[0 1], ...
     'color','k', ...
     'linewidth',1.5, ...
     'parent',Hclock, ...
     'clipping','off', ...
     'tag','HoursHand');
  AM=text(0.5,0,'AM', ...
     'color','k', ...
     'fontunits','normalized', ...
     'fontsize',.1, ...
     'horizontalalignment','center', ...
     'verticalalignment','middle', ...
     'parent',Hclock, ...
     'clipping','off', ...
     'tag','AM/PMIndicator');

   ST=inputdlg('Reference time (t=0):','',1,{'0.0'});
   ST=eval(ST{1},'NaN');
   if ~isequal(size(ST),[1 1]) | ~isfinite(ST) | ~isreal(ST),
     fprintf(1,'Using default: 0.0');
     ST=0.0;
   end;
   UD.StartTime=ST;
   set(B,'userdata',UD);

else,
  SH=findobj(Hclock,'tag','SecondsHand');
  MH=findobj(Hclock,'tag','MinutesHand');
  HH=findobj(Hclock,'tag','HoursHand');
  AM=findobj(Hclock,'tag','AM/PMIndicator');

  UD=get(B,'userdata');
  ST=UD.StartTime;
end;

set_xx_clock(SH,MH,HH,AM,hour,minute,second,ST);

%drawnow;
%for hour=0:12,
% for minute=0:59,
%  for second=0:15:59;
%   set_xx_clock(SH,MH,HH,AM,hour,minute,second);
%  end;
% end;
%end;

function set_xx_clock(SH,MH,HH,AM,hour,minute,second,reftime),
time=hour+minute/60+second/3600+reftime;
if time<0,
  time=time+24;
elseif time>24,
  time=time-24;
end;
hour=floor(time);
time=(time-hour)*60;
minute=floor(time);
second=(time-minute)*60;
set(SH,'xdata',0.8*[0 sin(second*2*pi/60)],'ydata',0.8*[0 cos(second*2*pi/60)]);
set(MH,'xdata',0.9*[0 sin((minute+second/60)*2*pi/60)],'ydata',0.9*[0 cos((minute+second/60)*2*pi/60)]);
set(HH,'xdata',0.5*[0 sin((hour+minute/60+second/3600)*2*pi/12)],'ydata',0.5*[0 cos((hour+minute/60+second/3600)*2*pi/12)]);
if hour<12,
  set(AM,'string','AM'),
else,
  set(AM,'string','PM'),
end;
