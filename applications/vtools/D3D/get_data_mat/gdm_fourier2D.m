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

function [L,int]=gdm_fourier2D(gridInfo,data)
        
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
z_m2=[flipud(z_m),flipud(z_m);z_m,z_m];

f_z2=fft2(z_m2);
f_z_sh2=fftshift(f_z2);
f_zr_sh2=abs(f_z_sh2);
f_x_sh2=(-2*nx/2:1:2*nx/2-1)/dx/(2*nx);
f_y_sh2=(-2*ny/2:1:2*ny/2-1)'/dy/(2*ny);
f_x_sh_m2=repmat(f_x_sh2,2*ny,1);
f_y_sh_m2=repmat(f_y_sh2,1,2*nx);

%%

f_zr_sh2_v=reshape(f_zr_sh2,[],1);
f_x_sh_m2_v=reshape(f_x_sh_m2,[],1);
bol_0=f_x_sh_m2_v==0;
f_zr_sh2_v(bol_0)=NaN;
[int,idx_max]=max(f_zr_sh2_v);
L=1/abs(f_x_sh_m2_v(idx_max));

%%
% figure
% scatter3(reshape(f_x_sh_m2,[],1),reshape(f_y_sh_m2,[],1),reshape(f_zr_sh2,[],1),'filled')

end %function