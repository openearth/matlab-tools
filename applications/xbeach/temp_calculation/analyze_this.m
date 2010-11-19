function analyze_this(test, run, data_dir, output_dir)

test_id = [test '_' run];

%% coefficients and settings
fid = fopen([data_dir 'datanam.txt']);
nvar = str2num(fgetl(fid));
for i = 1:nvar
    line = fgetl(fid);
    [nam,remain] = strtok(line,' ');
    [dummy,remain] = strtok(remain,'=');
    par.(nam) = str2num(remain(2:end));
end
par.(nam) = remain(end-1:end);
fclose(fid);

%% simulation results
nam = [{'zb'};{'H'};{'zs'};{'hh'};{'u'};{'ue'};{'urms'};{'dzav'};{'D'};{'Df'};{'Dp'};];
nam2 = [{'ccg'};{'Susg'};{'Subg'};];

% dimensions
fid = fopen('dims.dat','r'); 
temp = fread(fid,[7,1],'double'); 
nt = temp(1);
nx = temp(2)+1;
ny = temp(3)+1;
ntheta = temp(4);
kmax = temp(5);
ngd = temp(6);
nd = temp(7);
fclose(fid);

t = (0:1:nt-1)*par.morfac/3600;
Tsim = t(end)*3600;

% read grid coordinates 
fid = fopen('xy.dat','r');
xw = fread(fid,[nx,ny],'double'); 
yw = fread(fid,[nx,ny],'double');
fclose(fid);

dx = zeros(1,length(xw));
dx(2:end-1) = 0.5*(xw(3:end,2)-xw(1:end-2,2));
dx(1) = 0.5*(xw(2,2)-xw(1,2));
dx(end) = 0.5*(xw(end,2)-xw(end-1,2));

xu = zeros(size(xw(:,2)));
xu(1:end-1) = 0.5*(xw(1:end-1,2)+xw(2:end,2));
xu(end) = xu(end-1)+ 0.5*(xu(end-1)-xu(end-2));
dx2 = dx*0;
dx2(2:end) = xu(2:end)-xu(1:end-1);
dx2(1) = 0.5*dx(2);

% read XBeach output
ts = 0:1:nt-1;
for j = 1:length(nam)
    temp = zeros(nx,ny,nt);
    fid = fopen([nam{j},'.dat'],'r');
    for i = 1:nt
        temp(:,:,i) = fread(fid,[nx,ny],'double');  % all data
    end
    fclose(fid);
    s.(nam{j}) = zeros(nx,nt);
    s.(nam{j}) = squeeze(temp(:,2,:));
end

for j = 1:length(nam2)
    temp = zeros(nx,ngd,nt);
    fid = fopen([nam2{j},'.dat'],'r');
    for i=1:nt
        for ii=1:ngd
            ttemp = fread(fid,[nx,ny],'double');
            temp(:,ii,i) = ttemp(:,2);               
        end
    end
    fclose(fid);
    s.(nam2{j}) = temp;
end

