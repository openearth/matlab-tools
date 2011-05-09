function surf2patch

ss=findall(gcf,'type','surface');
for i=length(ss):-1:1
  if isequal(get(ss,'marker'),'none')
    ss(i)=[];
  end
end

for i=1:length(ss)
  s=ss(i);
  Prop=get(s);
  act=~isnan(Prop.XData) & ~isnan(Prop.CData);
  p=Prop.Parent;
  l=patch(Prop.XData(act),Prop.YData(act),Prop.ZData(act),1, ...
             'CData',Prop.CData(act), ...
             'FaceColor','none', ...
             'LineStyle','none', ...
             'Marker',Prop.Marker, ...
             'MarkerFaceColor',Prop.MarkerFaceColor, ...
             'MarkerEdgeColor',Prop.MarkerEdgeColor, ...
             'Parent',p, ...
             'UserData',Prop.UserData);
  c=allchild(p);
  c(c==s)=l;
  delete(s);
  set(p,'children',c);
end