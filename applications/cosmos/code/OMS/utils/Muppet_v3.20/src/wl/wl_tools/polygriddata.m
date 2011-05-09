function Zgrid=polygriddata(Xsamp,Ysamp,Zsamp,Xgrid,Ygrid,Xpoly,Ypoly)
% POLYGRIDDATA Apply griddata to points inside a specified polygon
%   ZGrid = polygriddata(XSample,YSample,ZSample, XGrid, YGrid, XPoly, YPoly)
%   uses XSample, YSample, ZSample as sample points of which the data is
%   interpolated onto the gridpoints specified by XGrid, YGrid inside the
%   polygon specified by XPoly, YPoly.

% find all points in or on the polygon
In=inpolygon(Xgrid,Ygrid,Xpoly,Ypoly)>0;

% create the output matrix
Zgrid=repmat(NaN,size(Xgrid));

% grid the data
Zgrid(In)=griddata(Xsamp,Ysamp,Zsamp,Xgrid(In),Ygrid(In));
