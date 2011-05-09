function h=my_isosurf(x,y,z,isodata,isovalue,coldata,varargin),
% MY_ISOSURF draws isosurfaces, isocaps and colours them
% Usage:
%      H=MY_ISOSURF(X,Y,Z,ISODATA,ISOVALUES,COLDATA);
%      draws isosurfaces based on the ISODATA for the given
%      ISOVALUES. The ISODATA is specified in the X,Y,Z points
%      wich form a structured 3D mesh (not necessarily monotonic
%      and plaid). The isosurface is coloured based on the COLDATA
%      that is also given in the X,Y,Z points. All interpolation
%      routines use linear interpolation.
%
%      H=MY_ISOSURF(X,Y,Z,ISODATA,ISOVALUES,COLDATA,ENCLOSE);
%      also displays the end cap geometry if the end caps enclose
%      data values above or below ISOVALUES. ENCLOSE can be 'above'
%      or 'below'. 
%    
%      MY_ISOSURF(..., WHICHPLANE) draws only the end caps on the
%      specified plane. WHICHPLANE is one of 'all' (default), 'xmin',
%      'xmax', 'ymin', 'ymax', 'zmin', or 'zmax'.
%    
% Example:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      th = 30*pi/180;
%      X = x*cos(th) - y*sin(th);
%      Y = x*sin(th) + y*cos(th);
%      x = X;
%      y = Y;
%      data=sqrt(x.^2 + y.^2 + z.^2);
%      cdata = smooth3(rand(size(data)), 'box', 7);
%      my_isosurf(x,y,z,data,[20 25],cdata);
%      my_isosurf(x,y,z,z,5,cdata,'below');
%      my_isosurf(x,y,z,x,10,cdata);
%      set(gca,'dataaspectratio',[1 1 1]);
%      material metal
%      camlight
%      view(95,30);
%      cameramenu

if nargin>6, % draw also isocaps
  h=zeros(1,2*length(isovalue(:)));
else,
  h=zeros(1,length(isovalue(:)));
end;
if iscell(x),
  h=cell(size(x));
  for block=1:length(x(:)),
    h{block}=my_isosurf(x{block},y{block},z{block},isodata{block},isovalue,coldata{block},varargin{:});
  end;
else,
  for i=1:length(isovalue(:));
    fv=isosurface(isodata,isovalue(i));
    if ~isempty(fv.vertices),
      vcoord=zeros(size(fv.vertices));
      vcoord(:,1)=interp3(x,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      vcoord(:,2)=interp3(y,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      vcoord(:,3)=interp3(z,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      fv.facevertexcdata=isocolors(coldata,fv.vertices);
  %    isonormals should not be evaluated in i,j,k space!
  %    or they should be corrected ...
  %    fv.vertexnormals=isonormals(isodata,fv.vertices);
      fv.vertices=vcoord;
    end;
    h(i)=patch(fv);
    if nargin>6, % draw also isocaps
      fv=isocaps(isodata,isovalue(i),varargin{:});
      vcoord=zeros(size(fv.vertices));
      vcoord(:,1)=interp3(x,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      vcoord(:,2)=interp3(y,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      vcoord(:,3)=interp3(z,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
      fv.facevertexcdata=isocolors(coldata,fv.vertices);
  %    isonormals should not be evaluated in i,j,k space!
  %    or they should be corrected ...
  %    fv.vertexnormals=isonormals(isodata,fv.vertices);
      fv.vertices=vcoord;
      h(i+length(isovalue(:)))=patch(fv);
    end;
  end;
  set(h,'edgecolor','none','facecolor','interp');
end;