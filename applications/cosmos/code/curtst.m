clear variables;close all;

fname='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts\models\europe\csm\archive\20110130_12z\maps\windvel.mat';
s=load(fname);

Ax.XMin=min(s.X);
Ax.XMax=max(s.X);

Ax.YMin=min(s.Y);
Ax.YMax=max(s.Y);

Plt.DxCurVec=0.3;
Plt.DtCurVec=1800;

Plt.HeadThickness=1.0;
Plt.ArrowThickness=0.3;
Plt.LifeSpanCurVec=50;
Plt.RelSpeedCurVec=1;
Plt.DDtCurVec=600;

u=squeeze(s.U(1,:,:));
v=squeeze(s.V(1,:,:));
xl=0;
yl=0;
pos=[];

[x,y]=meshgrid(s.X,s.Y);

u=u/100000;
v=v/100000;

[xp,yp,pos]=omsKMLCurVec(x,y,u,v,xl,yl,pos,Ax,Plt);
for i=1:size(xp,2)
    plot(squeeze(xp(:,i)),squeeze(yp(:,i)));hold on;
end
