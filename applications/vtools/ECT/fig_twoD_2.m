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

function fig_twoD_2(in_2D,max_cl_m,max_gr_m,xm_k,ym_k,xm_l,ym_l)

%% DEFAULT

if isfield(in_2D,'fig')==0
    in_2D.fig.dummy=NaN;
end
if isfield(in_2D.fig,'fig_visible')==0
    in_2D.fig.fig_visible=true;
end
if isfield(in_2D.fig,'fig_print')==0
    in_2D.fig.fig_print=false;
end
if isfield(in_2D.fig,'fig_name')==0
    in_2D.fig.fig_name='domain';
end
in_2D.fig=isfield_default(in_2D.fig,'fname',in_2D.fig.fig_name);
if isfield(in_2D.fig,'print_size')==0
    in_2D.fig.print_size=[0,0,17,12];
end
in_2D.fig=isfield_default(in_2D.fig,'title_str',repmat({'growth rate [rad/s]'},1,size(max_gr_m,3)));
in_2D.fig=isfield_default(in_2D.fig,'plot_max',1);

in_2D.fig=isfield_default(in_2D.fig,'contours_l',{});
if isempty(in_2D.fig.contours_l)
    in_2D.fig=isfield_default(in_2D.fig,'plot_set_contour_l',0);
else
    in_2D.fig=isfield_default(in_2D.fig,'plot_set_contour_l',1);
end

in_2D.fig=isfield_default(in_2D.fig,'contours_k',{});
if isempty(in_2D.fig.contours_k)
    in_2D.fig=isfield_default(in_2D.fig,'plot_set_contour_k',0);
else
    in_2D.fig=isfield_default(in_2D.fig,'plot_set_contour_k',1);
end

in_2D.fig=isfield_default(in_2D.fig,'do_colorbar',0);
in_2D.fig=isfield_default(in_2D.fig,'clims_k',NaN);
in_2D.fig=isfield_default(in_2D.fig,'clims_l',NaN);

v2struct(in_2D) %better to keep structure below
v2struct(fig)

%% DIMENSIONS


ne=size(max_cl_m,3)+3;
nsim=size(max_gr_m,3); 

%% data rework

%max location
[max_idx_sc_val,max_idx_sc]=max(max_gr_m(:));
[max_idx_sc_x,max_idx_sc_y]=ind2sub(size(max_gr_m),max_idx_sc);

ks=1; %to loop over contours?

%%
%figure input
% prnt.filename=sprintf('dom_%s',str_p{1,ks});
prnt.filename=fig_name;
prnt.size=print_size; %slide=[0,0,25.4,19.05]; tex=[0,0,11.6,..]
npr=nsim; %number of plot rows
npc=2; %number of plot columns
marg.mt=1.0; %top margin [cm]
marg.mb=1.5; %bottom margin [cm]
marg.mr=0.5; %right margin [cm]
marg.ml=1.5; %left margin [cm]
marg.sh=1.5; %horizontal spacing [cm]
marg.sv=1.0; %vertical spacing [cm]

prop.ms1=20; 
prop.lw1=1;
prop.ls1='-';
prop.ls2='--';
prop.fs=10;
prop.fn='Helvetica';
prop.markertype1='o';
prop.markertype2='s';
% prop.color=[... %>= matlab 2014b default
%  0.0000    0.4470    0.7410;... %blue
%  0.8500    0.3250    0.0980;... %red
%  0.9290    0.6940    0.1250;... %yellow
%  0.4940    0.1840    0.5560;... %purple
%  0.4660    0.6740    0.1880;... %green
%  0.3010    0.7450    0.9330;... %cyan
%  0.6350    0.0780    0.1840];   %brown
% prop.color=[... %<  matlab 2014b default
%  0.0000    0.0000    1.0000;... %blue
%  0.0000    0.5000    0.0000;... %green
%  1.0000    0.0000    0.0000;... %red
%  0.0000    0.7500    0.7500;... %cyan
%  0.7500    0.0000    0.7500;... %purple
%  0.7500    0.7500    0.0000;... %ocre
%  0.2500    0.2500    0.2500];   %grey
% prop.color=[... %<  matlab 2014b default
%  0.0000    0.0000    0.0000;... %black
%  0.0000    0.0000    0.0000;... %black
%  1.0000    0.0000    0.0000;... %red
%  0.0000    0.7500    0.7500;... %cyan
%  0.7500    0.0000    0.7500;... %purple
%  0.7500    0.7500    0.0000;... %ocre
%  0.2500    0.2500    0.2500];   %grey

% set(groot,'defaultAxesColorOrder',prop.color)
% set(groot,'defaultAxesColorOrder','default') %reset the color order to the default value

