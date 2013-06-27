function [pos,tar]=flightpathspline(flightpath,times,dataaspectratio)

for ip=1:length(flightpath.waypoint)        

    tar0(1)=str2double(flightpath.waypoint(ip).waypoint.cameratargetx);
    tar0(2)=str2double(flightpath.waypoint(ip).waypoint.cameratargety);
    tar0(3)=str2double(flightpath.waypoint(ip).waypoint.cameratargetz);
    ang0(1)=str2double(flightpath.waypoint(ip).waypoint.cameraazimuth);
    ang0(2)=str2double(flightpath.waypoint(ip).waypoint.cameraelevation);
    ang0(3)=str2double(flightpath.waypoint(ip).waypoint.cameradistance);
    pos0=cameraview('viewangle',ang0,'target',tar0,'dataaspectratio',dataaspectratio);
    
    t0(ip)=datenum(flightpath.waypoint(ip).waypoint.time,'yyyymmdd HHMMSS');    
    tarx0(ip)=tar0(1);
    tary0(ip)=tar0(2);
    tarz0(ip)=tar0(3);
    posx0(ip)=pos0(1);
    posy0(ip)=pos0(2);
    posz0(ip)=pos0(3);

end

tar(:,1)=spline(t0,tarx0,times)';
tar(:,2)=spline(t0,tary0,times)';
tar(:,3)=spline(t0,tarz0,times)';

pos(:,1)=spline(t0,posx0,times)';
pos(:,2)=spline(t0,posy0,times)';
pos(:,3)=spline(t0,posz0,times)';
