function wsmngr(cmd),
% WSMNGR Workspace manager

if nargin==0,
  cmd='initialize';
end;

switch(cmd),
case 'initialize',
  ui_wsmngr;
case 'close',
  close(gcbf);
case 'refresh',
  varlist=findobj(gcbf,'tag','varlist');
  vars=evalin('base','whos');
  if isempty(vars),
    set(varlist,'string','','enable','off','userdata','','value',[]);
  else,
    varnames={vars.name};
    for i=1:length(vars),
      sz=evalin('base',['size(' vars(i).name ')']);
      sz=sprintf('%ix',sz);
      if evalin('base',['isglobal(' vars(i).name ')']),
        glob=' (global)';
      else,
        glob='';
      end;
      longvarnames{i}=[vars(i).name ' [' sz(1:(end-1)) ' ' vars(i).class ']: ' num2str(vars(i).bytes) ' bytes' glob];
    end;
    set(varlist,'string',longvarnames,'value',1,'userdata',varnames,'enable','on');
  end;
case 'clear',
  varlist=findobj(gcbf,'tag','varlist');
  varnames=get(varlist,'userdata');
  if ~isempty(varnames),
    var=get(varlist,'value');
    evalin('base',['clear' sprintf(' %s',varnames{var}) ]);
    wsmngr('refresh');
  end;
case 'edit',
  varlist=findobj(gcbf,'tag','varlist');
  varnames=get(varlist,'userdata');
  if ~isempty(varnames),
    var=get(varlist,'value');
    if length(var)>1,
      uiwait(msgbox('Please select just one variable to edit.','modal'));
      return;
    end;
    if evalin('base',['exist(''' varnames{var} ''',''var'')']),
      evalin('base',[varnames{var} '=md_edit(' varnames{var} ');']);
    else,
      wsmngr('refresh');
    end;
  end;
end;