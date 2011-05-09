function H=handles(Obj),

% get all handles

SHH=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
H=findobj('tag',Obj.Tag);
set(0,'showhiddenhandles',SHH);

% sort handles such that H(1) - the MAIN ITEM - contains the object info

if length(H)>1,
  nrs=1:length(H);
  for i=nrs,
    UD=get(H(i),'userdata');
    if isstruct(UD) & isfield(UD,'PTag') & isequal(UD.PTag,'main'),
      % MAIN ITEM found, shift its handle to H(1)
      H=[H(i) transpose(H(nrs~=i))];
      if length(H)>1,
        try,
          H=sorthandles(Obj.TypeInfo,H);
        end;
      end;
      % and return
      return;
    end;
  end;
  % no main item found!
end;