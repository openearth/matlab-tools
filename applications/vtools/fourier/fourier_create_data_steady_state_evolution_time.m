%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Only loop of eigenvalues in 2D study.

function fourier_create_data_steady_state_evolution_time(fdir_out,noise_Lbx_v,noise_W_v,etab_max,nlength,nmove,nx,ny,nt,ECT_input,dim_ini,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'plot_1D',0);
addOptional(parin,'plot_2D',0);
addOptional(parin,'overwrite',0);
addOptional(parin,'order_anl',1);
addOptional(parin,'do_only_index',false);

parse(parin,varargin{:});

do_plot_1D=parin.Results.plot_1D;
do_plot_2D=parin.Results.plot_2D;
overwrite=parin.Results.overwrite;
order_anl=parin.Results.order_anl;
do_only_index=parin.Results.do_only_index;

pert_anl=1; %1=full

%% CALC

%% input variation

input_m_L=allcomb(noise_Lbx_v,noise_W_v);
nv=size(input_m_L,1);
data=struct('Lx',cell(nv,1),'Ly',cell(nv,1),'c',cell(nv,1),'w',cell(nv,1));

%% dir
fdir_nc=fullfile(fdir_out,'nc');
mkdir_check(fdir_nc);

fdir_fig=fullfile(fdir_out,'fig');
mkdir_check(fdir_fig);

fdir_mat=fullfile(fdir_out,'mat');
mkdir_check(fdir_mat);

%% loop

flg.order_anl=order_anl;
kv_v=gdm_kt_v(flg,nv);

for k=1:nv

    kv=kv_v(k);

    %% disp
    messageOut(NaN,sprintf('Done %4.2f %%',k/nv*100));

    %% overwrite

    fname=sprintf('%06d',kv);
    filename=fullfile(fdir_nc,sprintf('%s.nc',fname));

    if exist(filename,'file') && ~overwrite
        messageOut(NaN,sprintf('File exists: %s',filename));
        continue
    end

    %% case parameters
    
    %matrix input rework
    noise_Lbx=input_m_L(kv,1);
    noise_W=input_m_L(kv,2); %width of the domain (half the lengthscale for alternate bars)
    
    noise_Lby=2*noise_W;
    
    %compute matrices
    [ECT_matrices,~]=call_ECT(ECT_input);
    
    %compute celerity
    [c,w]=compute_celerity(ECT_matrices,noise_Lbx,noise_Lby,pert_anl);
    
    %initial condition
    % noise_etab=initial_condition(x_in,y_in,noise_Lbx,noise_Lby,etab_max); %not needed, already in the Fourier modes
   
    %% save to mat

    data(kv).Lx=noise_Lbx;
    data(kv).Ly=noise_Lby;
    data(kv).c=c;
    data(kv).w=w;

    if do_only_index
        continue
    end

    %% case reconstruction

    %domain
    [x,y,t,x_in,y_in]=compute_domain(nlength,noise_Lbx,noise_W,nx,ny,nt,c,w,nmove);

    %initial Fourier coefficient of bed level
    [fx2,fy2,P2]=fourier_modes_alternate_bar(noise_Lbx,noise_Lby,etab_max); 

    %matrices
    [R,omega,M]=fourier_eigenvalues_frequency_matrices(ECT_matrices.Dx,ECT_matrices.Dy,ECT_matrices.Ax,ECT_matrices.Ay,ECT_matrices.B,ECT_matrices.C,ECT_matrices.M_pmm,fx2,fy2,pert_anl,0);

    %initial Fourier coefficient of all equations
    P2all0=fourier_steady_state_frequency('flat',fx2,fy2,P2,dim_ini,M);

    %compute evolution of Fourier coefficient of bed level with time
    [~,~,P2allt_bl]=fourier_evolution_frequency(fx2,fy2,x_in,y_in,t,P2all0,R,omega,NaN,'full',0,'disp',0);

    %compute steady state solution with timefor all equations
    Q_rec=compute_steady_state_in_time(P2allt_bl,fx2,fy2,x_in,y_in,dim_ini,M);

    %% WRITE
    
    %we check again because when running in parallel a file may be created
    %by another processor when this processor was already working on it.
    if exist(filename,'file') && ~overwrite
        messageOut(NaN,sprintf('File exists: %s',filename));
        continue
    end

    fourier_write_nc(filename,x,y,t,Q_rec,noise_Lbx,noise_W,etab_max,c,w)
    
    %% PLOT
    
    %% 2D
    if do_plot_2D
        in_p.fname=fullfile(fdir_fig,fname);
        in_p.Q_rec=Q_rec;
        in_p.x_in=x_in;
        in_p.y_in=y_in;
        in_p.t=t;
        
        fig_surf(in_p);
    end

    %% 1D

    if do_plot_1D
        plot_1D(Q_rec,x_in,t,c,w,fname,fdir_fig);
    end

