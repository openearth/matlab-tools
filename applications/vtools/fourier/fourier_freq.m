%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: fourier2.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/fourier2.m $
%

function [dx,fx2,fx1,dy,fy2,fy1]=fourier_freq(x,y)

x_diff=diff(x);
dx=x_diff(1);
if any(x_diff-dx)
    error('dx must be constant.')
end
y_diff=diff(y);
dy=y_diff(1);
if any(y_diff-dy)
    error('dy must be constant.')
end

fsx=1/dx; %sampling frequency
fsy=1/dy; %sampling frequency

nx=numel(x);
ny=numel(y);

fx1=fsx*(0:(nx/2))/nx; 
fy1=fsy*(0:(ny/2))/ny; 

fx2=(-nx/2:nx/2-1)*(fsx/nx);
fy2=(-ny/2:ny/2-1)*(fsy/ny);

end %function