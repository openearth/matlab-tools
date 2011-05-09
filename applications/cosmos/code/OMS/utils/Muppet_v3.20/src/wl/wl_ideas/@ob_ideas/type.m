function Tp=type(obj)
%TYPE

if prod(size(obj))>1,
  Tp={obj(:).Type};
  for i=1:length(Tp),
    if isempty(Tp{i}), % both [] (uninitialized one of an array) and '' (initialized)
      Tp{i}='empty';
    end;
  end;
else,
  Tp=obj.Type;
end;