end %kv

%% SAVE MAT

fname=fullfile(fdir_mat,'index.mat');
save(fname,'data')

end %function

%%
%% FUNCTION
%%

%%

function  plot_1D(Q_rec,x_in,t,c,w,fname,fdir_fig)

[ne,nx,ny,nt]=size(Q_rec);
variable_v={'h','qxsp','qysp','etab'};

for ke=1:ne

kc=0;
ky=128;
val={};
x={};


for kt=1:nt
    kc=kc+1;
    x{kc}=x_in(ky,:);
    val{kc}=Q_rec(ke,:,ky,kt);
end

kt=1;
[vm0,idx_max]=max(Q_rec(ke,round(nx/4):round(nx*3/4),ky,kt)); %we guarantee the maximum is in the first half
dt=t(end)-t(1);
vmT=vm0*exp(w*dt);
x_0=x_in(ky,idx_max);
x_f=x_0+c*dt;

kc=kc+1;
x{kc}=[x_0,x_f];
val{kc}=[vm0,vmT];

in_p.fname=fullfile(fdir_fig,sprintf('%s_%d',fname,ke));
in_p.fig_overwrite=1;
in_p.s=x;
in_p.val=val';
in_p.variable=variable_v{ke};
in_p.do_leg=0;

fig_1D_01(in_p)

end %ke

end %function

%%

function Q_rec=compute_steady_state_in_time(P2allt_bl,fx2,fy2,x_in,y_in,dim_ini,M)

nt=size(P2allt_bl,2);
ne=size(M,1);
[ny,nx]=size(x_in);
nmx=numel(fx2);
nmy=numel(fy2);

Q_rec=zeros(ne,nx,ny,nt);

%loop through time
for kt=1:nt
    %Fourier coefficient of bed level at local time
    aux=P2allt_bl(dim_ini,kt,:,:); %(ne,nt,nmx,nmy);
    aux2=squeeze(aux);
    P2_bl_loc=aux2.'; %ATTENTION!

    %Watch out for transpose (`'`) and dot-transpose (`.'`) with
    %complex numbers! The below code (what you want) is a
    %dot-transpose.
    %
    % for kmx=1:nmx
    %     for kmy=1:nmy
    %         P2_bl_loc(kmy,kmx)=c_bl(dim_ini,kt,kmx,kmy);
    %     end
    % end

    %Fourier coefficients of all equations at local time
    P2all=fourier_steady_state_frequency('steady',fx2,fy2,P2_bl_loc,dim_ini,M);
    
    %loop
    for kmx=1:nmx
        for kmy=1:nmy
            kx_fou=2*pi*fx2(kmx);
            ky_fou=2*pi*fy2(kmy);
            
            c=P2all(:,kmy,kmx);
    
            for ky=1:ny
                e=real(c*exp(1i*kx_fou*x_in(ky,:)).*exp(1i*ky_fou*y_in(ky,:)));
                Q_rec(:,:,ky,kt)=Q_rec(:,:,ky,kt)+e;
            end %ky
        end %kmy
    end %kmx
