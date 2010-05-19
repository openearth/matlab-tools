function [x,y,z]=ddb_getSRTM(xlim,ylim,res)

%handles=getHandles;
xlim(1)=max(-179.5,xlim(1));
xlim(2)=min(179.5,xlim(2));
ylim(1)=max(-89.5,ylim(1));
ylim(2)=min(89.5,ylim(2));

[x,y,z,url,ok]=ddb_read_srtm30plus(xlim,ylim,res,0);

% xavg=0.5*(xlim(1)+xlim(2));
% yavg=0.5*(ylim(1)+ylim(2));
% 
% xavg=7+floor(12*xavg/360);
% yavg=4+floor(6*yavg/180);
% 
% str=['d:\data\gebco\tmp\gebco_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
% %str=['d:\data\etopo2\etopo2_' num2str(xavg,'%0.3i') '_' num2str(yavg,'%0.3i') '.mat'];
% a=load(str);
% ithin=max(1,round(res/(3600*a.data.cellsize(1))));
% x=a.data.interpx(1:ithin:end,1:ithin:end);
% y=a.data.interpy(1:ithin:end,1:ithin:end);
% z=a.data.interpz(1:ithin:end,1:ithin:end);
% ok=1;
% clear a
 
% sz=size(x);
% xx=reshape(x,sz(1)*sz(2),1);
% yy=reshape(y,sz(1)*sz(2),1);
% 
% if strcmp(handles.ScreenParameters.CoordinateSystem,'Cartesian')
%     [lon,lat]=ddb_ddb_deg2utm(xx,yy,handles.ScreenParameters.UTMZone{1});
%     x=reshape(lon,sz(1),sz(2));
%     y=reshape(lat,sz(1),sz(2));
% end

if ok==0
%     x0=x-360;
%     y0=y;
%     z0=z;
%     handles.GUIData.x=[x0 x];
%     handles.GUIData.y=[y0 y];
%     handles.GUIData.z=[z0 z];
%      handles.GUIData.x=x;
%      handles.GUIData.y=y;
%      handles.GUIData.z=z;
% else
    disp('Could not connect to server ...');
    handles=getHandles;
    x0=handles.ScreenParameters.Etopo05.X;
    y0=handles.ScreenParameters.Etopo05.Y;
    z0=handles.ScreenParameters.Etopo05.Z;
    [x1,y1]=meshgrid(x0(:,1)',y0(1,:)');
    z1=z0';
    x=[x1];
    y=[y1];
    z=[z1];
end
