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

function fig_map_sal_01(in_p)

%% DEFAULTS

if isfield(in_p,'fig_visible')==0
    in_p.fig_visible=1;
end
if isfield(in_p,'fig_print')==0
    in_p.fig_print=0;
end
if isfield(in_p,'fname')==0
    in_p.fname='fig';
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
if isfield(in_p,'is_background')==0
    in_p.is_background=0;
end
if isfield(in_p,'is_diff')==0
    in_p.is_diff=0;
end
if isfield(in_p,'is_percentage')==0
    in_p.is_percentage=0;
end
in_p.plot_vector=0;
if isfield(in_p,'vec_x')
    in_p.plot_vector=1;
end
if isfield(in_p,'do_axis_equal')==0
    in_p.do_axis_equal=1;
end
if isfield(in_p,'fact')==0
    in_p.fact=1;
end
if isfield(in_p,'do_3D')==0
    in_p.do_3D=0;
end
if isfield(in_p,'do_cbar')==0
    in_p.do_cbar=1;
end
if isfield(in_p,'zlims')==0
    in_p.zlims=NaN;
end

if isfield(in_p,'views')==0
    in_p.views=[45,45];
end   

if isfield(in_p,'str_idx')==0
    in_p.str_idx=NaN; 
end
if isfield(in_p,'vector_color')==0
    in_p.vector_color='w'; 
end
if isfield(in_p,'plot_tiles')==0
    in_p.plot_tiles=0;
end
if isfield(in_p,'Lref')==0
    in_p.Lref='+NAP';
end

in_p=isfield_default(in_p,'tim',NaT(0,0));
if isempty(in_p.tim)
    in_p.do_title=0;
else
    if ~isdatetime(in_p.tim)
        in_p.tim=datetime(in_p.tim,'ConvertFrom','datenum');
    end
    in_p=isfield_default(in_p,'do_title',1);
end
in_p=isfield_default(in_p,'tim_mea',in_p.tim);

in_p=isfield_default(in_p,'filter_lim',[inf,-inf]);
in_p=isfield_default(in_p,'filter_lims',in_p.filter_lim);
if any(isnan(in_p.filter_lims))
    in_p.filter_lims=[inf,-inf];
end

if isfield(in_p,'cmap_cut_edges')==0
    in_p.cmap_cut_edges=NaN;
end
%For D3D4 we need a reshaped version for plotting vectors and dealing with limits. It does nothing to FM. 
if isfield(in_p,'gridInfo_v')==0
    in_p.gridInfo_v=vectorize_structure(in_p.gridInfo);
end
if isfield(in_p,'vector_scale')==0
    in_p.vector_scale=1;
end
if isfield(in_p,'font_size')==0
    in_p.font_size=10;
end

if in_p.do_measurements
    in_p=isfield_default(in_p,'fig_size',[0,0,25,14]);
    in_p=isfield_default(in_p,'fig_margin_top',2.5);
else
    in_p=isfield_default(in_p,'fig_size',[0,0,14,14]);
end
in_p=gdm_parse_fig_margins(in_p);

if isfield(in_p,'xlims')==0 || isnan(in_p.xlims(1))
    [in_p.xlims,in_p.ylims]=D3D_gridInfo_lims(in_p.gridInfo);
end
in_p=isfield_default(in_p,'epsg_in',28992);
in_p=isfield_default(in_p,'epsg_out',in_p.epsg_in);
in_p=isfield_default(in_p,'save_tiles',false);
in_p=isfield_default(in_p,'tiles',{});

in_p=isfield_default(in_p,'measurements_images',cell(0,0));
if isempty(in_p.measurements_images)
    in_p.do_measurements=0;
else
    in_p=isfield_default(in_p,'do_measurements',1);
end


in_p=isfield_default(in_p,'contour_lines',NaN);
if ~isnan(in_p.contour_lines)
    in_p=isfield_default(in_p,'plot_contour',1);
else
    in_p=isfield_default(in_p,'plot_contour',0);
end


v2struct(in_p)

%% check if printing
print_fig=check_print_figure(in_p);
if ~print_fig
    return
end

%% faces or edges

is_faces=1; %default is faces and we check whether it is edges
if isfield(gridInfo,'edge_nodes')==1 %backward compatibility
    if numel(val)==size(gridInfo.edge_nodes,2)
        is_faces=0;
    end
