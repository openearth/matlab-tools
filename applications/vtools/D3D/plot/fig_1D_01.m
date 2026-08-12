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
%MATLAB BUGS:
%   -The command to change font name does not work. It does not give error
%   but it does not change the font [151102].
%   -When getting and setting position of ylabels, axis, colorbars,
%   etcetera, if the figure is open in screensize the result is different
%   than if it is not. Moreover, you may need to put a pause(1) after getting
%   positions and setting them [151105].
%   -When something is out of the axes (the box delimited by 'Position')
%   (e.g. text outside the axes), the continuous colors (e.g. from a plot
%   like 'area') have weird lines in .eps.
%   -FontName if interpreter LaTeX: check post 114116
%	-When adding text in duration axis, scatter interprets days while surf interprets hours

% in_p.fig_print=; %0=NO; 1=png; 2=fig; 3=eps; 4=jpg; (accepts vector)
% in_p.fname=;
% in_p.fig_visible=;

function varargout=fig_1D_01(in_p)

% Run parser self-tests when called without inputs.
if nargin==0
    fig_1D_01_test_get_data_into_cell;
    fig_1D_01_test_plot_parsing_to_handles;
    return
end

%% DEFAULTS

% Parse inputs explicitly (no v2struct side effects).
val=isfield_default(in_p,'val',NaN,'output','array');
s=isfield_default(in_p,'s',NaN,'output','array');
s_mea=isfield_default(in_p,'s_mea',NaN,'output','array');
val_mea=isfield_default(in_p,'val_mea',NaN,'output','array');
val0=isfield_default(in_p,'val0',NaN,'output','array');
tim=isfield_default(in_p,'tim',NaN,'output','array'); %datenum

%already return if we cannot plot
sv=size(val);
if numel(sv)>2
    sv=sv(2:end);
    bol_d1=sv==1;
    if ~any(bol_d1)
        messageOut(NaN,'I cannot plot more than 2 dimensions')
        return
    end
end

fig_visible=isfield_default(in_p,'fig_visible',0,'output','array');
fig_print=isfield_default(in_p,'fig_print',1,'output','array');
fname=isfield_default(in_p,'fname','fig','output','array');
fig_size=isfield_default(in_p,'fig_size',[0,0,14.5,12],'output','array');


plot_mea_default=isfield(in_p,'val_mea');
plot_mea=isfield_default(in_p,'plot_mea',plot_mea_default,'output','array');
xlims=isfield_default(in_p,'xlims',[NaN,NaN],'output','array');
ylims=isfield_default(in_p,'ylims',[NaN,NaN],'output','array');
do_include_mea_xylims=isfield_default(in_p,'do_include_mea_xylims',0,'output','array');
do_area=isfield_default(in_p,'do_area',0,'output','array');

lan=isfield_default(in_p,'lan','en','output','array');
fid_log=isfield_default(in_p,'fid_log',NaN,'output','array'); %#ok<NASGU>
plot_gen_struct=0; %#ok<NASGU>
plot_all_struct=0;
all_struct=isfield_default(in_p,'all_struct',[],'output','array');
if isfield(in_p,'gen_struct')
%     plot_gen_struct=1;
    plot_all_struct=1;
    all_struct=in_p.gen_struct;
    all_struct=struct_assign_val(all_struct,'type',1);
end
if isfield(in_p,'all_struct')
    plot_all_struct=1;
end
is_diff=isfield_default(in_p,'is_diff',0,'output','array'); %#ok<NASGU>

plot_val0_default=isfield(in_p,'val0');
plot_val0=isfield_default(in_p,'plot_val0',plot_val0_default,'output','array');
is_std=isfield_default(in_p,'is_std',0,'output','array'); %#ok<NASGU>
if isfield(in_p,'do_title')==0
    if isfield(in_p,'tim')==0
        do_title=0;
    else
        do_title=1;
    end
else
    do_title=in_p.do_title;
end

xlab_str=isfield_default(in_p,'xlab_str','dist_prof','output','array');
if isempty(xlab_str)
    xlab_str='dist_prof';
end
xlab_un=isfield_default(in_p,'xlab_un',1,'output','array');
if isempty(xlab_un)
    xlab_un=1;
