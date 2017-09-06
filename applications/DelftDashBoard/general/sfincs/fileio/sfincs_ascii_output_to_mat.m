function sfincs_ascii_output_to_mat(folder,inpfile,ascfile,hmaxfile,matfile,refdate)

thrsh=0.1;

inp=sfincs_read_input([folder inpfile]);
dep=load([folder inp.depfile]);

s0=load([folder ascfile]);
nt=size(s0,1)/inp.nmax;
% wl=reshape(s,[nt size(h,1) size(h,2)]);
wlc = mat2cell(s0,inp.nmax*ones(nt,1),inp.mmax);
val=zeros(nt,inp.nmax,inp.mmax);
wdep=val;

hmax=load([folder hmaxfile]);
hmax(hmax<thrsh)=NaN;

for it=1:nt
    % Cut out land points
    v0=wlc{it};
    v0(v0<dep+thrsh)=NaN;
    val(it,:,:)=v0;
    wdep(it,:,:)=v0-dep;
end

dt=inp.dtout/86400; % output timestep in days
t=refdate:dt:refdate+(nt-1)*dt;

xx=0:inp.dx:inp.dx*(inp.mmax-1);
yy=0:inp.dy:inp.dy*(inp.nmax-1);
xx=xx+inp.x0;
yy=yy+inp.y0;

[x,y]=meshgrid(xx,yy);

s.parameters(1).parameter.name='water level';
s.parameters(1).parameter.time=t;
s.parameters(1).parameter.x=x;
s.parameters(1).parameter.y=y;
s.parameters(1).parameter.val=val;
s.parameters(1).parameter.size=[nt 0 inp.nmax inp.mmax 0];
s.parameters(1).parameter.quantity='scalar';

s.parameters(2).parameter.name='water depth';
s.parameters(2).parameter.time=t;
s.parameters(2).parameter.x=x;
s.parameters(2).parameter.y=y;
s.parameters(2).parameter.val=wdep;
s.parameters(2).parameter.size=[nt 0 inp.nmax inp.mmax 0];
s.parameters(2).parameter.quantity='scalar';

s.parameters(3).parameter.name='maximum water depth';
s.parameters(3).parameter.x=x;
s.parameters(3).parameter.y=y;
s.parameters(3).parameter.val=hmax;
s.parameters(3).parameter.size=[0 0 inp.nmax inp.mmax 0];
s.parameters(3).parameter.quantity='scalar';

save([folder matfile],'-struct','s');


% wl1=squeeze(wl(end,:,:));
% wl=zeros(nt,nmax,mmax);
% for it=1:nt
%     wl(it,:,:)=s((it-1)*nmax+1:(it-1)*nmax+nmax,:);
% end


% pcolor(x,y,squeeze(wl(end,:,:)));shading flat;axis equal;colorbar;
% 
% % figure(3)
% % p=plot(x(1,:),squeeze(wl(1,1,:)));
% %     set(gca,'ylim',[-1 6]);
% % for it=1:nt
% %   set(p,'ydata',  squeeze(wl(it,1,:)));
% %     drawnow;pause(0.02);
% % end
% 
% figure(6)
% maxwl=squeeze(max(wl,[],1));
% pcolor(x,y,maxwl);shading flat;axis equal;colorbar;
% 
% maxwl=squeeze(max(wl,[],1));
% maxwl=squeeze(max(maxwl,[],1));
% %maxwl=squeeze(maxwl(1,:));
% figure(4)
% p=plot(x(1,:),maxwl,'k');hold on;
% p=plot(x(1,:),z(1,:),'b');hold on
%     set(gca,'ylim',[-1 6]);
% 
% figure(5)
% p=surf(x,y,wlc{1});
% set(gca,'zlim',[-1 5]);
% for it=1:nt
%   set(p,'zdata',  wlc{it});
%     drawnow;pause(0.01);
% end
% 
% figure(6)
% s=load('zmax.txt');
% s(s<0)=NaN;
% p=pcolor(x,y,s);shading flat;axis equal;colorbar;
% 
% figure(7)
% p1=surf(x,y,z);hold on;
% set(p1,'facecolor',[0.2 1.0 0.2]);
% %set(p1,'facecolor',[1 0 0]);
% set(p1,'edgecolor','none');
% set(gca,'zlim',[-20 20]);
% zw=wlc{1};
% zw(zw-z<0.01)=NaN;
% p=surf(x,y,zw);
% set(p,'facecolor',[0.5 0.5 1]);
% set(p,'edgecolor','none');
% set(p,'FaceAlpha',1);
% light;
% for it=1:nt
% zw=wlc{it};
% zw(zw-z<0.01)=NaN;
%   set(p,'zdata',  zw);
%     drawnow;pause(0.1);
% end
% 
% zend=wlc{end};
% zend(zend<-900)=NaN;
% dpt=zend-z;
% dpt(isnan(dpt))=0;
% vol=sum(sum(dpt))*100*100

% figure(8)
% p1=plot(x(1,:),z(1,:));hold on;
% set(gca,'ylim',[-1 5]);
% zw=wlc{1};
% zw(zw-z<0.01)=NaN;
% p=plot(x(1,:),zw(1,:));
% for it=1:nt
% zw=wlc{it};
% zw(zw-z<0.01)=NaN;
%   set(p,'ydata',  zw(1,:));
%     drawnow;pause(0.05);
% end

% zmax=load('zmax.txt');
% zmax(zmax<0)=NaN;
% dp=zmax-z;
% zmax(dp<0.1)=NaN;
% figure(9)
% % z(z<0)=NaN;
% pcolor(x,y,z);axis equal;shading flat;colorbar;
% hold on;
% zmax(~isnan(zmax))=1;
% p=pcolor(x,y,zmax);axis equal;shading flat;colorbar;
% 
% %set(p,'facecolor',[0  0 1]);