end %kt

end %function

%%

function [c_morph_p,gr]=compute_celerity(ECT_matrices,noise_Lbx,noise_Lby,pert_anl)

kwx=2*pi/noise_Lbx;
kwy=2*pi/noise_Lby;

[eig_r,eig_i]=twoD_study_eigenvalues(pert_anl,kwx,kwy,ECT_matrices.Dx,ECT_matrices.Dy,ECT_matrices.C,ECT_matrices.Ax,ECT_matrices.Ay,ECT_matrices.B,ECT_matrices.M_pmm);
[c_morph_p,~,gr]=derived_variables_twoD_study_c_morph_p(eig_r,eig_i,kwx);

end %function

%%

function [x,y,t,x_in,y_in]=compute_domain(nlength,noise_Lbx,noise_W,nx,ny,nt,c,w,nmove)

%space
Ltrue=nlength*noise_Lbx;
dx=Ltrue/nx;     
dy=noise_W/ny; 
% L=(nx-1)*dx; %domain length
% W=(ny-1)*dy; %domain width
x=(0:nx-1)*dx;        
y=(0:ny-1)*dy;   
y=y+noise_W/2;

[x_in,y_in]=meshgrid(x,y);

%time
T_c=abs(nmove*noise_Lbx/c); %time to move fact of lambda
T_w=abs(1/w*log(nmove)); %time to decrease or increase `nmove` fraction of the original amplitude. $\omega=1/(\Delta t)*ln(A2/A1)$
T=min([T_c,T_w,365*24*3600]);
t0=0;
% t0=1; %for t=0, the analytical solution of the bed level is 0. 
% t0=T/2; 
tf=t0+T;
t=linspace(t0,tf,nt); 

end %function

%%

function noise_etab=initial_condition(x_in,y_in,noise_Lbx,noise_Lby,etab_max)

Ay=sin(2*pi*(y_in)./noise_Lby);
noise_etab=etab_max*Ay.*cos(2*pi*x_in/noise_Lbx-pi/2);

end %function

%%

function [fx2,fy2,P2]=fourier_modes_alternate_bar(noise_Lbx,noise_Lby,etab_max)

fx=1/noise_Lbx; %[1/m]
fy=1/noise_Lby; %[1/m]

fo_c=etab_max/4; %Fourier coefficients [m]

fx2=[-fx,+fx];
fy2=[-fy,+fy];
P2=[-fo_c,+fo_c;+fo_c,-fo_c];

end %function

%%

function fig_surf(in_p)

%% DEFAULTS

if isfield(in_p,'fig_visible')==0
    in_p.fig_visible=0;
end
if isfield(in_p,'fig_print')==0
    in_p.fig_print=1;
end
if isfield(in_p,'fname')==0
    in_p.fname='fig';
end
if isfield(in_p,'fig_size')==0
    in_p.fig_size=[0,0,14,17]; %(1+sqrt(5)/2)
end
if isfield(in_p,'fig_overwrite')==0
    in_p.fig_overwrite=1;
end
if isfield(in_p,'fid_log')==0
    in_p.fid_log=NaN;
end
if isfield(in_p,'lan')==0
    in_p.lan='en';
end
in_p=isfield_default(in_p,'x_lab',labels4all('x',1,in_p.lan));
in_p=isfield_default(in_p,'y_lab',labels4all('y',1,in_p.lan));
in_p=isfield_default(in_p,'XScale','linear');
in_p=isfield_default(in_p,'marker','none');
in_p=isfield_default(in_p,'lims_x',[NaN,NaN]);
in_p=isfield_default(in_p,'lims_y',[NaN,NaN]);
in_p=isfield_default(in_p,'lims_y',[NaN,NaN]);
[in_p.lims_x,in_p.lims_y]=xlim_ylim(in_p.lims_x,in_p.lims_y,in_p.x_in,in_p.y_in);