%set interpreter to Latex (to have bold text use \bfseries{})
% set(groot,'defaultTextInterpreter','Latex'); 
% set(groot,'defaultAxesTickLabelInterpreter','Latex'); 
% set(groot,'defaultLegendInterpreter','Latex');
set(groot,'defaultTextInterpreter','tex'); 
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'defaultLegendInterpreter','tex');

%colorbar
kr=1; kc=2;
cbar(kr,kc).displacement=[0.0,0,0,0]; 
cbar(kr,kc).location='northoutside';
cbar(kr,kc).label='growth rate [rad/s]';

%text
    %irregulra
% kr=1; kc=1;
% texti.sfig(kr,kc).pos=[0.015,0.5e-3;0.03,-0.5e-3;0.005,-1e-3];
% texti.sfig(kr,kc).tex={'1','2','a'};
% texti.sfig(kr,kc).clr={prop.color(1,:),prop.color(2,:),'k'};
% texti.sfig(kr,kc).ref={'ul'};
% texti.sfig(kr,kc).fwe={'bold','normal'};
% texti.sfig(kr,kc).rot=[0,90];

    %regular
% text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o'};
text_str={'a','b';'c','d';'e','f';'g','h'};
for kr=1:npr
    for kc=1:npc
% kr=1; kc=1;
texti.sfig(kr,kc).pos=[0.5,0.5];
texti.sfig(kr,kc).tex={text_str{kr,kc}}; %#ok
texti.sfig(kr,kc).clr={'k'};
texti.sfig(kr,kc).ref={'lr'};
texti.sfig(kr,kc).fwe={'bold'};
texti.sfig(kr,kc).rot=[0,0];
    end
end
    %regular more than one
% text_str={'a','b','c';'d','e','f';'g','h','i';'j','k','l';'m','n','o';'p','q','r';'s','t','u'};
% % text_str1={'S','U','Hir.';'Ia','Ia','Ia';'Ib','Ib','Ib';'IIa','IIa','IIa';'IIb','IIb','IIb';'IIc','IIc','IIc';'IId','IId','IId'};
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

clim_l=max(abs(min(max_gr_m(:))),abs(max(max_gr_m(:))));
clim_f=[-clim_l,clim_l];

if exist('f_clim','var')==0
    f_clim(1,1:2)=[1,1];
end

%axes and limits
for ksim=1:nsim

kr=ksim; kc=1;
lims.x(kr,kc,1:2)=[min(xm_k(:)),max(xm_k(:))];
lims.y(kr,kc,1:2)=[min(ym_k(:)),max(ym_k(:))];
if isnan(clims_k)
    lims.c(kr,kc,1:2)=clim_f*f_clim(ks,1);
else
    lims.c(kr,kc,1:2)=clims_k(ksim,:);
end
xlabels{kr,kc}='k_{wx} [rad/m]';
ylabels{kr,kc}='k_{wy} [rad/m]';

kr=ksim; kc=2;
lims.x(kr,kc,1:2)=[min(xm_l(:)),max(xm_l(:))];
lims.y(kr,kc,1:2)=[min(ym_l(:)),max(ym_l(:))];
if isnan(clims_l)
    lims.c(kr,kc,1:2)=clim_f*f_clim(ks,2);
else
    lims.c(kr,kc,1:2)=clims_l(ksim,:);
end
xlabels{kr,kc}='l_{wx} [m]';
ylabels{kr,kc}='l_{wy} [m]';

end

% brewermap('demo')
ncmap=1000000;
cmap1=brewermap(ncmap,'RdYlGn');
cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));0,0,0;flipud(cmap1(ncmap/2+ncmap*0.05+1:end,:))]);

%figure initialize
han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
% set(han.fig,'units','normalized','outerposition',[-1,0,1,1]) %full monitor 2
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,marg.mt,marg.mb,marg.mr,marg.ml,marg.sh,marg.sv);

%subplots initialize
    %if regular
for kr=1:npr
    for kc=1:npc
        han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
    end
end
    %if irregular
% han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

    %add axis to sub1
%     aux_yco=-0.37;
% pos.sfig=han.sfig(1,1).Position; % position of first axes    
% han.sfig(1,2)=axes('units','normalized','Position',pos.sfig+[0  ,0,0,aux_yco],'XAxisLocation','top','YAxisLocation','right','XColor','none','YColor',prop.color(1,:),'Color','none','ylim',[0,1]);
% han.sfig(1,2).YLabel.String='sediment transport rate (coarse) [g/min]';

for ksim=1:nsim
    kr=ksim;
    for kc=1:npc
hold(han.sfig(kr,kc),'on')
grid(han.sfig(kr,kc),'on')
% axis(han.sfig(kr,kc),'equal')
han.sfig(kr,kc).Box='on';
han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
if kr==npr
    han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
