function unwlsettings

P=path;
P=multiline(P,';','cell');
for i=length(P):-1:1
   if ~isempty(findstr(P{i},'wl_'))
      P(i)=[];
   end
end
path(sprintf('%s;',P{:}))