end
do_time=isfield_default(in_p,'do_time',0,'output','array'); %add colorbar with time
if do_time
    fig_margin_top=isfield_default(in_p,'fig_margin_top',2.5,'output','array');
    fig_margin_right=isfield_default(in_p,'fig_margin_right',1.3,'output','array');
else
    fig_margin_top=isfield_default(in_p,'fig_margin_top',1,'output','array');
    fig_margin_right=isfield_default(in_p,'fig_margin_right',0.5,'output','array');
end
in_p.fig_margin_top=fig_margin_top;
in_p.fig_margin_right=fig_margin_right;
in_p=gdm_parse_fig_margins(in_p);
fig_margin_top=in_p.fig_margin_top;
fig_margin_bottom=in_p.fig_margin_bottom;
fig_margin_right=in_p.fig_margin_right;
fig_margin_left=in_p.fig_margin_left;
fig_margin_separation_horizontal=in_p.fig_margin_separation_horizontal;
fig_margin_separation_vertical=in_p.fig_margin_separation_vertical;

do_marker=isfield_default(in_p,'do_marker',0,'output','array');
leg_loc=isfield_default(in_p,'leg_loc','eastoutside','output','array');
fig_fs=isfield_default(in_p,'fig_fs',10,'output','array');
leg_move=isfield_default(in_p,'leg_move',NaN,'output','array');
markersize=isfield_default(in_p,'markersize',10,'output','array');
plot_pillars_name=isfield_default(in_p,'plot_pillars_name',0,'output','array');
do_staircase=isfield_default(in_p,'do_staircase',0,'output','array');
ylab=isfield_default(in_p,'ylab','','output','array');
xdir=isfield_default(in_p,'xdir','normal','output','array');
frac=isfield_default(in_p,'frac','','output','array');
ls=isfield_default(in_p,'ls',NaN,'output','array');
cmap=isfield_default(in_p,'cmap',NaN,'output','array');
do_leg=isfield_default(in_p,'do_leg',NaN,'output','array');
is_dom=isfield_default(in_p,'is_dom',0,'output','array'); %#ok<NASGU>
clims=isfield_default(in_p,'clims',[NaN,NaN],'output','array');
title_str=isfield_default(in_p,'title_str','','output','array');
y_scale=isfield_default(in_p,'y_scale','linear','output','array');

%baclward compatibility. Use `variable`.
lab_str=isfield_default(in_p,'lab_str','variable','output','array');
varname=isfield_default(in_p,'varname',lab_str,'output','array');
variable=isfield_default(in_p,'variable',varname,'output','array');
do_replace_underscore=isfield_default(in_p,'do_replace_underscore',1,'output','array');
leg_str=isfield_default(in_p,'leg_str',[],'output','array');
has_leg_mea=isfield(in_p,'leg_mea');
leg_mea=isfield_default(in_p,'leg_mea',[],'output','array');

%% check if printing
in_p_check=in_p;
in_p_check.fig_print=fig_print;
in_p_check.fname=fname;
in_p_check.fid_log=fid_log;
print_fig=check_print_figure(in_p_check);
if ~print_fig
    return
end

%% check dimensions

[s,val]=get_data_into_cell(s,val,do_area);

if do_area
    nv=size(val{1},2); 
else
    nv=numel(val); 
end

%% get limits
val_ylim_check=squeeze(val);
if do_area
    %the max ylimit is on the sum of the lines
    val_ylim_check=sum(val_ylim_check{1,1},2);
    %the minimum is 0
    [~,min_idx]=min(val_ylim_check);
    val_ylim_check(min_idx)=0;
end

if plot_mea && do_include_mea_xylims
    [xlims,ylims]=xlim_ylim(xlims,ylims,{s{:},s_mea},{val_ylim_check{:},squeeze(val_mea)}); %`val` can be a [np,1,nv] matrix and it is valid.
else
    [xlims,ylims]=xlim_ylim(xlims,ylims,s,val_ylim_check); %`val` can be a [np,1,nv] matrix and it is valid.
end


%% SIZE

%figure input
prnt.filename=fname;
prnt.size=fig_size; %slide=[0,0,25.4,19.05]; slide16:9=[0,0,33.867,19.05] tex=[0,0,11.6,..]; deltares=[0,0,14.5,22]
npr=1; %number of plot rows
npc=1; %number of plot columns

%% PLOT PROPERTIES 

