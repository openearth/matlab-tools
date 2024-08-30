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
%Compute spline per parts.
%
%ATTENTION! It fails at vertical points. The solution is to turn it and always orient it in increasing x. 
%
%INPUT:
%   - x   = x-coordinate to fit polyline
%   - y   = y-coordinate to fit polyline
%   - xq  = x-coordinate of query points
%   - int = interval to which xq pertains (it could be computed inside)
%

function yq=spline_parts(x,y,xq,int)

np=numel(x); %number of points
nq=numel(xq); %number of query points
nint=np-1; %number of intervals
yq=NaN(nq,1);

%we take groups of 4 points, 3 intervals.
for kint=2:nint-1 
    idx_get=kint-1:kint+2;
    xl=x(idx_get);
    yl=y(idx_get);
    %it must be in increasing x order
    if xl(end)<xl(1)
        xl=flipud(xl);
        yl=flipud(yl);
    end
    spl=spline(xl,yl);
    coefs=spl.coefs(2,:); %coefficients of the center interval (the second out of three)
    bol_p=int==kint;
    x_int=xq(bol_p); %local points we interpolate
    x_int_0=x_int-xl(2,1); %local points we interpolate with respect to the origin point of the interval. Point 2 because we deal with second interval. 
    yq(bol_p)=polyval(coefs,x_int_0);
end

end %function