v2struct(in_p)

%% check if printing
do_fig=check_print_figure(in_p);
if ~do_fig
    return
end

%% SIZE

%square option
npr=2; %number of plot rows
npc=1; %number of plot columns
axis_m=allcomb(1:1:npr,1:1:npc);

%some of them
% axis_m=[1,1;2,1;2,2];
% npr=max(axis_m(:,1));
% npc=max(axis_m(:,2));

na=size(axis_m,1);

%figure input
prnt.filename=fname;
prnt.size=fig_size; %slide=[0,0,25.4,19.05]; slide16:9=[0,0,33.867,19.05] tex=[0,0,11.6,..]; deltares=[0,0,14.5,22]
marg.mt=1.0; %top margin [cm]
marg.mb=1.5; %bottom margin [cm]
marg.mr=1.0; %right margin [cm]
marg.ml=1.5; %left margin [cm]
marg.sh=1.0; %horizontal spacing [cm]
marg.sv=1.0; %vertical spacing [cm]

%% PLOT PROPERTIES 

prop.ms1=10; 
prop.mf1='g'; 
prop.mt1='s'; 
prop.lw1=1;
prop.ls1='-'; %'-','--',':','-.'
prop.m1=marker; % 'o', '+', '*', '.', 'x','_','|','s','d','^','v','>','<','p','h'... {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h'};
prop.fs=10;
prop.fn='Helvetica';
prop.color=[... %>= matlab 2014b default
 0.0000    0.4470    0.7410;... %blue
 0.8500    0.3250    0.0980;... %red
 0.9290    0.6940    0.1250;... %yellow
 0.4940    0.1840    0.5560;... %purple
 0.4660    0.6740    0.1880;... %green
 0.3010    0.7450    0.9330;... %cyan
 0.6350    0.0780    0.1840];   %brown
% prop.color=[... %<  matlab 2014b default
%  0.0000    0.0000    1.0000;... %blue
%  0.0000    0.5000    0.0000;... %green
%  1.0000    0.0000    0.0000;... %red
%  0.0000    0.7500    0.7500;... %cyan
%  0.7500    0.0000    0.7500;... %purple
%  0.7500    0.7500    0.0000;... %ocre
%  0.2500    0.2500    0.2500];   %grey
set(groot,'defaultAxesColorOrder',prop.color)
% set(groot,'defaultAxesColorOrder','default') %reset the color order to the default value

%set interpreter to Latex (to have bold text use \bfseries{})
% set(groot,'defaultTextInterpreter','Latex'); 
% set(groot,'defaultAxesTickLabelInterpreter','Latex'); 
% set(groot,'defaultLegendInterpreter','Latex');
set(groot,'defaultTextInterpreter','tex'); 
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'defaultLegendInterpreter','tex');

%% COLORBAR AND COLORMAP

ke=1; 
eigen_str={'flow depth','x-discharge','y-discharge','bed level'};
eigen_unit={'[m]','[m^2/s]','[m^2/s]','bed level [m]'};

kr=1; kc=1;
for kr=1:npr
cbar(kr,kc).displacement=[0.0,0,0,0]; 
cbar(kr,kc).location='northoutside';
cbar(kr,kc).label=sprintf('perturbation %s %s',eigen_str{ke},eigen_unit{ke});
end
% brewermap('demo')
cmap=brewermap(100,'RdYlBu');

%center around 0
% ncmap=1000;
% cmap1=brewermap(ncmap,'RdYlGn');
% cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))]);

%cutted centre colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdBu'));
% fact=0.1; %percentage of values to remove from the center
% cmap=[cmap(1:(ncmap-round(fact*ncmap))/2,:);cmap((ncmap+round(fact*ncmap))/2:end,:)];

