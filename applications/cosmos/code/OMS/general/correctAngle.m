function [u,v]=correctAngle(u,v,alfa)

umag=sqrt(u.^2+v.^2);
angle=atan2(v,u);
angle=angle+alfa;

u=umag.*cos(angle);
v=umag.*sin(angle);
