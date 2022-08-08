clear all
close all


%% input
fname = '\xboutput.nc';
maxWL = 4.13;





%% read nc

% --- read variables as an example
zb          = nc_varget(fname,'zb');
x           = nc_varget(fname,'globalx');
zswet_max   = nc_varget(fname,'zswet_max');

zswet_max   = squeeze(zswet_max(:,1,:));

zbe         =  squeeze( zb(end,1,:) ); 
zb0         =  squeeze( zb(1,1,:) ); 

figure(10)
plot(x, zb0,'k-','linewidth',2)
hold on
plot(x, zbe,'r-')
plot(x, x*0+maxWL,'b--')
grid on

%% analyse

% --- erosion volume
V                   = get_erosionvolume_2(x,zb0,zbe,maxWL);
title(sprintf('V=%2.2f m^3/m',V))

% --- erosion point
[xafslag,zafslag]   = get_xafslag_xbBOI(x,zb0,zbe);

scatter(xafslag, zafslag,'r','filled')

% --- xwet-t
[xnat_t,znat_t] = get_xnat_t_xbBOI(x,zswet_max');

scatter(xnat_t, znat_t,5,'m','filled')

% --- xwet
slopeland=1/2;
[xnat,znat,itxnat] = get_xnat_xbBOI(xnat_t,znat_t,slopeland,x,zbe);

scatter(xnat, znat,'g','filled')

% --- boundary profile
X0 = loc_boundary_profile(znat,xnat,x,zbe,maxWL);

% --- plot
height = znat+1.5 - maxWL;
figure(10)
plot([X0 X0+height*1 X0+height+3 X0+height+3+height*2],[maxWL, znat+1.5 znat+1.5 maxWL],'b-','linewidth',2)

legend({'zb[t=0]','zb[t=tend]','rekenpeil','afslag punt','natte punten', 'natte punt','grensprofiel'},'Location','northwest')

string = sprintf('V=%2.2f m^3/m\nXaf=%2.2f m; Zaf=%2.2f m\nXnat=%2.2f m; Znat=%2.2f m',V,xafslag,zafslag,xnat,znat);
text(0.6,0.15,string,'Units','normalized')
set(gcf,'Position',[100 100 800 500])
xlabel('Afstand [m+RSP]'); ylabel('Hoogte [m+NAP]')