%compressed colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdYlBu'));
% p1=0.5; %fraction of cmap compressed in p2
% p2=0.7; %fraction of
% np1=round(ncmap*p1);
% np2=round(ncmap*p2);
% x=1:1:ncmap;
% x1=1:1:np1; %x vector
% x2=1:1:ncmap-np1; %x vector
% y1=cmap(1:np1,:); 
% y2=cmap(np1+1:end,:); 
% xq1=linspace(1,np1,np2); %query vector 1
% xq2=linspace(1,ncmap-np1,ncmap-np2); %query vector 2
% vq1=interp1(x1,y1,xq1);
% vq2=interp1(x2,y2,xq2);
% cmap=[vq1;vq2];

%gauss colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdYlBu'));
% x=linspace(0,1,ncmap);
% xs=normcdf(x,0.5,0.25);
% plot(x,xs)
% cmap2=interp1(x,cmap,xs);
% cmap=cmap2;
% %merge 2 colormaps at a specific value. cmap1 spans between [clim_l(1),aux_cmap_change] and cmap 2 between [aux_cmap_change,clim_l(2)]
% ncmap=100; %total number of colors (will be rounded)
% aux_cmap_change=1; %value in which the colormaps change. 
% aux_cmap1_n=round(ncmap*(aux_cmap_change-clim_l(1))/(clim_l(2)-clim_l(1)));
% aux_cmap2_n=round(ncmap*(clim_l(2)-aux_cmap_change)/(clim_l(2)-clim_l(1)));
% cmap1=flipud(brewermap(aux_cmap1_n,'Reds'));
% cmap2=brewermap(aux_cmap2_n,'Greens');
% cmap=[cmap1;cmap2];