prop.ms1=10; 
prop.mf1='g'; 
prop.mt1='s'; 
prop.lw1=1;
% prop.ls1=repmat({'-'},; %'-','--',':','-.'
prop.m1='none'; % 'o', '+', '*', ...
prop.fs=fig_fs;
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

kr=1; kc=1;
cbar(kr,kc).displacement=[0.0,0,0,0]; 
cbar(kr,kc).location='northoutside';
% cbar(kr,kc).label=labels4all('t',1/3600/24,lan); %time as a string. Better no label.
cbar(kr,kc).label='';

% brewermap('demo')

if isnan(cmap(1,1))
    if nv<=9
        cmap=brewermap(nv,'set1');
    else
        if do_time
            nv_tim=100;
            cmap_tmp=jet(nv_tim+1); 
            tim_frac=(tim-tim(1))/(tim(end)-tim(1))*nv_tim;
            cmap=NaN(nv,3);
            for kcolor=1:3
                cmap(:,kcolor)=interp_line_vector(0:1:nv_tim,cmap_tmp(:,kcolor),tim_frac,NaN);
            end
        else
            cmap=jet(nv); 
        end
    end
else
    if size(cmap,2)~=3
        error('The colormap is input and the number of columns must be 3, but it is %d',size(cmap,2))
    end
    if size(cmap,1)>nv
        warning('The colormap is input and there are more colors (%d) than values to plot (%d)',size(cmap,1),nv);
    elseif size(cmap,1)<nv
        error('The number of provided colors (%d) is smaller than the number of values to plot (%d)',size(cmap,1),nv);
    end
end
if do_marker
    mk=repmat({'o','+','*','.','x','s','d','^','v','>','<','p','h'},1,nv); %we are for sure safe...
else
    mk=repmat({'none'},1,nv);
end
if isa(ls,'double') && isnan(ls)
    ls=repmat({'-'},1,nv);
elseif iscell(ls)
    if numel(ls)>nv
        warning('The number of linestyles (%d) is larger than the number of values to plot (%d)',numel(ls),nv)
    elseif numel(ls)<nv
        error('The number of linestyles (%d) is smaller than the number of values to plot',numel(ls),nv)
    end
else
    error('Do not get which kind of input is this.')
end

%If there is only one measurement, we print it in black. If there is more
%than one measurement, we assume there is one measurement for each line,
%and we plot it with the same colour but different linestyle.
if plot_mea
    nmea=size(val_mea,2);
    if nmea==1
        cmap_mea=[0,0,0];
        ls_mea={'-'};
    else
        if nmea~=nv
            error('This case should be added.');
        end
        cmap_mea=cmap;
        ls_mea={'--'};
    end
end
%center around 0
% ncmap=1000;
% cmap1=brewermap(ncmap,'RdYlGn');
% cmap=flipud([flipud(cmap1(1:ncmap/2-ncmap*0.05,:));flipud(cmap1(ncmap/2+ncmap*0.05:end,:))]);

%cutted centre colormap
% ncmap=100;
% cmap=flipud(brewermap(ncmap,'RdBu'));
% fact=0.1; %percentage of values to remove from the center
% cmap=[cmap(1:(ncmap-round(fact*ncmap))/2,:);cmap((ncmap+round(fact*ncmap))/2:end,:)];
% %compressed colormap
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
% %gauss colormap
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

kr=1; kc=1;
lims.y(kr,kc,1:2)=ylims;
lims.x(kr,kc,1:2)=xlims;
if do_time
    if isnan(clims(1))
        clims=[tim(1),tim(end)];
    end
    lims.c(kr,kc,1:2)=clims;
else
    lims.c(kr,kc,1:2)=NaN;
end
if isdatetime(s{1})
    xlabels{kr,kc}='';
else
    xlabels{kr,kc}=labels4all(xlab_str,xlab_un,lan);
end
if isempty(ylab)
    if numel(frac)>1
        frac='';
    end
    in_p_cmap=in_p;
    in_p_cmap.frac=frac;
    in_p_cmap.variable=variable;
    in_p_cmap.lan=lan;
    in_p_cmap.is_diff=is_diff;
    in_p_cmap.is_std=is_std;
    [~,cstring,~]=gdm_cmap_and_string(in_p_cmap,[0,1]);
    ylabels{kr,kc}=cstring;
else
    ylabels{kr,kc}=ylab;
end
% ylabels{kr,kc}=labels4all('dist_mouth',1,lan);
% lims_d.x(kr,kc,1:2)=seconds([3*3600+20*60,6*3600+40*60]); %duration
% lims_d.x(kr,kc,1:2)=[datenum(1998,1,1),datenum(2000,01,01)]; %time


%% FIGURE INITIALIZATION

han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',prnt.size,'visible',fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
% set(han.fig,'units','normalized','outerposition',[-1,0,1,1]) %full monitor 2
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,fig_margin_top,fig_margin_bottom,fig_margin_right,fig_margin_left,fig_margin_separation_horizontal,fig_margin_separation_vertical);

