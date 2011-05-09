function [Hpu]=popup(name,header,labels,callbacks,option1,option2)
%POPUP  Create a list of choices with uicontrols and callbacks.
%       POPUP('NAME',HEADER,BUTTONLABELS,CALLBACKS) creates
%       a window with registered name NAME. The window contains
%       the string HEADER and buttons labeled with BUTTONLABELS.
%       These buttons register callback strings from CALLBACKS.
%       An additional button, labeled 'Close', is added to each
%       choicelist. The option 'noclose' can be added as fifth
%       argument, in which case no CLOSE button is added.
%       By default POPUP waits for the pressing of one button. If
%       this is not desired, the option 'nowait' can be added. The
%       user should in that case take care of the closing of the
%       popup window after the selection has been made.
%       POPUP returns the number of the selected choice, or if
%       the 'nowait' option is used, the handle of the popup window.
%
%       Example:
%       header = 'Easy Example';
%       labels = str2mat('Choice 1','Choice 2','Choice 3');
%       callbacks = str2mat('image(magic(1))','image(magic(2))', ...
%                           'image(magic(3))');
%       popup('EXAMPLE', header, labels, callbacks);
%

%	Loren Shure, 8-14-92.
%	Copyright (c) 1984-93 by The MathWorks, Inc.
% Edited by H.R.A. Jagers, University of Twente, The Netherlands
closebutton=1;
choicewait=1;
if nargin < 4
	error('Not enough input arguments.');
elseif nargin > 4,
  if nargin > 6,
    error('Too many input arguments.');
  end;
  if strcmp(option1,'noclose'),
    closebutton=0;
  elseif strcmp(option1,'nowait'),
    choicewait=0;
  else,
    error(['Invalid option argument : ',gui_str(option1)]);
  end;
  if nargin > 5,
    if strcmp(option2,'noclose'),
      closebutton=0;
    elseif strcmp(option2,'nowait'),
      choicewait=0;
    else,
      error(['Invalid option argument : ',gui_str(option2)]);
    end;
  end;
end
c = computer;
if ~isstr(name) | ~isstr(header) | ~isstr(labels) | ~isstr(callbacks)
	error('Requires string arguments.');
end
uicok = strcmp(c(1:2),'PC') | strcmp(c(1:2),'MA');
if isunix | ~uicok   % could be VMS as well
	uicok = strcmp(lower(get(0,'TerminalProtocol')),'x');
end
%can't use uicontrols -use menu stuff instead- this is for terminals -UNIX & VMS
if ~uicok
   labels = str2mat(labels,'Done');
   nl = size(labels,1);
   % build up menu string for evaluation
   % fix quotes, if there are any
   ss = deblank(labels(1,:));
   ss = ss(sort([1:length(ss) find(ss=='''')]));
   args = ['''',ss,''''];
   header = header(sort([1:length(header) find(header=='''')]));
   for i = 2:nl
      ss = deblank(labels(i,:));
      ss = ss(sort([1:length(ss) find(ss=='''')]));
      args = [args, ',''', ss,''''];
   end
   k = 1;
   while k > 0 & k < nl
      eval(['k = menu(''',header,''',', args,');']);
      if k == nl | k == 0
         return
      else
         eval(callbacks(k,:));
      end
   end
end
% can use uicontrols
name = deblank(name);
xedge = 0;
ybord = 30;
width = 30;
yedge = 20;
height = 20;
avwidth = 4; % actually 6.8886 +/- 0.4887
imax = 1;
maxlen = max(size(labels,2),size(header,2));
twidth = 1.2*maxlen*avwidth;
% now figure out total dimensions needed so things can get placed in pixels
mwwidth = max(twidth + width + 2*xedge,94); % for PCWIN minimum width is 94
hdr=1;
if isempty(header)
  hdr=0;
end;
mwheight = (size(labels,1)+closebutton+hdr)*yedge;
ss = get(0,'ScreenSize');
swidth = ss(3); sheight = ss(4);
PointerLoc=get(0,'PointerLocation');
left = min(PointerLoc(1),swidth-mwwidth);
bottom = max(1,PointerLoc(2)-mwheight-ybord);
rect = [left bottom mwwidth mwheight];
i = findstr(name,':');
if ~isempty(i),
  label=name(1:i(1)-1);
else,
  label=name;
end;
fg = figure('Position',rect,'number','off', ...
       'name',upper(label),'resize','off','colormap',[],...
       'Menubar','none');
Hfg=['hex2num(''',num2hex(fg),''')'];

% Place header
header_pos(4)=1/(size(labels,1)+closebutton+hdr);      % height of text region
header_pos(3)=0.90;                                % 90 percent of window width available to text region
header_pos(2)=1.0-1/(size(labels,1)+closebutton+hdr);  % text region equal size as other buttons
header_pos(1)=0.05;                                % 5 percent of window left (and right) as border
if hdr
  hh = uicontrol(fg,'visible','off','position',[xedge  (size(labels,1)+closebutton)*yedge mwwidth-2*xedge height],'style','text','string',header,'visible','on');
  set(hh,'BackgroundColor',[0.7647 0.7647 0.7647]);
  gelm_font(hh);
end;

% resetting mouse position does not work in Matlab 5.1
% sb = ['global PopUPtempLoc; PopUPtempLoc=get(0,''pointerlocation'');'];
% se = ['figure(',Hfg,'); set(0,''pointerlocation'',PopUPtempLoc); clear global PopUPtempLoc'];
sb = '';
se = ['figure(',Hfg,');'];
for ii=size(labels,1):-1:1
  i = size(labels,1) + closebutton - ii;
  h1 = uicontrol(fg,'position',[xedge  i*yedge mwwidth-2*xedge height]);
  if choicewait,
    set(h1,'callback',[sb callbacks(ii,:) ';set(',Hfg,',''userdata'',',gui_str(ii),');' se])
  else,
    sb = ['set(',Hfg,',''visible'',''off''); close(',Hfg,');'];
    set(h1,'callback',[sb callbacks(ii,:)])
  end;
  set(h1,'string',[deblank(labels(ii,:))]);
  gelm_font(h1);
end
if closebutton,
  % Create Close button
  h1 = uicontrol(fg,'position',[xedge 0 mwwidth-2*xedge height]);
  set(h1,'string','Close');
  if choicewait,
    set(h1,'callback',[sb 'set(',Hfg,',''userdata'',',gui_str(size(labels,1)+1),');' se]);
  else,
    set(h1,'callback',['close(',Hfg,');']);
  end;
  gelm_font(h1);
end;

set(fg,'windowstyle','modal');
Q=[];
if choicewait,
  set(fg,'userdata',[]);
  while isempty(Q),
    waitfor(fg,'userdata');
    Q=get(fg,'userdata');
  end;
  close(fg);
end;

if nargout>0,
  if choicewait,
    Hpu=Q;
  else,
    Hpu=fg;
  end;
end;