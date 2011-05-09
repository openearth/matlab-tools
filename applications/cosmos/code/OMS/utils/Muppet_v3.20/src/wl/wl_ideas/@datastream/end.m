function L = end(Obj,K,N)
%DATASTREAM/END

if (N~=1),
  error('Only one dimension allowed.'),
else,
  L=Obj.NumberOfFields;
end;