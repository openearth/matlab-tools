function [x1,y1,z1]=Helmert7(x0,y0,z0,dx,dy,dz,rx,ry,rz,ds)
      
m=1.0 + ds*0.000001;
      
x1 = m*(    x0 - rz*y0 + ry*z0) + dx;
y1 = m*( rz*x0 +    y0 - rx*z0) + dy;
z1 = m*(-ry*x0 + rx*y0 +    z0) + dz;
