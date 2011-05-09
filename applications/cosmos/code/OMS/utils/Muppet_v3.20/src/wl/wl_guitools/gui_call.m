function gui_call(obj),
%GUI_CALL Start GUI for an graphics object of any type
%         GUI_CALL(h)
%         where h is a graphics handle
%
%         May be abbreviated to GC(h).

if nargin==0
  if isempty(get(0,'children')), return; end % no figure
  f=get(0,'currentfigure');
  obj=get(f,'currentobj');
  if isempty(obj),
    obj=get(f,'currentaxes');
    if isempty(obj),
      obj=f;
    end
  end
end
obj=obj(:);
for i=1:length(obj),
  objtyp=get(obj(i),'type');
  eval(['gui_',objtyp,'(obj(i))'])
end;