function H=sorthandles(obj,Hin),

H=Hin;
if ~isequal(get(H(2),'type'),'patch'),
  H([2 3])=H([3 2]);
end;