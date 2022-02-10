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

function D3D_plot_1D(flg,br_name,z,SZ,zlab,refdate,time_r,desc_sim_v,time_data,which_v_v)

[ns,nb,nt,nv]=size(SZ);

%% 

if flg.print
    fig_vis=0;
else
    fig_vis=1;
end

%%
%% time_data=0
%%

if time_data==0
    
%% 1 simulation, 1 branch, 1 variable, all times (time_data=0)

if flg.fig_xvallt
    
kt=1;
for kb=1:nb
    for kv=1:nv
        for ks=1:ns
            nt=size(z{ks,kb,kt,kv},2);
            cmap=brewermap(nt,'RdYlGn');
            refdate_str=num2str(refdate{ks,1});
%             time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb});
            figure('Visible',fig_vis)
            hold on
            for kt0=1:nt
                plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv}(:,kt0),'color',cmap(kt0,:))
            end

            han.cbar=colorbar;
            han.cbar.Label.String='time';
            clim([min(time_r{ks,kb}),max(time_r{ks,kb})]);
            aux_tick=linspace(min(time_r{ks,kb}),max(time_r{ks,kb}),10);
            han.cbar.YTick=aux_tick;
            han.cbar.YTickLabel=datestr(datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(aux_tick),'dd/mm/yyyy');
            colormap(cmap);

            title(sprintf('%s; %s',br_name{kb,1},desc_sim_v{ks}))
            
            if flg.err
                str_var=sprintf('difference in %s',zlab{kv});
                str_fig='err';
            else
                str_var=zlab{kv};
                str_fig='';
            end
            ylabel(str_var)
            if flg.rkm
                xlabel('river km [km]')
            else
                xlabel('streamwise coordinate [m]')
            end

            if flg.print
                print(gcf,sprintf('xvallt_%s_ks_%s_kb_%s_kt_%02d_kv_%02d.png',str_fig,desc_sim_v{ks},br_name{kb,1},kt,which_v_v(kv)),'-dpng','-r300')
                close(gcf)
            end
        end
    end
end

end

%% x-t

if flg.fig_xt
    
kt=1;
kv=1;
kv_m=1;

z_p=cell(ns,nb);
z_p_mea=cell(1,nb);

for kv=1:nv
    for kb=1:nb
        for ks=1:ns

            refdate_str=num2str(refdate{ks,1});
            time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb});
    %         time_d=time_r{ks,kb};
            [s_m,t_m]=meshgrid(SZ{ks,kb},time_d);

    %         SZ_p{ks,kb}=s_m;
    %         time_p{ks,kb}=t_m;

            z_p{ks,kb}=z{ks,kb,kt,kv};
            if flg.err
                cmap=brewermap(100,'RdYlGn');
                str_var=sprintf('difference in %s',zlab{kv});
                str_fig='err';
            else
%                 cmap=brewermap(100,'Reds');
                cmap=turbo(100);
                str_var=zlab{kv};
                str_fig='';
            end

    %         z_p{ks,kb}=z{ks,kb,kt,kv}-repmat(z{ks,kb,kt,kv}(:,1),1,size(z{ks,kb,kt,kv},2)); %with respect to initial 
    %         str_var=sprintf('change in %s',zlab{kv});

    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}-z{ks,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv_m}-z{ks,kb,1,kv_m}; %initial condition of simulations is measured

            figure('Visible',fig_vis)
            hold on

            surf(s_m,t_m,z_p{ks,kb}','edgecolor','none')

            title(sprintf('%s; %s',br_name{kb,1},desc_sim_v{ks}))
            if flg.rkm
                xlabel('river km [km]')
            else
                xlabel('streamwise coordinate [m]')
            end
            ylabel('time')

            han.cbar=colorbar;
            han.cbar.Label.String=str_var;
            colormap(cmap);
            if flg.err
                clim(absolute_limits(z_p{ks,kb}))
            end
            if flg.print
                print(gcf,sprintf('xt_%s_ks_%s_kb_%s_kt_%02d_kv_%02d.png',str_fig,desc_sim_v{ks},br_name{kb,1},kt,which_v_v(kv)),'-dpng','-r300')
                close(gcf)
            end
        end
    end
end

end

%% x-t with respect to initial

if flg.fig_xtchange && ~flg.err
kt=1;
kv=1;
kv_m=1;

z_p=cell(ns,nb);
z_p_mea=cell(1,nb);

cmap=brewermap(100,'Reds');

for kv=1:nv
    for kb=1:nb
        for ks=1:ns

            refdate_str=num2str(refdate{ks,1});
            time_d=datetime(str2double(refdate_str(1:4)),str2double(refdate_str(5:6)),str2double(refdate_str(7:8)))+seconds(time_r{ks,kb});

            [s_m,t_m]=meshgrid(SZ{ks,kb},time_d);


            z_p{ks,kb}=z{ks,kb,kt,kv}-repmat(z{ks,kb,kt,kv}(:,1),1,size(z{ks,kb,kt,kv},2)); %with respect to initial 
            str_var=sprintf('change in %s',zlab{kv});

    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv}-z{ks,kb,1,kv}; %initial condition of simulations is measured
    %         z_p_mea{1,kb}=z_mea{1,kb,1,kv_m}-z{ks,kb,1,kv_m}; %initial condition of simulations is measured

            figure('Visible',fig_vis)
            hold on

            surf(s_m,t_m,z_p{ks,kb}','edgecolor','none')

            title(sprintf('%s; %s',br_name{kb,1},desc_sim_v{ks}))
            if flg.rkm
                xlabel('river km [km]')
            else
                xlabel('streamwise coordinate [m]')
            end
            ylabel('time')

            han.cbar=colorbar;
            han.cbar.Label.String=str_var;
            colormap(cmap);
            
            if flg.print
                print(gcf,sprintf('xtchange_ks_%s_kb_%s_kt_%02d_kv_%02d.png',desc_sim_v{ks},br_name{kb,1},kt,which_v_v(kv)),'-dpng','-r300')
                close(gcf)
            end
        end
    end
end

end

%%
%% time_data=1
%%

else
  
%% 1 simulation, all branches branch, 1 variable, 1 time

error('do')

ks=1;
kv=1;
kt=1;

% nt=size(z{ks,kb,kt,kv},2);
nt=size(z,3);
% cmap=brewermap(nt,'RdYlGn');
cmap=brewermap(nt,'set1');
for kb=1:nb
figure 
hold on
for kt=1:nt
    plot(SZ{ks,kb,kt,kv},z{ks,kb,kt,kv},'color',cmap(kt,:))
end
% han.cbar=colorbar;
% han.cbar.Label.String='time [s]';
% clim([min(time_r{ks,kb,kt,kv}),max(time_r{ks,kb,kt,kv})]);
% colormap(cmap);
title(br_name{kb,1})
ylabel(zlab{kv})
            if flg.rkm
                xlabel('river km [km]')
            else
                xlabel('streamwise coordinate [m]')
            end
end

end %time_data