%subplots initialize
    %if regular
for kr=1:npr
    for kc=1:npc
        han.sfig(kr,kc)=subaxis(npr,npc,kc,kr,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);
    end
end
    %if irregular
% han.sfig(1,1)=subaxis(npr,npc,1,1,1,1,'mt',mt,'mb',mb,'mr',mr,'ml',ml,'sv',sv,'sh',sh);

    %add axis on top
% kr=1; kc=2;
% % pos.sfig=[0.25,0.6,0.25,0.25]; % position of first axes    
% pos.sfig=han.sfig(1,1).Position; % position of first axes    
% han.sfig(kr,kc)=axes('units','normalized','Position',pos.sfig,'XAxisLocation','bottom','YAxisLocation','right','Color','none');
%% HOLD
for kr=1:npr
    for kc=1:npc
        hold(han.sfig(kr,kc),'on')
    end
end
%% MAP TILES

% kr=1; kc=1;
% OPT.xlim=x_lims;
% OPT.ylim=y_lims;
% OPT.epsg_in=28992; %WGS'84 / google earth
% OPT.epsg_out=28992; %Amersfoort
% OPT.tzl=tzl; %zoom
% OPT.save_tiles=false;
% OPT.path_save='C:\Users\chavarri\checkouts\riv\earth_tiles\';
% % OPT.path_tiles=fullfile(pwd,'earth_tiles'); 
% OPT.map_type=3;%map type
% OPT.han_ax=han.sfig(kr,kc);
% 
% plotMapTiles(OPT);

%% EHY

% kr=1; kc=1;
% set(han.fig,'CurrentAxes',han.sfig(kr,kc))
% %data_map.grid=EHY_getGridInfo(filename,{'face_nodes_xy'});
% EHY_plotMapModelData(data_map.grid,data_map.val,'t',1); 

%% PLOT

kr=1; kc=1;  
if do_area
    % han.p(kr,kc,:)=area(s,val,'parent',han.sfig(kr,kc));
    han.p(kr,kc,:)=area(s{1},val{1},'parent',han.sfig(kr,kc),'edgecolor','none');
    for kv=1:nv
        han.p(kr,kc,kv).FaceColor=cmap(kv,:);
    end
    %This does not make sense. If area, it needs to be cumulative.
    % for kv=1:nv
        % han.p(kr,kc,kv)=area(s{kv},val{kv},'parent',han.sfig(kr,kc));
        % han.p(kr,kc,kv).FaceColor=cmap(kv,:);
    % end
else
    for kv=1:nv
        if do_staircase
            han.p(kr,kc,kv)=stairs(s{kv},val{kv},'parent',han.sfig(kr,kc),'color',cmap(kv,:),'linewidth',prop.lw1,'linestyle',ls{kv},'marker',mk{kv},'markersize',markersize);
        else
            han.p(kr,kc,kv)=plot(s{kv},val{kv},'parent',han.sfig(kr,kc),'color',cmap(kv,:),'linewidth',prop.lw1,'linestyle',ls{kv},'marker',mk{kv},'markersize',markersize);
        end
    end
end
if ~isempty(leg_str)
    if ~do_area
        if ~iscell(leg_str);
            error('in_p.leg_str should be a cell array of chars');
        end
        str_sim=leg_str;
    else
        %area and we provide a cell array of strings of the same size. We assume it is correct.
        if numel(leg_str)==nv
            str_sim=leg_str;
        else
            for kv=1:nv
                str_sim{kv}=sprintf('%d',kv); %change to runid?
            end
        end
    end

