%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19428 $
%$Date: 2024-02-10 10:41:10 +0100 (Sat, 10 Feb 2024) $
%$Author: chavarri $
%$Id: D3D_velocity.m 19428 2024-02-10 09:41:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/eqtran/matlab/fcn/D3D_velocity.m $
%
%Computation done in `fm_erosed`.

function [uuu,vvv,umod,zumod,utot,ulocal,vlocal,ustarc]=D3D_velocity(i2d3d,ucxq_mor,ucyq_mor,zcc,hs_mor,ee,vonkar,z0rou,chezy,sag,bl,eps)

switch i2d3d
    case 3
        ucxq_tmp=ucxq_mor;
        ucyq_tmp=ucyq_mor;
%       uuu(kk)   = ucxq_tmp(kmxvel)                  %! discharge based cell centre velocities
        uuu=ucxq_tmp;
%       vvv(kk)   = ucyq_tmp(kmxvel)
        vvv=ucyq_tmp;
%       umod(kk)  = sqrt(uuu(kk)*uuu(kk) + vvv(kk)*vvv(kk))
        umod=sqrt(uuu*uuu+vvv*vvv);
%       zumod(kk) = zcc-bl(kk)
        zumod=zcc-bl;
    case 2
%       uuu(kk)   = ucxq_mor(kk)
        uuu=ucxq_mor;
%       vvv(kk)   = ucyq_mor(kk)
        vvv=ucyq_mor;
%       umod(kk)  = sqrt(uuu(kk)*uuu(kk) + vvv(kk)*vvv(kk))
        umod=sqrt(uuu*uuu+vvv*vvv);
%       zumod(kk) = hs_mor(kk)/ee
        zumod=hs_mor/ee;
end
		 
% ustarc = umod(nm)*vonkar/log(1.0_fp + zumod(nm)/max(z0rou,1d-5))
ustarc=umod*vonkar/log(1+zumod/max(z0rou,1d-5));

% sag=sqrt(ag); %we already pass the square root

% utot  = ustarc * chezy / sag
utot=ustarc*chezy/sag;

%only for DLL
% ulocal= utot * uuu(nm) / (umod(nm)+eps)
ulocal=utot*uuu/(umod+eps);
% vlocal= utot * vvv(nm) / (umod(nm)+eps)
vlocal=utot*vvv/(umod+eps);

end %function