end

%% units

switch unit
    case {'cl','cl_surf'}
        clims=sal2cl(1,clims);
        val=sal2cl(1,val);
end

%% filter values

bol_out=val>filter_lims(1) & val<filter_lims(2);
val(bol_out)=NaN;
stot=numel(val);
sbo=sum(bol_out);

if sbo>0
    messageOut(NaN,sprintf('Removed %d points (%4.2f %%)',sbo,sbo/stot*100))
end

%% dependent

if is_faces
    bol_in=gridInfo_v.Xcen>xlims(1) & gridInfo_v.Xcen<xlims(2) & gridInfo_v.Ycen>ylims(1) & gridInfo_v.Ycen<ylims(2);
else
    bol_in=gridInfo_v.Xu>xlims(1) & gridInfo_v.Xu<xlims(2) & gridInfo_v.Yu>ylims(1) & gridInfo_v.Yu<ylims(2);
end

val(~bol_in)=NaN; %do not plot points outside the domain

if isnan(zlims)
    zlims=clims;
end

%% SIZE

%square option
npr=1; %number of plot rows
if do_measurements
    npc=2; %number of plot columns
else
    npc=1; %number of plot columns
end
axis_m=allcomb(1:1:npr,1:1:npc);

%some of them
% axis_m=[1,1;2,1;2,2];

na=size(axis_m,1);

%figure input
prnt.filename=fname;
fig_size; %slide=[0,0,25.4,19.05]; slide16:9=[0,0,33.867,19.05] tex=[0,0,11.6,..]; deltares=[0,0,14.5,22]

%% PLOT PROPERTIES 

prop.ms1=10; 
prop.mf1='g'; 
prop.mt1='s'; 
prop.lw1=1;
prop.ls1='-'; %'-','--',':','-.'
prop.m1='none'; % 'o', '+', '*', '.', 'x','_','|','s','d','^','v','>','<','p','h'...
prop.fs=font_size;
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
if do_measurements
    cbar(kr,kc).displacement=[0.25,0.1,0,0]; 
else
    cbar(kr,kc).displacement=[0.0,0,0,0]; %does not really work well. It changes position. 
end
cbar(kr,kc).location='northoutside';

in_p.variable=unit; %this is a mess
in_p.unit=fact; %this is a mess
in_p.frac=str_idx;
in_p.val=val; %it can be filtered
[cmap,cbar(kr,kc).label,clims]=gdm_cmap_and_string(in_p,val);

%% LABELS AND LIMITS

kr=1; 
for kc=1:npc
    lims.y(kr,kc,1:2)=ylims;
    lims.x(kr,kc,1:2)=xlims;
    lims.c(kr,kc,1:2)=clims;
    lims.z(kr,kc,1:2)=zlims;
    xlabels{kr,kc}=labels4all('x',1,lan);
    ylabels{kr,kc}=labels4all('y',1,lan);
    % ylabels{kr,kc}=labels4all('dist_mouth',1,lan);
    % lims_d.x(kr,kc,1:2)=seconds([3*3600+20*60,6*3600+40*60]); %duration
    % lims_d.x(kr,kc,1:2)=[datenum(1998,1,1),datenum(2000,01,01)]; %time
end

%% FIGURE INITIALIZATION

han.fig=figure('name',prnt.filename);
set(han.fig,'paperunits','centimeters','paperposition',fig_size,'visible',fig_visible)
set(han.fig,'units','normalized','outerposition',[0,0,1,1]) %full monitor 1
% set(han.fig,'units','normalized','outerposition',[-1,0,1,1]) %full monitor 2
[mt,mb,mr,ml,sh,sv]=pre_subaxis(han.fig,fig_margin_top,fig_margin_bottom,fig_margin_right,fig_margin_left,fig_margin_separation_horizontal,fig_margin_separation_vertical);

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

if plot_tiles
    kr=1;
    for kc=1:npc    
        OPT.xlim=xlims;
        OPT.ylim=ylims;
        OPT.epsg_in=epsg_in; %WGS'84 / google earth
        OPT.epsg_out=epsg_out; %Amersfoort
        dx=diff(xlims);
        tzl=tiles_zoom(dx);
        OPT.tzl=tzl; %zoom
        OPT.save_tiles=save_tiles;
        OPT.path_save=fpath_tiles; %mat file to save tiles
        OPT.path_tiles=in_p.path_tiles; %folder with tiles
        OPT.map_type=3;%map type
        OPT.han_ax=han.sfig(kr,kc);
        OPT.tiles=tiles;
        
        plotMapTiles(OPT);
    end