else
    if nv==1
        str_sim={labels4all('sim',1,lan)};
    else
        for kv=1:nv
            str_sim{kv}=sprintf('%d',kv); %change to runid?
        end
    end
end

if plot_all_struct
% plot(([[gen_struct.rkm];[gen_struct.rkm]]),repmat(ylims,numel([gen_struct.rkm]),1)','--','color',[0.6,0.6,0.6],'parent',han.sfig(kr,kc))
    %better loop to control color and whether to plot them or not in the future
    nas=numel([all_struct.rkm]);
    cmap_alls=[0.4,0.4,0.4;0.8,0.8,0.8];
    for kas=1:nas
        plot([all_struct(kas).rkm;all_struct(kas).rkm],ylims,'--','color',cmap_alls(all_struct(kas).type,:),'parent',han.sfig(kr,kc))
    end
end
if plot_mea
%     han.p(kr,kc,2)=plot(mea_etab_p.rkm,mea_etab_p.etab,'parent',han.sfig(kr,kc),'color',prop.color(2,:),'linewidth',prop.lw1,'linestyle',prop.ls1,'marker',prop.m1);
    nfv=numel(han.p(kr,kc,:));
    for kmea=1:nmea
        han.p(kr,kc,nfv+1)=plot(s_mea(:,kmea),val_mea(:,kmea),'parent',han.sfig(kr,kc),'color',cmap_mea(kmea,:),'linewidth',prop.lw1,'linestyle',ls_mea,'marker',prop.m1,'markersize',markersize);
        if ~has_leg_mea
            str_leg={str_sim{:},labels4all('mea',1,lan)}; %check concatenation is right
        else
            str_leg={str_sim{:},leg_mea};
        end
    end
else
    str_leg=str_sim;
end
if plot_val0
    nfv=numel(han.p(kr,kc,:));
    han.p(kr,kc,nfv+1)=plot(s{1},val0,'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle','--','marker',prop.m1,'markersize',markersize);
    str_leg={str_leg{:},'initial'};
end
% han.sfig(kr,kc).ColorOrderIndex=1; %reset color index
% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1);
% han.p(kr,kc,1).Color(4)=0.2; %transparency of plot
% han.p(kr,kc,1)=scatter(data_2f(data_2f(:,3)==0,1),data_2f(data_2f(:,3)==0,2),prop.ms1,prop.mt1,'filled','parent',han.sfig(kr,kc),'markerfacecolor',prop.mf1);
% surf(x,y,z,c,'parent',han.sfig(kr,kc),'edgecolor','none')

%% PROPERTIES

    %sub11
kr=1; kc=1;   
hold(han.sfig(kr,kc),'on')
grid(han.sfig(kr,kc),'on')
% axis(han.sfig(kr,kc),'equal')
han.sfig(kr,kc).Box='on';
han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
% han.sfig(kr,kc).XTickLabel='';
% han.sfig(kr,kc).YTickLabel='';
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
han.sfig(kr,kc).YScale=y_scale;
if do_title && ~do_time && isempty(title_str)
    if ~isnan(tim)
        if numel(tim)==1
            han.sfig(kr,kc).Title.String=datestr(tim,'dd-mm-yyyy HH:MM');
        elseif numel(tim)==2
            han.sfig(kr,kc).Title.String=sprintf('%s - %s',datestr(tim(1),'dd-mm-yyyy HH:MM'),datestr(tim(2),'dd-mm-yyyy HH:MM'));
        else
            error('not sure how more than 2 will look like')
        end
    else
        messageOut(NaN,'Time is a NaN, cannot add it to title.')
    end
else
    han.sfig(kr,kc).Title.String=strrep(title_str,'_','\_');
end
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';
han.sfig(kr,kc).XAxis.Direction=xdir;

%duration ticks
% xtickformat(han.sfig(kr,kc),'hh:mm')
% han.sfig(kr,kc).XLim=lims_d.x(kr,kc,:);
% han.sfig(kr,kc).XTick=hours([4,6]);

%colormap
kr=1; kc=1;
view(han.sfig(kr,kc),[0,90]);
colormap(han.sfig(kr,kc),cmap);
if ~isnan(lims.c(kr,kc,1:1))
caxis(han.sfig(kr,kc),lims.c(kr,kc,1:2));
end

%% ADD TEXT
if plot_all_struct