%interpolate depending on values
% c=[200e-6,210e-6,300e-6,420e-6,2e-3,5.6e-3,16e-3,20e-3]*1e3;
% nc=numel(c);
% cmap=brewermap(nc-1,'Reds');
% 
% F1=griddedInterpolant(c(1:end-1)',cmap(:,1),'linear','nearest');
% F2=griddedInterpolant(c(1:end-1)',cmap(:,2),'linear','nearest');
% F3=griddedInterpolant(c(1:end-1)',cmap(:,3),'linear','nearest');
% 
% %e.g.
% ct=[0.1e-3:0.1e-3:24e-3]*1e3; %color-dependent value
% nct=numel(ct);
% y=zeros(1,nct); %e.g.
% x=1:1:nct; %e.g.
% for kct=1:nct
% scatter(x(kct),y(kct),20,[F1(ct(kct)),F2(ct(kct)),F3(ct(kct))],'filled')
% end
% han.cbar=colorbar;
% colormap(cmap)
% clim([1,nc])
% han.cbar.Ticks=1:1:nc;
% aux_str=cell(nc,1);
% for kc=1:nc
%     if c(kc)<1
%         aux_str{kc,1}=sprintf('%3.0fe-3',c(kc)*1000);
%     else
%         aux_str{kc,1}=sprintf('%3.1f',c(kc));
%     end
% end
% han.cbar.TickLabels=aux_str;

%% TEXT

%     %irregulra
% kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.sfig(kr,kc).tex={'1','2','a'};
% texti.sfig(kr,kc).clr={prop.color(1,:),prop.color(2,:),'k'};
% texti.sfig(kr,kc).ref={'ul'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];
% 
%     %regular
% text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o'};
% text_str={'a','b';'c','d';'e','f';'g','h'};
% for kr=1:npr
%     for kc=1:npc
% % kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.5,0.5];
% texti.sfig(kr,kc).tex={text_str{kr,kc}}; %#ok
% texti.sfig(kr,kc).clr={'k'};
% texti.sfig(kr,kc).ref={'lr'};
% texti.sfig(kr,kc).fwe={'bold'};
% texti.sfig(kr,kc).rot=[0,90];
%     end
% end
%     %regular more than one
% text_str={'Hir.','Hir.','Hir.';'Ia','Ia','Ia';'Ib','Ib','Ib';'IIa','IIa','IIa';'IIb','IIb','IIb';'IIc','IIc','IIc';'IId','IId','IId'};
% text_str2={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o';'p','q','r';'s','t','u'};
% for kr=1:npr
%     for kc=1:npc
% % kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.5,0.5;0.5,0.5];
% texti.sfig(kr,kc).tex={text_str{kr,kc},text_str2{kr,kc}}; %#ok
% texti.sfig(kr,kc).clr={'k','k'};
% texti.sfig(kr,kc).ref={'ll','lr'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];
%     end
% end

%% LABELS AND LIMITS

% ka=1;
% kr=axis_m(ka,1);
% kc=axis_m(ka,2);

kr=1; kc=1;
% lims.y(kr,kc,1:2)=lims_y;
% lims.x(kr,kc,1:2)=lims_x;
% lims.c(kr,kc,1:2)=lims_c;
xlabels{kr,kc}=x_lab;
ylabels{kr,kc}=y_lab;
% ylabels{kr,kc}=labels4all('dist_mouth',1,lan);
% lims_d.x(kr,kc,1:2)=seconds([3*3600+20*60,6*3600+40*60]); %duration
% lims_d.x(kr,kc,1:2)=[datenum(1998,1,1),datenum(2000,01,01)]; %time

kr=2; kc=1;
% lims.y(kr,kc,1:2)=lims_y;
% lims.x(kr,kc,1:2)=lims_x;
% lims.c(kr,kc,1:2)=lims_c;
xlabels{kr,kc}=x_lab;
ylabels{kr,kc}=y_lab;
% ylabels{kr,kc}=labels4all('dist_mouth',1,lan);
% lims_d.x(kr,kc,1:2)=seconds([3*3600+20*60,6*3600+40*60]); %duration
% lims_d.x(kr,kc,1:2)=[datenum(1998,1,1),datenum(2000,01,01)]; %time

%% FIGURE INITIALIZATION

han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
% set(han.fig,'units','normalized','outerposition',[-1,0,1,1]) %full monitor 2
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
    %if regular
for ka=1:na
    kr=axis_m(ka,1);
    kc=axis_m(ka,2);
    han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
end
    %if irregular
% han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

    %add axis on top
% kr=1; kc=2;
% % pos.sfig=[0.25,0.6,0.25,0.25]; % position of first axes    
% pos.sfig=han.sfig(1,1).Position; % position of first axes    
% han.sfig(kr,kc)=axes('units','normalized','Position',pos.sfig,'XAxisLocation','bottom','YAxisLocation','right','Color','none');

%% HOLD

for ka=1:na
    hold(han.sfig(axis_m(ka,1),axis_m(ka,2)),'on')
end

%% MAP TILES

% kr=1; kc=1;
% OPT.xlim=x_lims;
% OPT.ylim=y_lims;
% OPT.epsg_in=28992; %WGS'84 / google earth
% OPT.epsg_out=28992; %Amersfoort
% OPT.tzl=tiles_zoom(diff(x_lims)); %zoom
% OPT.save_tiles=false;
% OPT.path_save=fullfile(pwd,'earth_tiles');
% OPT.path_tiles='C:\Users\chavarri\checkouts\riv\earth_tiles\'; 
% OPT.map_type=3;%map type
% OPT.han_ax=han.sfig(kr,kc);
% 
% plotMapTiles(OPT);

%% EHY

%get time vecto
% simdef.D3D.dire_sim=sim_path;
% simdef=D3D_simpath(simdef);
% path_map=simdef.file.map;
% 
% ismor=D3D_is(path_map);
% [~,~,time_dnum]=D3D_results_time(path_map,ismor,[192,2]);

%read map data
%data_map.grid=EHY_getGridInfo(filename,{'face_nodes_xy'});
%grid_info=EHY_getGridInfo(path_map,{'face_nodes_xy','XYcen'});

%read data long longitudinal section
%[data_lp,data_lp.grid]=EHY_getMapModelData(path_map,'varName','mesh2d_lyrfrac','t0',time_dnum(1),'tend',time_dnum(end),'disp',1,'pliFile',path_lp);

% kr=1; kc=1;
% set(han.fig,'CurrentAxes',han.sfig(kr,kc))

%plot map data
% EHY_plotMapModelData(data_map.grid,data_map.val,'t',1); 

%plot 1D data along longitudinal section
% plot(data_bl.Scen,data_bl.val)

%plot 2D data (layers) along longitudinal sections
% data_p=data_lp;
% data_p.val=squeeze(data_lp.val(kt,:,:,kf));
% data_p.grid.Ycor=data_lp.grid.Ycor(kt,:,:);
% EHY_plotMapModelData(data_p.grid,data_p.val,'t',1); 

%plot 2D grid
% data_map.grid=EHY_getGridInfo(fname_grd,{'grid'});
% plot(data_map.grid.grid(:,1),data_map.grid.grid(:,2),'color','k')

%plot3D
    %as vertices
% gridInfo = EHY_getGridInfo(mapFile,{'face_nodes_xy','face_nodes_z'});
% Data = EHY_getMapModelData(mapFile,'varName','salinity','t',7,'k',42);
% EHY_plotMapModelData(gridInfo,Data.val);
    %as tiles
% gridInfo = EHY_getGridInfo(mapFile,{'face_nodes_xy','Z'});
% EHY_plotMapModelData(gridInfo,Data.val);

%% PLOT

kr=1; kc=1;    
for kr=1:npr
    kt=kr;
    Q_rec_t=squeeze(Q_rec(ke,:,:,kt))';
    surf(x_in,y_in,Q_rec_t,'edgecolor','none','parent',han.sfig(kr,kc));
end

% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1,'linestyle',prop.ls1,'marker',prop.m1);
% han.sfig(kr,kc).ColorOrderIndex=1; %reset color index
% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1);
% han.p(kr,kc,1).Color(4)=0.2; %transparency of plot
% han.p(kr,kc,1)=scatter(data_2f(data_2f(:,3)==0,1),data_2f(data_2f(:,3)==0,2),prop.ms1,prop.mt1,'filled','parent',han.sfig(kr,kc),'markerfacecolor',prop.mf1);
% surf(x,y,z,c,'parent',han.sfig(kr,kc),'edgecolor','none')
% patch([data_m.Xcen;nan],[data_m.Ycen;nan],[data_m.Scen;nan]*unit_s,[data_m.Scen;nan]*unit_s,'EdgeColor','interp','FaceColor','none','parent',han.sfig(kr,kc)) %line with color

