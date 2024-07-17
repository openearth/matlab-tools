%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18545 $
%$Date: 2022-11-15 13:06:55 +0100 (di, 15 nov 2022) $
%$Author: chavarri $
%$Id: D3D_plot_raw.m 18545 2022-11-15 12:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot_raw.m $
%

function D3D_plot_patch(his_sal,his_zint,stations,ks,dir_figs)

[nt,ns,nl]=size(his_sal.val);

    val_stat=his_sal.val(:,ks,:);
    zint_stat=his_zint.val(:,ks,:);
%     zcen_stat=his_zcen.val(:,ks,:);
%     wl_val_stat=his_wl.val(:,ks,:);
    
    % check interfaces

%     time_mat_zcen=repmat(his_sal.times,1,size(his_sal.val,3));
%     time_mat_zint=repmat(his_sal.times,1,size(his_sal.val,3)+1);
%     figure 
%     hold on
%     plot(his_wl.times,wl_val_stat,'-k','linewidth',2)
%     scatter(time_mat_zcen(:),zcen_stat(:),10,val_stat(:),'filled')
%     scatter(time_mat_zint(:),zint_stat(:),10,'*k')
    
    % salinity patch
    
    time_cor=cen2cor(his_sal.times);
    z_int_mat=reshape(zint_stat,nt,nl+1)';
    sal_mat=reshape(val_stat,nt,nl)';

    in.XCOR=time_cor;
    in.sub=z_int_mat;
    in.cvar=sal_mat;
    [faces,vertices,col]=rework4patch(in);
    
%     switch flg.sal_u
%         case 1
            col_p=col; %psu
            str_sal='salinity [psu]';
%         case 2
%             col_p=sal2cl(1,col);
%             str_sal='chlorinity [mg/l]';
%     end
    
    figure
    patch('faces',faces,'vertices',vertices,'FaceVertexCData',col,'edgecolor','k','FaceColor','flat');
%     patch('faces',faces,'vertices',vertices,'FaceVertexCData',col_p,'edgecolor','none','FaceColor','flat');
    han.cbar=colorbar;
    han.cbar.Label.String=str_sal;
    title(strrep(stations{ks},'_','\_'))
    fname_fig=sprintf('%s_sal.png',stations{ks});
    ylabel('elevation [m]')
    path_fig=fullfile(dir_figs,fname_fig);
    datetick('x') 

    print(gcf,path_fig,'-dpng','-r300')  
end %function