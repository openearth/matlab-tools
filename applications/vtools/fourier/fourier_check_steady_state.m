%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20047 $
%$Date: 2025-02-13 09:19:45 +0100 (Thu, 13 Feb 2025) $
%$Author: chavarri $
%$Id: fourier_evolution_frequency.m 20047 2025-02-13 08:19:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_evolution_frequency.m $
%
%Check steady state.
%
%Attention, in other functions `Q` is for all modes and `Q_rec` for the
%summed modes (reconstructed). Here `Q` is the summed modes (i.e., the
%solution).

function [LHS,RHS]=fourier_check_steady_state(Q,Dx,Dy,Ax,Ay,B,dx,dy,dim_ini)


[ne,nx,ny,nt]=size(Q); %[ne,nx,ny,nt]
% dQdx=diff(Q_rec,1,2)./dx; %[ne,nx-1,ny,nt]
dQdx=NaN(size(Q));
dQdx(:,2:end-1,:,:)=(Q(:,3:end,:,:)-Q(:,1:end-2,:,:))/(2*dx);
% d2Qdx2=diff(Q_rec,2,2)./dx^2; %[ne,nx-2,ny,nt]
d2Qdx2=NaN(size(Q));
d2Qdx2(:,2:end-1,:,:)=(dQdx(:,3:end,:,:)-dQdx(:,1:end-2,:,:))/(2*dx);
% dQdy=diff(Q_rec,1,3)./dy; %[ne,nx,ny-1,nt]
dQdy=NaN(size(Q));
dQdy(:,:,2:end-1,:)=(Q(:,:,3:end,:)-Q(:,:,1:end-2,:))/(2*dy);
% d2Qdy2=diff(Q_rec,2,3)./dy^2; %[ne,nx,ny-1,nt]
d2Qdy2=NaN(size(Q));
d2Qdy2(:,:,2:end-1,:)=(dQdy(:,:,3:end,:)-dQdy(:,:,1:end-2,:))/(2*dy);

%indices of steady state variables
dim_steady=1:1:ne;
dim_steady(dim_ini)=[];


Dxs=Dx(dim_steady,dim_steady);
Dys=Dy(dim_steady,dim_steady);
Axs=Ax(dim_steady,dim_steady);
Ays=Ay(dim_steady,dim_steady);
Bs=B(dim_steady,dim_steady);

DxF=Dx(dim_steady,dim_ini);
DyF=Dy(dim_steady,dim_ini);
AxF=Ax(dim_steady,dim_ini);
AyF=Ay(dim_steady,dim_ini);
BF=B(dim_steady,dim_ini);

LHS=NaN(ne-1,nx,ny,nt);
RHS=LHS;
for kt=1:nt
    for kx=1:nx
        for ky=1:ny
            %Dx*d^2Q/dx^2+Dy*d^2Q/dy^2+Ax*dQ/dx+Ay*dQ/dy+B*Q=F
            LHS(dim_steady,kx,ky,kt)=Dxs*d2Qdx2(dim_steady,kx,ky,kt)+Dys*d2Qdy2(dim_steady,kx,ky,kt)+Axs*dQdx(dim_steady,kx,ky,kt)+Ays*dQdy(dim_steady,kx,ky,kt)+Bs*Q(dim_steady,kx,ky,kt);
            RHS(dim_steady,kx,ky,kt)=DxF*d2Qdx2(dim_ini   ,kx,ky,kt)+DyF*d2Qdy2(dim_ini   ,kx,ky,kt)+AxF*dQdx(dim_ini   ,kx,ky,kt)+AyF*dQdy(dim_ini   ,kx,ky,kt)+BF*Q(dim_ini   ,kx,ky,kt);
        end
    end
end

end %function