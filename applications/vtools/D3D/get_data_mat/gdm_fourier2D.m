%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18613 $
%$Date: 2022-12-09 18:24:34 +0100 (Fri, 09 Dec 2022) $
%$Author: chavarri $
%$Id: create_mat_map_2DH_01.m 18613 2022-12-09 17:24:34Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_2DH_01.m $
%
%

function [L,int,a,l]=gdm_fourier2D(gridInfo,data)
        
out_read.XZ=gridInfo.Xcen(1:end-1,:)';
out_read.YZ=gridInfo.Ycen(1:end-1,:)';
out_read.z=data(1:end-1,:)';
%         out_read.time_r=seconds(tim.time_mor_dtime-tim.time_mor_dtime(1));

x_m=out_read.XZ(2:end-1,:);
y_m=out_read.YZ(2:end-1,:);
z_m=out_read.z(2:end-1,:);

nx=size(x_m,2);
ny=size(x_m,1);

%better to take it from input
dx=x_m(1,2)-x_m(1,1);
dy=y_m(2,1)-y_m(1,1);

%shift
% x_m2=repmat([-fliplr(x_m),x_m],2,1);
% y_m2=repmat([-flipud(y_m);y_m],1,2);
% z_m2=[flipud(z_m),flipud(z_m);z_m,z_m];
z_m2=[fliplr(flipud(z_m)),flipud(z_m);fliplr(z_m),z_m];

f_z2=fft2(z_m2);
f_z_sh2=fftshift(f_z2);
% f_zr_sh2=abs(f_z_sh2);

%considering that the domain is extended!
Nx=2*nx;
Ny=2*ny;
% f_zr_sh2=abs(f_z_sh2).^2;
f_zr_sh2=abs(f_z_sh2).^2/Nx/Ny;
% f_zr_sh2=abs(f_z_sh2).^2/Nx/Ny*dx*dy;

f_x_sh2=(-2*nx/2:1:2*nx/2-1)/dx/(2*nx);
f_y_sh2=(-2*ny/2:1:2*ny/2-1)'/dy/(2*ny);
f_x_sh_m2=repmat(f_x_sh2,2*ny,1);
f_y_sh_m2=repmat(f_y_sh2,1,2*nx);

%%

f_zr_sh2_v=reshape(f_zr_sh2,[],1);
f_x_sh_m2_v=reshape(f_x_sh_m2,[],1);
f_y_sh_m2_v=reshape(f_y_sh_m2,[],1);
bol_0=f_x_sh_m2_v==0;
f_zr_sh2_v(bol_0)=NaN;
[int,idx_max]=max(f_zr_sh2_v);
L=1/abs(f_x_sh_m2_v(idx_max));
% Ly=1/abs(f_y_sh_m2_v(idx_max));

%%

[a,l]=zero_crossing_properties(x_m(1,:),z_m(1,:));

%%

% [ny,nx]=size(z_m2);
% x=(0:nx-1)*dx;        
% y=(0:ny-1)*dy;  
% noise=z_m2;
% [fx,fy,P2]=fftV(x,y,noise);
% 
% % P2_r=real(P2);
% P2_r=abs(P2);
% bol_0x=fx==0;
% bol_0y=fy==0;
% P2(:,bol_0x)=NaN;
% P2(bol_0y,:)=NaN;
% [int,idx_max]=max(P2_r(:));
% P2_v=reshape(P2,[],1);

%%

% %%
% figure
% hold on
% plot(x,z)
% plot(x,zm.*ones(size(z)))
% scatter(x(idx_u),zm.*ones(size(idx_u)))
% %%
% figure
% % scatter3(reshape(f_x_sh_m2,[],1),reshape(f_y_sh_m2,[],1),f_zr_sh2_v,10,f_zr_sh2_v,'filled')
% scatter3(reshape(f_x_sh_m2,[],1),reshape(f_y_sh_m2,[],1),f_zr_sh2_v,10,P2_v,'filled')
% xlabel('x')
% ylabel('y')
% 
% %%
% 
% figure
% hold on
% surf(z_m2,'edgecolor','none')

end %function