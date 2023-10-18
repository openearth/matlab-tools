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

function create_trench(fpath_etab,fdir_pol_in,fpath_rkm,fdir_out,trench)

%read bed level
etab=D3D_io_input('read',fpath_etab);
etab_mod=etab;

%read summerbed
[x_pol_in,y_pol_in]=join_shp_xy(fdir_pol_in);

%axis coordinates of rkm
trench_xy_c_v=convert2rkm(fpath_rkm,trench.rkm,trench.branch);

%loop on trench
ntrench=numel(trench.length);
etab_trench=NaN(ntrench,1);

for ktrench=1:ntrench
    
    trench_L=trench.length(ktrench);
    trench_xy_c=trench_xy_c_v(ktrench,:);
    trench_h=trench.height(ktrench);
    trench_rkm=trench.rkm(ktrench);
    trench_br=trench.branch(ktrench);

    %axis coordinates downstream
    trench_xy_ds=convert2rkm(fpath_rkm,trench_rkm+trench_L/2/1000,trench_br);
    trench_xy_us=convert2rkm(fpath_rkm,trench_rkm-trench_L/2/1000,trench_br);

    %perpendicular lines
    xy_axis=[trench_xy_us;trench_xy_c;trench_xy_ds];
    [xyL,xyR]=perpendicular_polyline(xy_axis,2,150); %ds=150 to be outiside the main channel

    %intersection between perpendicular and summerbed polygon
    xy_fp=[xyL(1,:);xyL(end,:);xyR(end,:);xyR(1,:)];
    [min_dist,x_int,y_int,~,idx_c,~,~,~,~]=p_poly_dist(xy_fp(:,1),xy_fp(:,2),x_pol_in,y_pol_in); %the order of output seems wrong, but it is correct. 

    %mean bed level
    bol_in=inpolygon(etab(:,1),etab(:,2),x_int,y_int);

    %elevation to lower bed
    etab_trench(ktrench)=mean(etab(bol_in,3))-trench_h;

    %create trench
    etab_mod(bol_in,3)=etab_trench(ktrench);

    
% %% debug
% figure
% hold on
% plot(x_pol_in,y_pol_in,'-k')
% plot(x_int,y_int,'-r','linewidth',2)
% scatter(xy_axis(:,1),xy_axis(:,2))
% scatter(xyL(:,1),xyL(:,2))
% scatter(xyR(:,1),xyR(:,2))
% axis equal

%%

end %ktrench

%save bed level file
[~,fname,fext]=fileparts(fpath_etab);
fname_out=sprintf('%s_trench%s',fname,fext);
fpath_out=fullfile(fdir_out,fname_out);
D3D_io_input('write',fpath_out,etab_mod);

%% PLOT

for kdiff=1:2
    
fig=figure('visible',0);
hold on
plot(x_pol_in,y_pol_in,'-k','linewidth',1)
scatter(trench_xy_c_v(:,1),trench_xy_c_v(:,2),20,'red','x')
axis equal

cbar=colorbar;
[lab,~,~,str_diff]=labels4all('etab',1,'en');
switch kdiff
    case 1
        scatter(etab_mod(:,1),etab_mod(:,2),3,etab_mod(:,3),'filled')
        colormap(jet(100));
        cbar.Label.String=lab;
    case 2
        scatter(etab_mod(:,1),etab_mod(:,2),3,etab_mod(:,3)-etab(:,3),'filled')
        colormap(brewermap(100,'RdYlBu'));
        cbar.Label.String=str_diff;
end

for ktrench=1:ntrench
    text(trench_xy_c_v(ktrench,1),trench_xy_c_v(ktrench,2),sprintf('%6.2f',trench.rkm(ktrench)));
    switch kdiff
        case 1
            clim([etab_trench(ktrench)-3,etab_trench(ktrench)+3]);
        case 2
            clim([-3,+3]);
    end
    xlim([trench_xy_c_v(ktrench,1)-3000,trench_xy_c_v(ktrench,1)+3000]);
    ylim([trench_xy_c_v(ktrench,2)-3000,trench_xy_c_v(ktrench,2)+3000]);
    fpath_fig=fullfile(fdir_out,sprintf('trench_%02d_%02d.png',ktrench,kdiff));
    print(gcf,fpath_fig,'-dpng','-r300')
end

close(fig);

end

%% debug

% %%
% figure
% hold on
% scatter(etab_mod(:,1),etab_mod(:,2),10,etab(:,3)-etab_mod(:,3),'filled')
% plot(x_pol_in,y_pol_in,'-k')
% scatter(trench_xy_c_v(:,1),trench_xy_c_v(:,2),10,'red','x')
% axis equal
% colorbar
% colormap(brewermap(100,'RdYlBu'))
% clim([-2,2])
% 
% %% 
% figure
% hold on
% scatter3(etab_mod(:,1),etab_mod(:,2),etab(:,3),10,etab(:,3),'filled')
% plot(x_pol_in,y_pol_in,'-k')
% scatter(trench_xy_c_v(:,1),trench_xy_c_v(:,2),10,'red','x')
% axis equal
% colorbar
% % colormap(brewermap(100,'RdYlBu'))
% % clim([-2,2])