end

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

%% PLOT

%% model

kr=1; kc=1;    
set(han.fig,'CurrentAxes',han.sfig(kr,kc))
if is_faces
    % if do_3D
        EHY_plotMapModelData(gridInfo,val,'t',1);
    %     EHY_plotMapModelData(gridInfo,val,'t',1,'edgecolor',edgecolor,'linestyle',linestyle); 
    % else
        EHY_plotMapModelData(gridInfo,val,'t',1); 
    % end
else
    ne=size(val,2);
    for ke=1:ne
        if ~isnan(val(ke))
            c_idx=round(interp_line([clims(1),clims(2)],[0,ncolor],val(ke)));
            c_idx=max([c_idx,1]);
            c_idx=min([c_idx,ncolor]);
            xv=[gridInfo.Xcor(gridInfo.edge_nodes(1,ke)),gridInfo.Xcor(gridInfo.edge_nodes(2,ke))];
            yv=[gridInfo.Ycor(gridInfo.edge_nodes(1,ke)),gridInfo.Ycor(gridInfo.edge_nodes(2,ke))];
            plot(xv,yv,'color',cmap(c_idx,:))
        end
    end
end

if plot_vector
    %before it was `gridInfo.Xcen` which was a column vector. Now it is `gridInfo_v.Xcen` which is 
    %a row vector. I hope nothing is broken.
    quiver(gridInfo_v.Xcen,gridInfo_v.Ycen,vec_x,vec_y,vector_scale,'parent',han.sfig(kr,kc),'color',vector_color)
end

fcn_add_features(in_p,han.sfig(kr,kc),lims.x(kr,kc,:),lims.y(kr,kc,:))

if plot_contour
    %the patch plot is at z=0. We plot the tricontour on top of it. The minimum
    %value must be above 0.
    bline=abs(min(val));
    han.p(kr,kc,:)=tricontour(gridInfo.tri,gridInfo.Xcen,gridInfo.Ycen,val+bline,[contour_lines+bline],'k');
end %plot contour

% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1,'linestyle',prop.ls1,'marker',prop.m1);
% han.sfig(kr,kc).ColorOrderIndex=1; %reset color index
% han.p(kr,kc,1)=plot(x,y,'parent',han.sfig(kr,kc),'color',prop.color(1,:),'linewidth',prop.lw1);
% han.p(kr,kc,1).Color(4)=0.2; %transparency of plot
% han.p(kr,kc,1)=scatter(data_2f(data_2f(:,3)==0,1),data_2f(data_2f(:,3)==0,2),prop.ms1,prop.mt1,'filled','parent',han.sfig(kr,kc),'markerfacecolor',prop.mf1);
% surf(x,y,z,c,'parent',han.sfig(kr,kc),'edgecolor','none')
% patch([data_m.Xcen;nan],[data_m.Ycen;nan],[data_m.Scen;nan]*unit_s,[data_m.Scen;nan]*unit_s,'EdgeColor','interp','FaceColor','none','parent',han.sfig(kr,kc)) %line with color

%% measurements

fcn_add_measurements(in_p,han,lims)

%% PROPERTIES

kr=1; 
for kc=1:npc

hold(han.sfig(kr,kc),'on')
grid(han.sfig(kr,kc),'on')

han.sfig(kr,kc).Box='on';
han.sfig(kr,kc).XLim=lims.x(kr,kc,:);
han.sfig(kr,kc).YLim=lims.y(kr,kc,:);
if do_3D
    han.sfig(kr,kc).ZLim=lims.z(kr,kc,:);
end
if do_axis_equal
    %     axis(han.sfig(kr,kc),'equal')
    if kc==1
        han.dar=get(han.sfig(kr,kc),'DataAspectRatio');
        if han.dar(3)==1
            dar=[1 1 1/max(han.dar(1:2))];
        else
            dar=[1 1 han.dar(3)];
        end
        set(han.sfig(kr,kc),'DataAspectRatio',dar)
    else
        set(han.sfig(kr,kc),'DataAspectRatio',dar)
    end