for kas=1:nas
    if all_struct(kas).type==2 && ~plot_pillars_name; continue; end
    structure_name=strrep(all_struct(kas).name,'ST_',''); %dangerours... better to clean using rwsnames
    idx=strfind(structure_name,'=');
    structure_name(1:idx)='';
    text(all_struct(kas).rkm,ylims(1),structure_name,'Rotation',90)
end
end

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

%legend default
if isnan(do_leg) %nothing has been specified
    if (nv>1 || plot_mea) && ~do_time %if we `do_time`, we are adding a colorbar with the information of the legend
        do_leg=1;
    else
        do_leg=0;
    end
end

kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
if do_leg
    if do_replace_underscore
        str_leg=strrep(str_leg,'_','\_');
    end
    han.leg(kr,kc)=legend(han.sfig(kr,kc),reshape(han.p(kr,kc,:),1,numel(han.p(kr,kc,:))),str_leg,'location',leg_loc);
    pos.leg=han.leg(kr,kc).Position;
end
if ~isnan(leg_move(1))
han.leg.Position=pos.leg+leg_move;
han.sfig(kr,kc).Position=pos.sfig;
end

%% COLORBAR

if do_time
kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
pos.cbar=han.cbar.Position;
% han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
han.sfig(kr,kc).Position=pos.sfig;
han.cbar.Label.String=cbar(kr,kc).label;

% 	%set the marks of the colorbar according to your vector, the number of lines and colors of the colormap is np1 (e.g. 20). The colorbar limit is [1,np1].
% aux2=fliplr(d1_r./La_v); %we have plotted the colors in the other direction, so here we can flip it
% v2p=[1,5,11,15,np1];

v2p=linspace(tim(1),tim(end),3); %dnum
if (tim(end)-tim(1))>1 %if more than 1 day
    tim_format='dd-MMM-yyyy';
else
    tim_format='HH:mm';
end
han.cbar.Ticks=v2p;
% v2p=han.cbar.Ticks;
% aux3=aux2(v2p);
aux_str=cell(1,numel(v2p));
for ka=1:numel(v2p)
    tim_dtime_loc=datetime(v2p(ka),'convertfrom','datenum');
    aux_str{ka}=char(tim_dtime_loc,tim_format);
end
han.cbar.TickLabels=aux_str;
end

%% GENERAL
set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%% ADHOC functions

apply_adhoc_functions(in_p);

%% PRINT

fig_print_close(in_p,han.fig,fig_print,fname);

if nargout>0
    varargout{1}=han;
end

end %function

%%
%% FUNCTION
%%

function [s_cell,val_cell]=get_data_into_cell(s,val,do_area)

if iscell(val) && iscell(s)
    s_cell=s;
    val_cell=val;
    return
end
if ~iscell(val) && iscell(s)
    error('deal with this')
end
if iscell(val) && ~iscell(s)
    error('deal with this')
end

%If we are here, both `s` and `val` are arrays. 

%It is valid to input `val` with size [nx,1,nv]. Here we check that at
%least one dimension is 1. 
sv=size(val);
if numel(sv)>2
    sv=sv(2:end);
    bol_d1=sv==1;
    if ~any(bol_d1)
        messageOut(NaN,'I cannot plot more than 2 dimensions')
        evalin('caller', 'return');
    end
end
val=squeeze(val);

if ~do_area
    %If it is not an area plot, each of the lines goes into a separate
    %cell. 
    nv=size(val,2);
    val_cell=cell(nv,1);
    s_cell=cell(nv,1);
    for kv=1:nv
        val_cell{kv,1}=val(:,kv);
        s_cell{kv,1}=s;
    end
else
    %If it is an area plot, the variable to plot is `size(val{1})=[np,nv]`.
    %That is, the matrix is inside the first element of a cell array. 
    val_cell{1}=val;
    s_cell{1}=s;
end

end %function

function fig_1D_01_test_get_data_into_cell()

% Case 1: array input [nx,1] -> one line in one cell.
s=(1:5)';
val=[10;11;12;13;14];
[s_cell,val_cell]=get_data_into_cell(s,val,false);
assert(iscell(s_cell) && iscell(val_cell),'Output should be cell arrays.');
assert(numel(s_cell)==1 && numel(val_cell)==1,'Single-line input should produce one cell.');
assert(isequal(s_cell{1},s),'Unexpected x-data for single-line case.');
assert(isequal(val_cell{1},val),'Unexpected y-data for single-line case.');

