function AcceptPressed=edit(Obj),
if ~isempty(Obj.TypeInfo),
  AcceptPressed=edit(Obj.TypeInfo);
else,
  ui_message('warning','Cannot edit an empty IDEAS object.');
  AcceptPressed=0;
end;
