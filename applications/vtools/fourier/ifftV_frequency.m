%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18312 $
%$Date: 2022-08-19 08:16:54 +0200 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: fourier_eigenvalues.m 18312 2022-08-19 06:16:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/fourier/fourier_eigenvalues.m $
%
%Compute ifft for given frequencies.

function [noise_rec_2d,noise_rec]=ifftV_frequency(fx2,fy2,x,y,P2)

[x_in,y_in]=meshgrid(x,y);
nx=numel(x);
ny=numel(y);
nmx=numel(fx2); %same as nx if double-sided spectrum
nmy=numel(fy2); %same as ny if double-sided spectrum

noise_rec_m=NaN(1,nx,ny,1,nmx,nmy); %[eigenvalue, x, y, time, mode x, mode y]
for kmx=1:nmx
    for kmy=1:nmy
        kx_fou=2*pi*fx2(kmx);
        ky_fou=2*pi*fy2(kmy);
        cx_fou=P2(kmy,kmx);
        noise_loc=cx_fou*exp(1i*kx_fou*x_in).*exp(1i*ky_fou*y_in);
        noise_rec_m(1,:,:,1,kmx,kmy)=noise_loc';
    end
    fprintf('%4.2f %% \n',kmx/nmx*100);
end
noise_rec=sum(noise_rec_m,[5,6]);
noise_rec_2d=real(squeeze(noise_rec)');

end %function