% Case 2: array input [nx,nv] -> one cell per line/column.
val=[1 10;2 20;3 30;4 40;5 50];
[s_cell,val_cell]=get_data_into_cell(s,val,false);
assert(numel(s_cell)==2 && numel(val_cell)==2,'Two-line input should produce two cells.');
assert(isequal(val_cell{1},val(:,1)),'First line was not parsed correctly.');
assert(isequal(val_cell{2},val(:,2)),'Second line was not parsed correctly.');
assert(isequal(s_cell{1},s) && isequal(s_cell{2},s),'x-data should be repeated for every line.');

% Case 3: array input [nx,1,nv] -> squeeze and one cell per line.
val3=reshape(1:10,[5,1,2]);
[s_cell,val_cell]=get_data_into_cell(s,val3,false);
assert(numel(val_cell)==2,'3D [nx,1,nv] input should produce nv cells.');
assert(isequal(val_cell{1},val3(:,1,1)),'First squeezed line was not parsed correctly.');
assert(isequal(val_cell{2},val3(:,1,2)),'Second squeezed line was not parsed correctly.');
assert(isequal(s_cell{1},s) && isequal(s_cell{2},s),'x-data should be repeated for squeezed 3D input.');

% Case 4: cell input -> passthrough.
s_in={s,s+100};
val_in={val3(:,1,1),val3(:,1,2)};
[s_cell,val_cell]=get_data_into_cell(s_in,val_in,false);
assert(isequal(s_cell,s_in),'Cell x-input should pass through unchanged.');
assert(isequal(val_cell,val_in),'Cell y-input should pass through unchanged.');

% Case 5: do_area=true -> one cell containing full matrix.
val_area=[1 2 3;4 5 6;7 8 9;10 11 12;13 14 15];
[s_cell,val_cell]=get_data_into_cell(s,val_area,true);
assert(numel(s_cell)==1 && numel(val_cell)==1,'Area input should produce one cell.');
assert(isequal(s_cell{1},s),'Area x-data was not parsed correctly.');
assert(isequal(val_cell{1},val_area),'Area y-data matrix should be preserved.');

% Case 6: mixed cell/array inputs should error.
did_error=false;
try
    get_data_into_cell({s,s},val_area,false);
catch
    did_error=true;
end
assert(did_error,'Expected error for mixed cell/array input (s as cell, val as array).');

did_error=false;
try
    get_data_into_cell(s,{val_area},false);
catch
    did_error=true;
end
assert(did_error,'Expected error for mixed cell/array input (s as array, val as cell).');

fprintf('fig_1D_01 get_data_into_cell tests passed.\n');

end %function

function fig_1D_01_test_plot_parsing_to_handles()

% Try to bootstrap the local repository path for batch/non-interactive runs.
try
    this_dir=fileparts(mfilename('fullpath'));
    repo_root=this_dir;
    for kup=1:4
        repo_root=fileparts(repo_root);
    end
    if exist(repo_root,'dir')~=0
        addpath(genpath(repo_root));
    end
catch
    % Ignore bootstrap issues; dependency checks below will report missing items.
end

required_funs={...
    'isfield_default',...
    'gdm_parse_fig_margins',...
    'v2struct',...
    'check_print_figure',...
    'xlim_ylim',...
    'pre_subaxis',...
    'subaxis',...
    'labels4all',...
    'gdm_cmap_and_string',...
    'brewermap',...
    'apply_adhoc_functions',...
    'fig_print_close'};
missing_funs={};
for kfun=1:numel(required_funs)
    if exist(required_funs{kfun},'file')==0 && exist(required_funs{kfun},'builtin')==0
        missing_funs{end+1}=required_funs{kfun}; %#ok<AGROW>
    end
end
if ~isempty(missing_funs)
    fprintf('fig_1D_01 plot parsing tests skipped (missing dependencies on MATLAB path): %s\n',strjoin(missing_funs,', '));
    return
end