%% PROPERTIES

    %sub11
kr=1; kc=1;   
for kr=1:npr
    kt=kr;
hold(han.sfig(kr,kc),'on')
grid(han.sfig(kr,kc),'on')
% axis(han.sfig(kr,kc),'equal')
han.sfig(kr,kc).Box='on';
% han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
% han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
han.sfig(kr,kc).XScale=XScale;
% han.sfig(kr,kc).YScale='log';
[t_disp,t_str]=time_display(t(kt));
han.sfig(kr,kc).Title.String=sprintf('time = %3.1f %s',t_disp,t_str);
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';
han.sfig(kr,kc).XAxis.Direction='normal'; %'reverse'

%duration ticks
% xtickformat(han.sfig(kr,kc),'hh:mm')
% han.sfig(kr,kc).XLim=lims_d.x(kr,kc,:);
% han.sfig(kr,kc).XTick=hours([4,6]);

%colormap
% kr=1; kc=1;
view(han.sfig(kr,kc),[38,62]);
colormap(han.sfig(kr,kc),cmap);
% if ~isnan(lims.c(kr,kc,1:1))
% caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
% end

end

%% ADD TEXT

    %if irregular
% which_pos_text=[1,1;2,1;3,1;3,2];
% nsf=size(which_pos_text);
% for ksf=1:nsf
%     kr=which_pos_text(ksf,1);
%     kc=which_pos_text(ksf,2);
%         ntxt=numel(texti.sfig(kr,kc).tex);
%         for ktx=1:ntxt
%             %if the specified values are in cm 
%             aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
% %             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
%             text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
%         end
% end
%     %if regular
% for kr=1:npr
%     for kc=1:npc
%         ntxt=numel(texti.sfig(kr,kc).tex);
%         for ktx=1:ntxt
%             %if the specified values are in cm 
%             aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
% %             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
%             text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
%         end
%     end
% end

