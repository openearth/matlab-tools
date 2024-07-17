%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19697 $
%$Date: 2024-07-08 08:30:24 +0200 (Mon, 08 Jul 2024) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19697 2024-07-08 06:30:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Modify the bed level of a grid file in NC format by setting a constant value
%at the corners inside a polygon.

function modify_bed_level_net(path_nc_or,path_pol,newetab)

%% CALC

node_x=ncread(path_nc_or,'mesh2d_node_x'); %bed elevation at mesh corners
node_y=ncread(path_nc_or,'mesh2d_node_y'); %bed elevation at mesh corners
node_z=ncread(path_nc_or,'mesh2d_node_z'); %bed elevation at mesh corners

node_z_mod=node_z;
nf=numel(path_pol);

xlims=NaN(nf,2);
ylims=NaN(nf,2);
pol_all=cell(nf,1);
for kf=1:nf
    pol=D3D_io_input('read',path_pol{kf,1},'xy_only',1);
%     pol=landboundary('read',path_pol{kf,1});
    inp=inpolygon(node_x,node_y,pol(:,1),pol(:,2));
    node_z_mod(inp)=newetab{kf,1};
    xlims(kf,:)=[min(pol(:,1)),max(pol(:,1))];
    ylims(kf,:)=[min(pol(:,2)),max(pol(:,2))];
    pol_all{kf}=pol;
end

%% SAVE

[folder_or,name_or,ext_or]=fileparts(path_nc_or);
name_mod=strrep(name_or,'_net','_mod_net');
path_nc_mod=fullfile(folder_or,sprintf('%s%s',name_mod,ext_or));
copyfile(path_nc_or,path_nc_mod)
ncwrite(path_nc_mod,'mesh2d_node_z',node_z_mod);

%% PLOT

fdir=fileparts(path_nc_or);
tol=100;
tol_z=3;

for kf=1:nf

    in_p.node_x=node_x;
    in_p.node_y=node_y;
    in_p.node_z=node_z;
    in_p.node_z_mod=node_z_mod;
    in_p.name=fullfile(fdir,sprintf('grid_mod_%d',kf));
    in_p.ylims=ylims(kf,:)+[-tol,tol];
    in_p.xlims=xlims(kf,:)+[-tol,tol];
    in_p.clims=newetab{kf}+[-tol_z,tol_z];
    in_p.pol=pol_all;

    fig_grid_change(in_p)

end

% %
% in_p.node_x=node_x;
% in_p.node_y=node_y;
% in_p.node_z=node_z;
% in_p.node_z_mod=node_z_mod;
% in_p.name='grid_mod_2';
% in_p.ylims=431343+[-1500,+1500];
% in_p.xlims=80589+[-1000,+1000];
% in_p.clims=-6.5+[-2,+2];
% 
% fig_grid_change(in_p)

%%
% clim_i=[-19,-15];
% 
% figure
% ha(1)=subplot(1,2,1);
% scatter(node_x,node_y,10,node_z,'filled')
% % view([0,90])
% axis equal
% caxis(clim_i)
% title('original')
% 
% ha(2)=subplot(1,2,2);
% scatter(node_x,node_y,10,node_z_mod,'filled')
% % view([0,90])
% axis equal
% caxis(clim_i)
% title('modified')
% 
% han.cbar=colorbar;
% han.cbar.Label.String='bed elevation [m]';
% linkaxes(ha,'xy')
% xlim([6.98,7.18]*1e4)
% ylim([4.40,4.43]*1e5)


end %function