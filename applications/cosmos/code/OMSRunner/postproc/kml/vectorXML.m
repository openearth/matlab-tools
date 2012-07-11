clear variables;close all;
[x,y]=meshgrid(4.1:0.001:4.12,52:0.001:52.02);
nx=size(x,1);
ny=size(x,2);
np=nx*ny;
x=reshape(x,[1 np]);
y=reshape(y,[1 np]);
mdl.x.value=x;
mdl.x.type='real';
mdl.y.value=y;
mdl.y.type='real';
for it=1:49
%     u=zeros(size(x))+it/50;
%     v=zeros(size(x))+cos(it/10);
    u=2*(rand(size(x))-0.5);
    v=2*(rand(size(x))-0.5);
    mdl.times(it).time.u.value=u;
    mdl.times(it).time.u.type='real';
    mdl.times(it).time.v.value=v;
    mdl.times(it).time.v.type='real';
end

struct2xml('c:\xampp\htdocs\scenarios\zandmotor_forecast\europe\zandmotor_zwin\figures\test.xml',mdl);
