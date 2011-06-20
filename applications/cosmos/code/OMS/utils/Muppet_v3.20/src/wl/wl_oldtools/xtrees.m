function xtrees(Ntrees),
if nargin==0,
  Ntrees=10;
end;
new=1;
figure
set(gcf,'color',[112 131 196]/255);
axes('position',[0 .3 1 1]);
hold on;
Radius=200;
xs=1*(-Radius:5:Radius);
ys=xs;
zs=rand(length(xs),length(ys))*2;
I=surface(xs,ys,zs, ...
     'facecolor',[1 1 1], ...
     'edgecolor','none', ...
     'clipping','off', ...
     'backfacelighting','lit', ...
     'facelighting','phong', ...
     'ambientstrength',.2, ...
     'diffusestrength',1, ...
     'specularstrength',0);
phi=2*pi*rand(Ntrees,1);
R=Radius*rand(Ntrees,1);
x=R.*cos(phi);
y=R.*sin(phi);
z=griddata(xs,ys,zs,x,y);
for i=1:Ntrees,
  h=0.9+0.2*rand;
  if new,
    h=tube3d(x(i)*ones(1,83),y(i)*ones(1,83),z(i)+h*[0 2 2:.1:10],h*[.2 .2 (3*(80:-1:0)/80).*(0.8+0.2*rand(1,81))],[2 1 zeros(1,81)]);
  else,
    h=tube3d(x(i)*ones(1,4),y(i)*ones(1,4),z(i)+h*[0 2 2 10],h*[.2 .2 3 0],[2 1 0 0]);
  end;
  set(h,'facecolor','flat', ...
        'edgecolor','flat', ...
        'facelighting','gouraud', ...
        'edgelighting','none', ...
        'ambientstrength',0.6, ...
        'diffusestrength',0.9, ...
        'specularstrength',0, ...
        'meshstyle','column', ...
        'clipping','off', ...
        'tag','tree');
end;
set(gca,'visible','off','xlim',[-Radius Radius],'ylim',[-Radius Radius],'dataaspectratio',[1 1 1]);
colormap([0 0.5 0;0.15 0.35 0;0.3 0.2 0]);
colorfix;
light;
view(3);
drawnow;
md_camera(gca);

% realistic texture
H=findobj(gca,'tag','tree');
cmap=[transpose(0:.01:1)*([0 0.75 0]-[.15 .35 0])+ones(101,1)*[.15 .35 0];.3 .2 0];
cmapi=1+round(100*rand(1,50));
cmap(cmapi,:)=1-(0.5*rand(50,3).*(1-cmap(cmapi,:)));
if new,
  icd=[102*ones(90,1) 1+round(50*rand(90,1)) 1+round(100*rand(90,81))];
else,
  icd=[102*ones(90,30) 1+round(50*rand(90,30)) 1+round(100*rand(90,30))];
end;
tcd=idx2rgb(icd,cmap);
if new,
  set(H,'cdata',tcd,'edgecolor','none','facecolor','texturemap','cdatamapping','direct')
else,
  set(H,'cdata',tcd,'edgecolor',[0 .5 0],'facecolor','texturemap','cdatamapping','direct')
end;
setview(gca,[-47.4137 2.4225 67.6187 0.0000]);

A=axes('position',[0 0 1 1],'visible','off');
text(.5,.35,{'Merry Christmas','and','Happy New Millennium','','\fontsize{10}{Bert Jagers}'},'parent',A,'horizontalalignment','left','fontname','times','fontsize',18,'color','r');
text(.99,.02,'Created in Matlab','parent',A,'horizontalalignment','right','verticalalignment','bottom','fontname','times','fontsize',8,'color','k');
