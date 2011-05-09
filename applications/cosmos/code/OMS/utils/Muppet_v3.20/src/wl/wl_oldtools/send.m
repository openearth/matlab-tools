function send(figlist);
if nargin==0,
   shh=get(0,'showhiddenhandles');
   set(0,'showhiddenhandles','on');
   figlist=get(0,'currentfigure');
   set(0,'showhiddenhandles',shh);
elseif nargin>1,
  fprintf(1,'**** Unexpected number of arguments.\n');
  fprintf(1,'**** Print command canceled.\n\n');
  return;
end;

if isempty(figlist),
  fprintf(1,'**** No figures to be printed.\n\n');
  return;
end;
Printer=-1;
AllFigures=0;
i=0;
while i<length(figlist),
  i=i+1;
  if ishandle(figlist(i)),
    if strcmp(get(figlist(i),'type'),'figure'),
      hvis=get(figlist(i),'handlevisibility');
      set(figlist(i),'handlevisibility','on');
      figure(figlist(i));
      if Printer==-1,
        printers={'Create EPS colour file', ...
                  'High resolution TIFF', ...
                  'Default Windows printer (not on UNIX)', ...
                  'CK0LAS1 - HP Laserjet 4 (painters, 864 DPI)', ...
                  'CK0LAS1 - HP Laserjet 4 (150 DPI)', ...
                  'CK1LAS1 - HP Laserjet 4 (painters, 864 DPI)', ...
                  'CK1LAS1 - HP Laserjet 4 (150 DPI)', ...
                  'HK2LAS1 - HP Laserjet 5 (painters, 864 DPI)', ...
                  'HK2LAS1 - HP Laserjet 5 (150 DPI)', ...
                  'HK2LAS1 - HP Laserjet 5 (300 DPI)', ...
                  'HK2DJT1 - HP Deskjet 1200 (150 DPI)', ...
                  'HK2DJT1 - HP Deskjet 1200 (300 DPI)', ...
                  'HK4PJT1 - HP Paintjet 600 (150 DPI)'};
        Printer=gui_send(figlist(i),printers);

%        fprintf(1,' *N) Apply same answer (N) for all remaining figures\n\n');
%        if (length(Choice)>1) & (Choice(1)=='*'),
%          Printer=eval(Choice(2:length(Choice)),'-1');
%          AllFigures=1;
%        else,
%          Printer=eval([' ' Choice],'-1');
%        end;
      end;
      if Printer>length(printers),
