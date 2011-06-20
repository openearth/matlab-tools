function h=my_vecsurf(x,y,z,isodata,isovalue,R,vecx,vecy,vecz),
% MY_VECSURF draws vectors on an isosurface
% Usage:
%      H=MY_VECSURF(X,Y,Z,ISODATA,ISOVALUES,R,U,V,W);
%      draws in R vertices of the isosurface specified by
%      (X,Y,Z,ISODATA==ISOVALUE) a vector in the direction
%      given by the local values of (U,V,W).
%    
% Example:
%      [x y z] = meshgrid(1:20, 1:20, 1:20);
%      data=sqrt(x.^2 + y.^2 + z.^2);
%      my_isosurf(x,y,z,data,20,x);
%      hold on
%      my_vecsurf(x,y,z,data,20,30,x,y,z);
%      set(gca,'dataaspectratio',[1 1 1]);
%      view(95,30);
%      cameramenu
%
% See also: ISOSURFACE, REDUCEPATCH, QUIVER3

% (c) Copyright 2000 H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

h=zeros(2,length(isovalue(:)));
for i=1:length(isovalue(:));
  fv=isosurface(isodata,isovalue(i));
  fv=reducepatch(fv,R);
  xvec=interp3(vecx,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  yvec=interp3(vecy,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  zvec=interp3(vecz,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  vcoord(:,1)=interp3(x,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  vcoord(:,2)=interp3(y,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  vcoord(:,3)=interp3(z,fv.vertices(:,1),fv.vertices(:,2),fv.vertices(:,3),'*linear');
  h(:,i)=quiver3(vcoord(:,1),vcoord(:,2),vcoord(:,3),xvec,yvec,zvec,3);
end;
