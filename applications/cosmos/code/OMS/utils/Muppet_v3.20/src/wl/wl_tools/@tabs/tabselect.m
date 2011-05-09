function tabselect(Obj,N),
% select a tab
if nargin~=2,
  error('Not enough input arguments');
end;

WasSelected=Obj.Selected;
set(Obj.Tab(WasSelected),'value',1,'enable','on');
Obj.Selected=N;
set(Obj.Tab(N),'value',0,'enable','off');
set(Obj.Handles{N},'visible','on');
set(Obj.Handles{WasSelected},'visible','off');

% update tab information
set(Obj.Main,'userdata',Obj);