end
han.sfig(kr,kc).XLabel.String=xlabels{kr,kc};
han.sfig(kr,kc).XLabel.FontSize=prop.fs;
if kc==1
    han.sfig(kr,kc).YLabel.String=ylabels{kr,kc};
else
    han.sfig(kr,kc).YLabel.String='';
end
han.sfig(kr,kc).YLabel.FontSize=prop.fs;
han.sfig(kr,kc).YDir='normal';
% if kc==2 && ~isfield(measurements_images,'pol') %there are measurements and are tif
    % han.sfig(kr,kc).YDir='reverse';
% end
if do_3D
    han.sfig(kr,kc).ZLabel.String=cbar(kr,kc).label;
end
% han.sfig(kr,kc).XTickLabel='';
if kc~=1
    han.sfig(kr,kc).YTickLabel='';
end
% han.sfig(kr,kc).XTick=[];  
% han.sfig(kr,kc).YTick=[];  
% han.sfig(kr,kc).XScale='log';
% han.sfig(kr,kc).YScale='log';
if do_title
    if kc==1
        han.sfig(kr,kc).Title.String=string(tim,'dd-MM-yyyy HH:mm');
    else
        han.sfig(kr,kc).Title.String=string(tim_mea,'dd-MM-yyyy HH:mm');
    end
end
% han.sfig(kr,kc).XColor='r';
% han.sfig(kr,kc).YColor='k';

%duration ticks
% xtickformat(han.sfig(kr,kc),'hh:mm')
% han.sfig(kr,kc).XLim=lims_d.x(kr,kc,:);
% han.sfig(kr,kc).XTick=hours([4,6]);

%colormap
if do_3D
    view(han.sfig(kr,kc),views);
end
colormap(han.sfig(kr,kc),cmap);
clim(han.sfig(kr,kc),lims.c(kr,kc,1:2));

end %kc


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

if do_cbar
kr=1; kc=1;
pos.sfig=han.sfig(kr,kc).Position;
han.cbar=colorbar(han.sfig(kr,kc),'location',cbar(kr,kc).location);
pos.cbar=han.cbar.Position;
if do_measurements
han.cbar.Position=pos.cbar+cbar(kr,kc).displacement;
han.sfig(kr,kc).Position=pos.sfig;
end
han.cbar.Label.String=cbar(kr,kc).label;
han.cbar.Label.FontSize=prop.fs;
% 	%set the marks of the colorbar according to your vector, the number of lines and colors of the colormap is np1 (e.g. 20). The colorbar limit is [1,np1].
% aux2=fliplr(d1_r./La_v); %we have plotted the colors in the other direction, so here we can flip it
% v2p=[1,5,11,15,np1];
% han.cbar.Ticks=v2p;
% aux3=aux2(v2p);
% aux_str=cell(1,numel(v2p));
% for ka=1:numel(v2p)
%     aux_str{ka}=sprintf('%5.3f',aux3(ka));
% end
% han.cbar.TickLabels=aux_str;
end

%% GENERAL
% set(findall(han.fig,'-property','FontSize'),'FontSize',prop.fs)
% set(findall(han.fig,'-property','FontName'),'FontName',prop.fn) %!!! attention, there is a bug in Matlab and this is not enforced. It is necessary to change it in the '.eps' to 'ArialMT' (check in a .pdf)
% han.fig.Renderer='painters';

%% ADHOC functions

apply_adhoc_functions(in_p);

%% PRINT

fig_print_close(in_p,han.fig,in_p.fig_print,fname)

end %function

%%
%% FUNCTIONS
%%

function fcn_add_fxw(in_p,han_sfig_kr_kc,lims_x,lims_y)

%% PARSE

in_p.plot_fxw=0;
if isfield(in_p,'fxw') && isstruct(in_p.fxw)
    in_p.plot_fxw=1;
end

in_p=isfield_default(in_p,'color_fxw','m');

v2struct(in_p)

%% CALC

if plot_fxw
    bol_in=fxw.xy(:,1)>lims_x(1) & fxw.xy(:,1)<lims_x(2) & fxw.xy(:,2)>lims_y(1) & fxw.xy(:,2)<lims_y(2);
    fxw.xy(~bol_in,:)=NaN;
    plot(fxw.xy(:,1),fxw.xy(:,2),'parent',han_sfig_kr_kc,'color',color_fxw);
end

end %function

