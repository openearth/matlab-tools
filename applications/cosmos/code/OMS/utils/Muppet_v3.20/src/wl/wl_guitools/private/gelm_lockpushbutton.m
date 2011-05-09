function h=gelm_lockpushbutton(fig,cmdname,hInd,vInd,visible,enable,text1,cmd1,cmd2);
if all(nargin~=[7 8 9]),
  error('Incorrect number of input parameters');
end;
vPos=gelm_vpos(vInd);
hPos=gelm_hpos(hInd,0);
if nargin==9,
  cmd1string=[cmdname,'(gcbf,',gui_str(cmd1),')'];
  if strcmp(enable,'on'),
    cmd2string=[cmdname,'(gcbf,',gui_str(cmd2),')'];
  else,
    cmd2string='';
  end;
elseif nargin==8,
  cmd1string='';
  if strcmp(enable,'on'),
    cmd2string=[cmdname,'(gcbf,',gui_str(cmd1),')'];
  else,
    cmd2string='';
  end;
else,
  cmd1string='';
  cmd2string='';
end;
Pos=hPos+vPos;
lPos=Pos;
lPos(1)=lPos(1)+lPos(3)-lPos(4);
lPos(3)=lPos(4);
if isunix,
  cb_or_bdf='callback';
else,
  cb_or_bdf='buttondownfcn';
end;
Pos(3)=Pos(3)-Pos(4);
h(1)=uicontrol('visible',visible, ...
   'units','pixels', ...
   'position',Pos, ...
   'style','pushbutton', ...
   'horizontalalignment','center', ...
   'string',text1, ...
   'enable','off', ...
   'callback',cmd1string, ...
   'parent',fig);
h(2)=uicontrol('visible',visible, ...
   'units','pixels','position',lPos, ...
   'style',logicalswitch(isunix,'pushbutton','frame'), ...
   'backgroundcolor',[0 1 0], ...
   'enable',logicalswitch(strcmp(enable,'on'),logicalswitch(isunix,'on','inactive'),'off'), ...
   cb_or_bdf,cmd2string, ...
   'parent',fig);

gelm_font(h);


