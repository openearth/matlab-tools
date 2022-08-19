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