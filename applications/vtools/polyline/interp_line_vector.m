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
%Find a series of points `y` based on their coordinate `x` by 
%interpolating on a polyline defined by `xv_all` and `yv_all`. 

function [y,idx_1,idx_2]=interp_line_vector(xv_all,yv_all,x,x_thres,varargin)

np=numel(x);
y=NaN(np,1);
idx_1=NaN(np,1);
idx_2=NaN(np,1);
for kp=1:np
    [y(kp),idx_1(kp),idx_2(kp)]=interp_line_closest(xv_all,yv_all,x(kp),x_thres,varargin{:});
end %kp

end %function