% Case 1: numeric [nx,nv] input should produce one line object per column.
s=(1:6)';
val=[1 10;2 20;3 30;4 40;5 50;6 60];
in_p=fig_1D_01_test_base_input(s,val);
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==2,'Expected two plotted lines for two-column input.');
assert(isequal(han.p(1,1,1).XData(:),s),'Unexpected XData for first plotted line.');
assert(isequal(han.p(1,1,2).XData(:),s),'Unexpected XData for second plotted line.');
assert(isequal(han.p(1,1,1).YData(:),val(:,1)),'Unexpected YData for first plotted line.');
assert(isequal(han.p(1,1,2).YData(:),val(:,2)),'Unexpected YData for second plotted line.');
close(han.fig);

% Case 2: numeric [nx,1,nv] input should be squeezed and plotted as nv lines.
val3=reshape(1:12,[6,1,2]);
in_p=fig_1D_01_test_base_input(s,val3);
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==2,'Expected two plotted lines for [nx,1,nv] input.');
assert(isequal(han.p(1,1,1).YData(:),val3(:,1,1)),'Unexpected YData for first squeezed line.');
assert(isequal(han.p(1,1,2).YData(:),val3(:,1,2)),'Unexpected YData for second squeezed line.');
close(han.fig);

% Case 3: cell input with different x-vectors should preserve per-line x-data.
s_cell={s,s+100};
val_cell={val3(:,1,1),val3(:,1,2)};
in_p=fig_1D_01_test_base_input(s_cell,val_cell);
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==2,'Expected two plotted lines for cell input.');
assert(isequal(han.p(1,1,1).XData(:),s_cell{1}(:)),'Cell input first XData not preserved.');
assert(isequal(han.p(1,1,2).XData(:),s_cell{2}(:)),'Cell input second XData not preserved.');
assert(isequal(han.p(1,1,1).YData(:),val_cell{1}(:)),'Cell input first YData not preserved.');
assert(isequal(han.p(1,1,2).YData(:),val_cell{2}(:)),'Cell input second YData not preserved.');
close(han.fig);

% Case 4: area mode should create area objects and preserve matrix values.
val_area=[1 2 3;2 3 4;3 4 5;4 5 6;5 6 7;6 7 8];
in_p=fig_1D_01_test_base_input({s},{val_area});
in_p.do_area=1;
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==3,'Expected three area patches for three columns.');
assert(all(arrayfun(@(h) isa(h,'matlab.graphics.chart.primitive.Area'),reshape(han.p(1,1,:),[],1))),...
    'Expected area objects in do_area mode.');
assert(isequal(han.p(1,1,1).YData(:),val_area(:,1)),'Area first YData not preserved.');
assert(isequal(han.p(1,1,2).YData(:),val_area(:,2)),'Area second YData not preserved.');
assert(isequal(han.p(1,1,3).YData(:),val_area(:,3)),'Area third YData not preserved.');
close(han.fig);

% Case 5: staircase mode should create stair objects.
in_p=fig_1D_01_test_base_input(s,val);
in_p.do_staircase=1;
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==2,'Expected two staircase objects.');
assert(all(arrayfun(@(h) isa(h,'matlab.graphics.chart.primitive.Stair'),reshape(han.p(1,1,:),[],1))),...
    'Expected stair objects in do_staircase mode.');
close(han.fig);

% Case 6: measurement and val0 inputs should append extra plotted objects.
in_p=fig_1D_01_test_base_input(s,val(:,1));
in_p.s_mea=s;
in_p.val_mea=val(:,1)+100;
in_p.plot_mea=1;
in_p.val0=val(:,1)-100;
in_p.plot_val0=1;
in_p.do_leg=0;
han=fig_1D_01(in_p);
assert(numel(han.p(1,1,:))==3,'Expected simulation + measurement + val0 plotted objects.');
assert(isequal(han.p(1,1,1).YData(:),val(:,1)),'Simulation YData not preserved.');
assert(isequal(han.p(1,1,2).YData(:),in_p.val_mea(:)),'Measurement YData not preserved.');
assert(isequal(han.p(1,1,3).YData(:),in_p.val0(:)),'Initial condition YData not preserved.');
close(han.fig);

fprintf('fig_1D_01 plot parsing tests passed.\n');

end %function

function in_p=fig_1D_01_test_base_input(s,val)

% Keep tests deterministic and side-effect free.
in_p.s=s;
in_p.val=val;
in_p.fig_print=0;
in_p.fig_visible=0;
in_p.fname='fig_1D_01_unit_test';
in_p.variable='test_var';

end %function