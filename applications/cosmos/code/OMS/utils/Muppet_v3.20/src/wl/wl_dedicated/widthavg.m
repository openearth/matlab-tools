function widthavg
%WIDTHAVG function

d3d_qp('allm',1)
d3d_qp('alln',1)
d3d_qp presenttype conti
data=d3d_qp('loaddata');

figure
d0=mean(data.Val(:,18:28),2);
plot(825.2+(0:281)*0.15,d0)
mean(d0(1:end-1))

