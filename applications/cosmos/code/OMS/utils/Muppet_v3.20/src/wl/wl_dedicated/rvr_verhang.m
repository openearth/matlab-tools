figure
S=pathdistance2(data.X,data.Y);
dx=(gradient(data.Val')./gradient(S'));
surf(data.X,data.Y,dx')
view(0,90); shading flat
set(gca,'clim',[-1 1]*.0003)
colorbar
set(gca,'da',[1 1 1])

figure
S2=pathdistance2(data.X',data.Y');
dy=(gradient(data.Val)./gradient(S2'));
surf(data.X,data.Y,dy)
view(0,90); shading flat
set(gca,'clim',[-1 1]*.0003)
colorbar
set(gca,'da',[1 1 1])