else
    han.sfig(kr,kc).XTickLabel='';
    % han.sfig(kr,kc).XTick=[];  
end
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};

% han.sfig(kr,kc).YTickLabel='';

% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
% han.sfig(kr,kc).YScale='log';
if kc==1
    han.sfig(kr,kc).Title.String=title_str{kr};
end
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';
    end
end

%plots
% plot_v1{1,1}=[-1,0,5,10,15,20,25];
% plot_v2{1,1}=[-1000,-10,-0.01,0];

for ksim=1:nsim
    kr=ksim;
kc=1;    
if plot_set_contour_k
    han.p1=contourf(xm_k,ym_k,max_gr_m(:,:,ksim),contours_k{kr},'showtext','on','parent',han.sfig(kr,kc));
else
    han.p1=contourf(xm_k,ym_k,max_gr_m(:,:,ksim),'showtext','on','parent',han.sfig(kr,kc));
end
for ke=1:ne-3
    [han.p2,aux.p]=contour(xm_k,ym_k,max_cl_m(:,:,ke),[0,0],'showtext','off','parent',han.sfig(kr,kc));
    aux.p.LineWidth=2;
    aux.p.Color='k';
%     han.p2=contour(xm_k,ym_k,max_cl_m(:,:,ke),'showtext','on')
end
han.sfig(kr,kc).ColorOrderIndex=1; %reset color index

kc=2;    
if plot_set_contour_l
    han.p1=contourf(xm_l,ym_l,max_gr_m(:,:,ksim),contours_l{kr},'showtext','on','parent',han.sfig(kr,kc));
else
    han.p1=contourf(xm_l,ym_l,max_gr_m(:,:,ksim),'showtext','on','parent',han.sfig(kr,kc));
end
for ke=1:ne-3
    [han.p2,aux.p]=contour(xm_l,ym_l,max_cl_m(:,:,ke),[0,0],'showtext','off','parent',han.sfig(kr,kc));
    aux.p.LineWidth=2;
    aux.p.Color='k';
%     han.p2=contour(xm_l,ym_l,max_cl_m(:,:,ke),'showtext','on')
end
han.sfig(kr,kc).ColorOrderIndex=1; %reset color index

if plot_max
scatter3(xm_l(max_idx_sc_x,max_idx_sc_y),ym_l(max_idx_sc_x,max_idx_sc_y),max_idx_sc_val,50,'k','parent',han.sfig(kr,kc),'filled');
end



%colormap
for kc=1:npc
% kr=1; kc=1;
% view(han.sfig(kr,kc),[0,90]);
colormap(han.sfig(kr,kc),cmap);
caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
end

end %ksim

%text
% kr=1; kc=1;  

%if the specified values are in cm 
% texti.sfig(kr,kc).pos=cm2ax(texti.sfig(kr,kc).pos,han.fig,han.sfig(kr,kc),'reference','ll');

    %if irregular
% text(texti.sfig(kr,kc).pos(1),texti.sfig(kr,kc).pos(2),texti.sfig(kr,kc).tex,'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr)
    %if regular
for kr=1:npr
    for kc=1:npc
        ntxt=numel(texti.sfig(kr,kc).tex);
        for ktx=1:ntxt
            %if the specified values are in cm 
            aux.pos=cm2ax(texti.sfig(kr,kc).pos(ktx,:),han.fig,han.sfig(kr,kc),'reference',texti.sfig(kr,kc).ref{ktx});
%             text(texti.sfig(kr,kc).pos(1,1),texti.sfig(kr,kc).pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight','bold')
            text(aux.pos(1,1),aux.pos(1,2),texti.sfig(kr,kc).tex{ktx},'parent',han.sfig(kr,kc),'color',texti.sfig(kr,kc).clr{ktx},'fontweight',texti.sfig(kr,kc).fwe{ktx},'rotation',texti.sfig(kr,kc).rot(ktx))
        end
    end
end

%legend
% kr=1; kc=1;
% han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,1:2),1,2),{'\tau<1','\tau>1'},'location','south');

%colorbar
if do_colorbar
    kr=1; kc=1;
    pos.sfig=han.sfig(kr,kc).Position;
    han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
    pos.cbar=han.cbar.Position;
    han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
    han.sfig(kr,kc).Position=pos.sfig;
    han.cbar.Label.String=cbar(kr,kc).label;
end

for ksim=1:nsim
    kr=ksim;
kc=1;
han.sfig(kr,kc).Title.Units='normalized';
pos.cbar=han.sfig(kr,kc).Title.Position;
han.sfig(kr,kc).Title.Position=pos.cbar+[0.6,0.05,0];
end

%general
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%print
in_p=fig;
fig_print_close(in_p,han.fig,in_p.fig_print,fname);

end %function