%%

function fcn_add_rkm(in_p,han_sfig_kr_kc,lims_x,lims_y)

%% PARSE

in_p.plot_rkm=0;
if isfield(in_p,'rkm')==1 && ~isempty(in_p.rkm)
    in_p.plot_rkm=1;
end

in_p=isfield_default(in_p,'rkm_disp_color','c');
in_p=isfield_default(in_p,'rkm_disp_size',10);

v2struct(in_p)

%% CALC

if plot_rkm
    nrkm=numel(rkm{1,1});
    for krkm=1:nrkm
        bol_in=rkm{1,1}(krkm)>lims_x(1) && rkm{1,1}(krkm)<lims_x(2) && rkm{1,2}(krkm)>lims_y(1) && rkm{1,2}(krkm)<lims_y(2);
        if ~bol_in; continue; end
        scatter(rkm{1,1}(krkm),rkm{1,2}(krkm),10,rkm_disp_color,'parent',han_sfig_kr_kc)
        text(rkm{1,1}(krkm),rkm{1,2}(krkm),rkm{1,3}{krkm},'color',rkm_disp_color,'parent',han_sfig_kr_kc,'FontSize',rkm_disp_size)
    end
end

end %function

%%

function fcn_add_measurements_data(in_p,han_sfig_kr_kc)
    
%% PARSE

in_p=isfield_default(in_p,'measurements_edgecolor','k');

v2struct(in_p)

%% CALC

ni=numel(measurements_images);
for ki=1:ni
    measurements_images_loc=measurements_images{ki};
    if isfield(measurements_images_loc,'pol') %shp
        npolygons_plot=numel(measurements_images_loc.pol);
        for kp=1:npolygons_plot
            fill(measurements_images_loc.pol{kp}(:,1),measurements_images_loc.pol{kp}(:,2),measurements_images_loc.z(kp),'parent',han_sfig_kr_kc,'EdgeColor',measurements_edgecolor);
        end
    else %tif
        han.tmp(ki)=imagesc(measurements_images_loc.x, measurements_images_loc.y, measurements_images_loc.z,'parent',han_sfig_kr_kc);  % x and y are vectors
        han.tmp(ki).AlphaData=measurements_images_loc.mask;
    end %image type
end %ki

end %function

%% 

function fcn_add_measurements(in_p,han,lims)

%% PARSE

%parsed globally because it is used for the figure size

v2struct(in_p)

%% CALC

if do_measurements
    kr=1; kc=2;
    han_sfig_kr_kc=han.sfig(kr,kc);
    lims_x=lims.x(kr,kc,:);
    lims_y=lims.y(kr,kc,:);
    
    fcn_add_measurements_data(in_p,han_sfig_kr_kc);
    fcn_add_features(in_p,han_sfig_kr_kc,lims_x,lims_y);
end %do_measurements

end %function

%%

function fcn_add_ldb(in_p,han_sfig_kr_kc,lims_x,lims_y)

%% PARSE

in_p=isfield_default(in_p,'color_ldb','k');
in_p=isfield_default(in_p,'thk_ldb',0.5);

if isfield(in_p,'ldb')
    in_p=isfield_default(in_p,'plot_ldb',1);
else
    in_p=isfield_default(in_p,'plot_ldb',0);
end

v2struct(in_p)

%% CALC

if plot_ldb
    nldb=numel(ldb);
    for kldb=1:nldb
        bol_in=ldb(kldb).cord(:,1)>lims_x(1) & ldb(kldb).cord(:,1)<lims_x(2) & ldb(kldb).cord(:,2)>lims_y(1) & ldb(kldb).cord(:,2)<lims_y(2);
        ldb(kldb).cord(~bol_in,:)=NaN;
        plot(ldb(kldb).cord(:,1),ldb(kldb).cord(:,2),'parent',han_sfig_kr_kc,'color',color_ldb,'linewidth',thk_ldb,'linestyle','-','marker','none')
    end
end

end %function

%% 

function fcn_add_features(in_p,han_sfig_kr_kc,lims_x,lims_y)

fcn_add_rkm(in_p,han_sfig_kr_kc,lims_x,lims_y)
fcn_add_fxw(in_p,han_sfig_kr_kc,lims_x,lims_y)
fcn_add_ldb(in_p,han_sfig_kr_kc,lims_x,lims_y)

end %function