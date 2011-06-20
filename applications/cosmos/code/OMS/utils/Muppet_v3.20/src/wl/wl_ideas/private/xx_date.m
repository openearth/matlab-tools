function xx_date(Hclock,Date);
% XX_DATE draws a calender for the specified date.
%   XX_DATE(AxesHandle,Date)
%     Plots the specified Date in the specified Axes
%     where Date is either a datevector as returned
%     by the 'clock' command or a daynumber as returned
%     by 'now'
%   XX_DATE(AxesHandle)
%     Assumes XX_DATE(AxesHandle,clock) i.e. uses
%     the current date.
%   XX_DATE
%     Assumes XX_DATE(gca,clock) i.e. plots the
%     date in the current axes.

if nargin==0,
  Hclock=gca;
end;
if nargin<2,
  Date=clock;
elseif length(Date(:))==1,
  Date=datevec(Date);
end;

B=findobj(Hclock,'tag','BackgroundPlateCalendar');

if isempty(B),
  
  set(Hclock,'visible','off','dataaspectratio',[1 1 1],'xlim',[-1 1],'ylim',[-1 1]);
  
  % background plate
  B=patch([-1 -1 1 1],[-1 1 1 -1],-ones(1,4),'facecolor','w','parent',Hclock,'tag','BackgroundPlateCalendar','clipping','off');
  
  %indicators
  WD=text(0,.6,'WD', ...
      'color','k', ...
      'fontunits','normalized', ...
      'fontsize',0.1, ...
      'horizontalalignment','center', ...
      'verticalalignment','middle', ...
      'tag','Weekday', ...
      'parent',Hclock,'clipping','off');
  D=text(0,.2,'D', ...
      'color',[1 0 0], ...
      'fontunits','normalized', ...
      'fontsize',0.25, ...
      'fontweight','bold', ...
      'horizontalalignment','center', ...
      'verticalalignment','middle', ...
      'tag','Day', ...
      'parent',Hclock,'clipping','off');
  M=text(0,-0.2,'M', ...
      'color','k', ...
      'fontunits','normalized', ...
      'fontsize',0.15, ...
      'horizontalalignment','center', ...
      'verticalalignment','middle', ...
      'tag','Month', ...
      'parent',Hclock,'clipping','off');
  Y=text(0,-.6,'Y', ...
      'color','k', ...
      'fontunits','normalized', ...
      'fontsize',0.15, ...
      'horizontalalignment','center', ...
      'verticalalignment','middle', ...
      'tag','Year', ...
      'parent',Hclock,'clipping','off');

   ST=inputdlg('Reference time (t=0):','',1,{'0.0'});
   ST=eval(ST{1},'NaN');
   if ~isequal(size(ST),[1 1]) | ~isfinite(ST) | ~isreal(ST),
     fprintf(1,'Using default: 0.0');
     ST=0.0;
   end;
   UD.StartTime=ST;
   set(B,'userdata',UD);

else,
  WD=findobj(Hclock,'tag','Weekday');
  D=findobj(Hclock,'tag','Day');
  M=findobj(Hclock,'tag','Month');
  Y=findobj(Hclock,'tag','Year');

  UD=get(B,'userdata');
  ST=UD.StartTime;
end;

set_xx_date(WD,D,M,Y,Date,ST),

%for year=1998:2000,
% for month=1:12,
%  for day=1:eomday(year,month),
%   set_xx_date(WD,D,M,Y,day,month,year),
%  end;
% end;
%end;

function set_xx_date(WD,D,M,Y,DateVec,reftime),

daynum=datenum(DateVec(1),DateVec(2),DateVec(3),DateVec(4),DateVec(5),DateVec(6))+reftime;
daystr=str2mat('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');
monthstr=str2mat('January','February','March','April','May','June','July','August','September','October','November','December');
  
DateVec=datevec(daynum);
year=DateVec(1);
month=DateVec(2);
day=DateVec(3);
set(WD,'string',deblank(daystr(weekday(daynum),:)));
set(D,'string',int2str(day));
set(M,'string',deblank(monthstr(month,:)));
set(Y,'string',int2str(year));