%% LEGEND

% kr=1; kc=1;
% pos.sfig=han.sfig(kr,kc).Position;
% %han.leg=legend(han.leg,{'hyperbolic','elliptic'},'location','northoutside','orientation','vertical');
% han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,:),1,[])),{'flat bed','sloped bed'},'location','best');
% han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p1(kr,kc,:),1,[]),{labels4all('simulation',1,lan),labels4all('measurement',1,lan)},'location','eastoutside');
% pos.leg=han.leg(kr,kc).Position;
% han.leg(kr,kc).Position=pos.leg+[0,0.3,0,0];
% han.sfig(kr,kc).Position=pos.sfig;

%% COLORBAR

% kr=1; kc=1;
% for kr=1:npr
% pos.sfig=han.sfig(kr,kc).Position;
% han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
% pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
% han.sfig(kr,kc).Position=pos.sfig;
% han.cbar.Label.String=cbar(kr,kc).label;
% 	%set the marks of the colorbar according to your vector, the number of lines and colors of the colormap is np1 (e.g. 20). The colorbar limit is [1,np1].
% % aux2=fliplr(d1_r./La_v); %we have plotted the colors in the other direction, so here we can flip it
% % v2p=[1,5,11,15,np1];
% % han.cbar.Ticks=v2p;
% % aux3=aux2(v2p);
% % aux_str=cell(1,numel(v2p));
% % for ka=1:numel(v2p)
% %     aux_str{ka}=sprintf('%5.3f',aux3(ka));
% % end
% % han.cbar.TickLabels=aux_str;
% end

%% GENERAL
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%% PRINT

fig_print_close(in_p,han.fig,in_p.fig_print,fname);

end %function

%% difference in variable

% ke=4;
% figure
% hold on
% Q_rec_t=squeeze(Q_rec(ke,:,:,end)-Q_rec(ke,:,:,2))';
% surf(x_in,y_in,Q_rec_t,'edgecolor','none');
% view([0,90])
% colorbar

%% plot longitudinal section in time and for all variables

% ky=17;
% 
% cmap=turbo(nt);
% ne=size(R,1);
% ls={'-','--','-.',':'};
% 
% figure
% hold on
% % for ke=1:ne
% for ke=4:ne
%     for kt=1:nt
%         plot(x_in(ky,:),Q_rec(ke,:,ky,kt),'Color',cmap(kt,:),'LineStyle',ls{ke});
%     end
% end

%% plot longitudinal section for a given time, and add velocity

% qx_ref=ECT_input.u*ECT_input.h;
% h_ref=ECT_input.h;
% 
% u=((qx_ref+Q_rec(2,:,:,:))./(h_ref+Q_rec(1,:,:,:)))-qx_ref/h_ref;
% kt=2;
% % ky=17;
% ky=1;
% figure
% hold on
% for ke=1:ne
% plot(x_in(ky,:),Q_rec(ke,:,ky,kt))
% end
% plot(x_in(ky,:),u(1,:,ky,kt))
% legend({'h','qx','qy','eta','u'})