h = s.zs-s.zb;
rhos  = 2650;
%
dz = s.zb(:,end)-s.zb(:,1);
s.Sdzbtot = (1-par.np)*flipud(cumsum(flipud(dz.*dx2')))/Tsim;
s.Sdzavtot = (1-par.np)*flipud(cumsum(flipud(s.dzav(:,end).*dx2')))/Tsim;
s.Sustot = squeeze(mean(s.Susg(:,1,:),3));
s.Subtot = squeeze(mean(s.Subg(:,1,:),3));
s.Sutot = mean(s.Susg+s.Subg,3);

uemean = mean(s.ue,2);
qmean = mean(s.ue.*s.hh,2);
ccmean = mean(squeeze(s.ccg(:,1,:)),2);
Smean = mean(s.ue.*s.hh.*squeeze(s.ccg(:,1,:)),2);

%% measurements

% load hard layer
hardlayer = load('dz.dep');
zhard = s.zb(:,1)-hardlayer(2,:)';

xm   = [ 193   191.5  190    172    181    187    190    191.5  193    191.5  190    187    181    187    190];
cmm  = [ 3.1   2.3    1.73   0.18   0.52   1.22   0.98   0.54   0.36   0.55   0.56   0.90   0.77   0.67   0.5];
umm  = [-0.16 -0.183 -0.114 -0.127 -0.134 -0.137 -0.204 -0.162 -0.141 -0.201 -0.255 -0.192 -0.164 -0.191 -0.211];

% load measured data
load data_T1.mat

dzm = z{end}-z{1}; 
Sdzbtot = (1-par.np)*flipud(cumsum(flipud(dzm')))/Tsim;

%% profile evolution
s.zs = max(s.zs,s.zb);
ind = round([0 0.06 1.3 3.5 9.6]*3600/par.morfac); ind(1) = 1;
indh = find(zhard==max(zhard));
figure; set(gca,'FontSize',16)
plot(xw(:,2),s.zb(:,1),'k--'); hold on;
for i = 2:length(z)
    plot(xw(:,2),s.zb(:,ind(i)),'k-o','LineWidth',1.5); hold on; plot(x,z{i}-par.zs0,'k--');
end
plot(xw(:,2),s.zb(:,end),'k-o','LineWidth',1.5);
plot(xw(1:indh,2),zhard(1:indh),'r','LineWidth',1.5);
plot(xw(:,2),max(s.zs'),'b--','LineWidth',1.5);
plot(xw(:,2),min(s.zs'),'b--','LineWidth',1.5);
plot([0 210],[0 0],'k:','LineWidth',2);
axis([150 210 -2 2.5]); xlabel('x [m]'); ylabel('z_b [m]');
pname = [output_dir,test_id '_fig1.png'];
eval(['print -dpng ' pname]);
pname = [output_dir,test_id '_fig1.eps'];
eval(['print -depsc2 ' pname]);
pname = [output_dir,test_id '_fig1.fig'];
saveas(gcf, pname, 'fig');


%% Sediment transport analysis
% figure;
% subplot(211);
% plot(x,dzm,'k-o'); hold on;
% plot(xw(:,2),dz,'r-v'); grid on;
% subplot(212);
% plot(x,Sdzbtot,'k-o'); hold on;
% plot(xw(:,2),s.Sdzbtot,'r-v'); grid on;
% print sediment_transport1.png -dpng

figure; 
subplot(311);
plot(xw(:,2),s.zb(:,1),'k--'); hold on;
plot(xw(:,2),s.zb(:,end),'k-o');
plot(xw(1:indh,2),zhard(1:indh),'r','LineWidth',1.5); 
plot(xw(:,2),uemean,'r-v');
plot(xm,umm,'ro','LineWidth',2);
axis([150 210 -1.5 2.1]); grid on;
xlabel('x [m]'); ylabel('U_m [m/s]');
subplot(312); 
plot(xw(:,2),s.zb(:,1),'k--'); hold on;
plot(xw(:,2),s.zb(:,end),'k-o');
plot(x,z{1}-par.zs0,'k--');
plot(x,z{end}-par.zs0,'k--');
plot(xw(1:indh,2),zhard(1:indh),'r','LineWidth',1.5);
plot(xw(:,2),ccmean*rhos,'r-v','LineWidth',2);
plot(xm,cmm,'ro','LineWidth',2);
axis([150 210 -2 2.1]); grid on;
xlabel('x [m]'); ylabel('c [g/l]');
subplot(313);
% plot(xw(:,2),s.zb(:,1),'k--'); hold on;
% plot(xw(:,2),s.zb(:,end),'k-o');
% plot(xw(1:indh,2),zhard(1:indh),'r','LineWidth',1.5); 
% plot(xw(:,2),ccmean.*qmean,'r-+','LineWidth',2); hold on;
plot(xw(:,2),2650*(s.Sustot+s.Subtot),'r-v','LineWidth',2); hold on;
plot(xw(:,2),2650*s.Sdzavtot,'b-v');
plot(xw(:,2),2650*(s.Sustot+s.Subtot+s.Sdzavtot),'g-v');
% plot(x,2650*Sdzbtot,'k-o');
plot(xw(:,2),2650*s.Sdzbtot,'k-v');
plot([0 210],[0 0],'g','LineWidth',2);
axis([150 210 -0.3 0.1]); grid on;
legend('Ss+Sb','Sdzav','Sdzav+Ss+Sb','Sdzb_s',2); %'z_{b0}','z_{b_end}','hard layer','Sdzb_m'
pname = [output_dir,test_id '_fig2.png'];
eval(['print -dpng ' pname]);
pname = [output_dir,test_id '_fig2.eps'];
eval(['print -depsc2 ' pname]);
pname = [output_dir,test_id '_fig2.fig'];
saveas(gcf, pname, 'fig');

%% error statsitics

[r2,sci,relbias,bss]        = compskill_tb([xw(:,2) dz                      ] ,[x;  dzm]');
% [r2(2),sci(2),relbias(2),bss(2)]        = compskill_tb([xw(:,2) mean(s.ue,2)            ] ,[xm; umm]');
% [r2(3),sci(3),relbias(3),bss(3)]        = compskill_tb([xw(:,2) squeeze(mean(s.ccg(:,1,:),3))] ,[xm; cmm]');

% LaTeX text with subscript or superscript should be written between
% $-signs (this is the so-called math-mode, leading to italic text).
% varnames and errnames are 
% varnames = {'$u_{E}$','$C_{m}$','sedero'};
% errnames = {'$R^2$','SCI','Rel. Bias','BSS'};
varnames = {'sedero'};
errnames = {'$R^2$','SCI','Rel. Bias','BSS'};


OPT = {...
    'title', ['error statistics test ',test],...
    'filename', [output_dir,test_id '_tab1.tex'],...
    'where', '!tbp',...
    'rowlabel',varnames,...
    'rowjustification', 'l',...
    'collabel',errnames,...
    'caption', '',...
    'justification', 'center'};

table = [r2; sci; relbias; bss;]

matrix2latex(table',OPT{:});

%% movieplot
% figure;
% eps = 0.01;
% delta = 0.5;
% for i = nt-100:nt
%    ind1 = min(find(s.zs(:,i)-s.zb(:,i)<eps));
%    ind2 = min(find(s.zs(:,i)-s.zb(:,i)+delta*s.H(:,i)<eps));
%    plot(xw,s.zb(:,1),'k--'); hold on;
%    plot(xw(:,2),zhard,'r-o','LineWidth',1.5);
%    plot(xw,s.zb(:,i),'k-s','LineWidth',1.5);
%    plot(xw,s.zs(:,i),'b'); hold on; plot(xw(ind1,2),s.zs(ind1,i),'b*','MarkerSize',8);
%    plot(xw,s.H(:,i)+max(s.zb(:,i),0),'g'); hold on; plot(xw(ind2,2),s.zs(ind2,i),'g*','MarkerSize',8);
%    plot(xw,s.ue(:,i),'r');
%    plot(xw,par.rhos*s.ccg(:,1,i),'m','LineWidth',1.5);
%    plot([0 230],[par.topr par.topr],'k--');
%    axis([160 210 -2 2.2]);
%    title(num2str(i));
%    pause(0.1); hold off;
% end

end