%        fprintf(1,'**** Figure skipped.\n\n');
        if ~AllFigures,
          Printer='cancel';
        end;
      else,
        Printer=printers{Printer};
      end;
      switch Printer,
      case 'cancel',
        % nothing to do
      case 'Create EPS colour file',
        [fn,pn]=uiputfile('default.eps','Specify file name');
        fprintf(['**** Creating file %s%s ...'],pn,fn);
        try,
          eval(['print ',pn,fn,' -depsc;']);
          OK=1;
        catch,
          OK=0;
        end;
        if OK==1,
          fprintf(1,'done.\n\n ');
        else,
          fprintf(1,[char(7) '\n There was an error while trying to execute the command:\nprint ',pn,fn,' -depsc;\n\n ']);
        end;
      case 'High resolution TIFF',
        [fn,pn]=uiputfile('default.tif','Specify file name');
        if ischar(pn),
          prompt={'Resolution (DPI):'};
          def={'600'};
          lineNo=1;
          answer=inputdlg(prompt,'TIFF resolution',lineNo,def);
          if ~isempty(answer),
            answer=eval(answer{1},'NaN')
            if isnumeric(answer) & isequal(size(answer),[1 1]) & answer==round(answer) & answer>0 & answer<=1200,
              try,
                fprintf(['**** Creating file %s%s at resolution %i DPI ...'],pn,fn,answer);
                print([pn,fn],'-dtiff',['-r' num2str(answer)]);
                fprintf(1,'done.\n\n ');
              catch,
                fprintf(1,'error encoutered.\n\n ');
              end;
            else, % invalid DPI
            end;
          else, % cancel pressed
          end;
        end;
      otherwise,
        fprintf(1,'**** Printing ... ');
        tempfil=[tempname,'.'];
        ccd=cd;
        cd(tempdir);
        switch Printer,
        case 'Default Windows printer (not on UNIX)',
          if ~isunix,
            paperpos=get(figlist(i),'paperposition');
            set(figlist(i),'paperposition',paperpos-[0.5 0 0.5 0]);
            print('-dwinc');
            set(figlist(i),'paperposition',paperpos);
          end;
        case 'CK0LAS1 - HP Laserjet 5 (painters, 864 DPI)',
          if ~isunix,
            print('-dps','-painters',tempfil);
            dos(['copy ',tempfil,' \\oeros\ck0las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dps','-painters','-ck0las1');
          end;
        case 'CK0LAS1 - HP Laserjet 4 (150 DPI)',
          if ~isunix,
            print('-dpsc',tempfil);
            dos(['copy ',tempfil,' \\oeros\ck0las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-Pck0las1');
          end;
        case 'CK1LAS1 - HP Laserjet 5 (painters, 864 DPI)',
          if ~isunix,
            print('-dps','-painters',tempfil);
            dos(['copy ',tempfil,' \\oeros\ck1las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dps','-painters','-ck1las1');
          end;
        case 'CK1LAS1 - HP Laserjet 4 (150 DPI)',
          if ~isunix,
            print('-dpsc',tempfil);
            dos(['copy ',tempfil,' \\oeros\ck1las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-Pck1las1');
          end;
        case 'HK2LAS1 - HP Laserjet 5 (painters, 864 DPI)',
          if ~isunix,
            print('-dps','-painters',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk2las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dps','-painters','-Phk2las1');
          end;
        case 'HK2LAS1 - HP Laserjet 5 (150 DPI)',
          if ~isunix,
            print('-dpsc',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk2las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-Phk2las1');
          end;
        case 'HK2LAS1 - HP Laserjet 5 (300 DPI)',
          if ~isunix,
            print('-dpsc','-r300',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk2las1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-r300','-Phk2las1');
          end;
        case 'HK2DJT1 - HP Deskjet 1200 (150 DPI)',
          if ~isunix,
            print('-dpsc',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk2djt1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-Phk2djt1');
          end;
        case 'HK2DJT1 - HP Deskjet 1200 (300 DPI)',
          if ~isunix,
            print('-dpsc','-r300',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk2djt1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-r300','-Phk2djt1');
          end;
        case 'HK4PJT1 - HP Paintjet 600 (150 DPI)',
          if ~isunix,
            print('-dpsc',tempfil);
            dos(['copy ',tempfil,' \\sv01wld\hk4pjt1 /b | del ',tempfil,' | exit &']);
          else,
            print('-dpsc','-Phk4pjt1');
          end;
        otherwise,
          fprintf(1,'PRINTER NOT FOUND ...');
        end;
        cd(ccd);
        fprintf(1,'... done.\n\n ');
      end;
      set(figlist(i),'handlevisibility',hvis);
      if ~AllFigures,
        Printer=-1;
      end;
    end;
  end;
end;

function sdim=gui_send(hfig,printers),
% similar to gui_select

sdim=[];
nocancel=0;

if nargin~=2,
  fprintf(1,'* Two input arguments expected.\n');
  return;
end;
if iscell(printers),
  printers=str2mat(printers{:});
end;

LightGray=[1 1 1]*192/255;

nsel=1;
ndim=size(printers,1);

Fig_Width=max(60+7*(size(printers,2)+4),200);
Field_Height=20;
Margin=20;
Fig_Height=Field_Height*(ndim+2);

ss = get(0,'ScreenSize');
swidth = ss(3);
sheight = ss(4);
left = (swidth-Fig_Width)/2;
bottom = (sheight-Fig_Height)/2;
rect = [left bottom Fig_Width Fig_Height];

fig=figure('menu','none');
set(fig,'units','pixels', ...
        'position',rect, ...
        'color',LightGray, ...
        'inverthardcopy','off', ...
        'closerequestfcn','', ...
        'resize','off', ...
        'numbertitle','off', ...
        'handlevisibility','off', ...
        'name','Print to ...', ...
        'tag','Send Window');

for dim=1:ndim,
  Str=sprintf('%s',deblank(printers(dim,:)));
  rb(dim)=uicontrol('style','radiobutton', ...
            'position',[Margin Fig_Height-(1+dim)*Field_Height Fig_Width-2*Margin Field_Height], ...
            'parent',fig, ...
            'string',Str, ...
            'callback',['set(gcbf,''userdata'',',gui_str(dim),')']);
  gelm_font(rb(dim));
end;

Str=['Figure ',gui_str(hfig),': ',get(hfig,'name')];
h=uicontrol('style','text', ...
            'position',[Margin Fig_Height-Field_Height Fig_Width-2*Margin Field_Height], ...
            'string',Str, ...
            'parent',fig);
gelm_font(h);
if nocancel,
  h=uicontrol('style','pushbutton', ...
              'position',[Margin 0 Fig_Width-2*Margin Field_Height], ...
              'string','continue', ...
              'parent',fig, ...
              'callback','set(gcbf,''userdata'',0)');
  gelm_font(h);
else,
  hcanc=uicontrol('style','pushbutton', ...
                  'position',[Margin 0 Fig_Width/2-Margin Field_Height], ...
                  'string','cancel', ...
                  'parent',fig, ...
                  'callback','set(gcbf,''userdata'',-1)');
  gelm_font(hcanc);
  h=uicontrol('style','pushbutton', ...
              'position',[Fig_Width/2 0 Fig_Width/2-Margin Field_Height], ...
              'string','continue', ...
              'parent',fig, ...
              'callback','set(gcbf,''userdata'',0)');
  gelm_font(h);
end;

while isempty(sdim),
  waitfor(fig,'userdata');
  PresRB=get(fig,'userdata');
  if PresRB<0, % cancel
    sdim=ndim+1;
    break;
  end;
  if ~PresRB,
    for dim=1:ndim,
      if get(rb(dim),'value')==1,
        sdim=[sdim dim];
      end;
    end;
    if isempty(sdim),
      Str=sprintf('Please select printer or cancel.');
      uiwait(msgbox(Str,'modal'));
      set(fig,'userdata',[]);
      sdim=[];
    end;
  else,
    for dim=1:ndim,
      if get(rb(dim),'value')==1,
        sdim=[sdim dim];
      end;
    end;
    if length(sdim)~=1,
      for dim=1:length(sdim),
        if sdim(dim)~=PresRB,
          set(rb(sdim(dim)),'value',0);
        end;
      end;
    end;
    sdim=[];
  end;
end;
delete(fig);