function xx_timbar(Htimbar,Cmd,Begin,Now,End);
% XX_TIMBAR draws a time bar.
%   XX_TIMBAR(AxesHandle,Cmd,Begin,Now,End)
%     Draws a time bar in the specified Axes with
%     the value Now as progress of the bar from
%     left (Begin) to right (End).
%     If Cmd is,  The effect will be,
%      'values'    The values Begin and End are
%                  plotted above the time bar.
%      'dates'     The dates Begin and End are
%                  plotted above the time bar.
%      'datediff'  The time difference is plotted
%                  above the time bar.
%   XX_TIMBAR(AxesHandle,Now)
%     Updates the progress of the time bar specified
%     by the axes handle.
%   XX_TIMBAR(AxesHandle)
%     Uses Now is the current time.
%   XX_TIMBAR
%     uses the current axes.

if nargin==0,
  Htimbar=gca;
end;
if nargin==5,
  if End<Begin,
    Temp=Begin;
    Begin=End;
    End=Temp;
  end;
  if isempty(strmatch(Cmd,{'values','dates','datediff'})),
    error('Second parameter invalid.');
  end;
  Local_timbar_init(Htimbar,Cmd,Begin,Now,End);
elseif nargin==2,
  Time=Cmd;
  if length(Time(:))==6,
    Now=datenum(Time);
  elseif length(Time(:))==3,
    Now=datenum([transpose(Time(:)) 0 0 0]);
  elseif length(Time(:))==1,
    Now=Time;
  else,
    error('Invalid progress ''Now'' specified.');
  end;
elseif nargin<2,
  Now=now;
  if nargin==1,
    Htimbar=gca;
  end;
end;

B=findobj(Htimbar,'tag','BackgroundPlateTimBar');

if isempty(B),
  error('No time bar specified.');
end;

TBP=findobj(Htimbar,'tag','TimBarPatch');

options=get(B,'userdata');

Diff=options.End-options.Begin;
NowDiff=min(max(Now-options.Begin,0),Diff);
if Diff==0,
  Prog=((Now-options.Begin)>0);
else,
  Prog=NowDiff/Diff;
end;

set(TBP,'xdata',0.01+[0 0 1 1]*0.98*Prog);

function Local_timbar_init(Htimbar,Cmd,Begin,Now,End);

Diff=End-Begin;
NowDiff=min(max(Now-Begin,0),Diff);

B=findobj(Htimbar,'tag','BackgroundPlateTimBar');

if isempty(B),
  
  set(Htimbar,'visible','off','xlim',[0 1],'ylim',[0 1]);
%  set(Htimbar,'box','on','xtick',[],'ytick',[],'xcolor',[.5 .5 .5],'ycolor',[.5 .5 .5],'color','none','visible','on');

  options.Begin=Begin;
  options.End=End;

  % background plate
  B=patch([0 0 1 1],[0 1 1 0],-[1 1 1 1], ...
      'facecolor','w', ...
      'parent',Htimbar, ...
      'tag','BackgroundPlateTimBar', ...
      'userdata',options, ...
      'clipping','off');

  % time bar patch area
  TBPA=patch(0.01+[0 0 1 1]*0.98,[0.1 0.5 0.5 0.1],-0.75*[1 1 1 1], ...
      'facecolor','none', ...
      'parent',Htimbar, ...
      'tag','TimBarPatchArea', ...
      'clipping','off');

  % time bar patch
  TBP=patch([0 0 0 0],[0.1 0.5 0.5 0.1],-0.5*[1 1 1 1], ...
      'facecolor','r', ...
      'parent',Htimbar, ...
      'tag','TimBarPatch', ...
      'clipping','off');
  
  %texts
  TLEFT=text(0.01,0.75,'', ...
     'color','k', ...
     'fontunits','points', ...
     'fontsize',6, ...
     'horizontalalignment','left', ...
     'verticalalignment','middle', ...
     'parent',Htimbar, ...
     'clipping','off', ...
     'tag','Text Left');

  TRIGHT=text(0.99,0.75,'', ...
     'color','k', ...
     'fontunits','points', ...
     'fontsize',6, ...
     'horizontalalignment','right', ...
     'verticalalignment','middle', ...
     'parent',Htimbar, ...
     'clipping','off', ...
     'tag','Text Right');

else, % reset
  options=get(B,'userdata');
  options.Begin=Begin;
  options.End=End;
  set(B,'userdata',options);

  TLEFT=findobj(Htimbar,'tag','Text Left');
  TRIGHT=findobj(Htimbar,'tag','Text Right');
end;

switch Cmd,
case 'values',
  set(TLEFT,'string',gui_str(Begin));
  set(TRIGHT,'string',gui_str(End));
case 'dates',
  set(TLEFT,'string',datestr(Begin,0));
  set(TRIGHT,'string',datestr(End,0));
case 'datediff',
  set(TLEFT,'string','');
  set(TRIGHT,'string',strdiff(Diff));
end;

function S=strdiff(Diff),
if Diff>360*2*100,
  S=[gui_str(Diff/(365*100)) ' centuries'];
elseif Diff>360*2,
  S=[gui_str(Diff/365) ' years'];
elseif Diff>30*3,
  S=[gui_str(Diff/30) ' months'];
elseif Diff>7*3,
  S=[gui_str(Diff/7) ' weeks'];
elseif Diff>1.1,
  S=[gui_str(Diff) ' days'];
elseif Diff>1.1/24,
  S=[gui_str(Diff*24) ' hours'];
elseif Diff>1.1/(24*60),
  S=[gui_str(Diff*(24*60)) ' minutes'];
else,
  S=[gui_str(Diff*(24*60*60)) ' seconds'];
end;
