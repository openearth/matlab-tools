function h=gelm_text1(fig,cmdname,hInd,vInd,visible,enable,text1,cmd);
if all(nargin~=[7 8]),
  error('Incorrect number of input parameters');
end;
coltext=gelm_col('text');
if nargin==8,
  cmdstring=[cmdname,'(gcbf,',gui_str(cmd),')'];
else,
  cmdstring='';
end;
vPos=gelm_vpos(vInd);
hPos=gelm_hpos(0,hInd);
vPos(4)=18;
if 1, % Version 5.1: isunix,
  cb_or_bdf='callback';
  activestyle='pushbutton';
else,
  cb_or_bdf='buttondownfcn';
  activestyle='text';
end;
h=uicontrol('visible',visible, ...
   'units','pixels', ...
   'position',vPos+hPos, ...
   'style',logicalswitch(isempty(cmdstring),'text',activestyle), ...
   'backgroundcolor',coltext, ...
   'horizontalalignment','left', ...
   'string',text1, ...
   'enable',enable, ...
   cb_or_bdf,cmdstring, ...
   'parent',fig);
gelm_font(h);
