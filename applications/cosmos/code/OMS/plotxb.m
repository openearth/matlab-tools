close all;

outdir9='F:\OperationalModelSystem\SoCalCoastalHazards\scenarios\jan2010_slr14\models\northamerica\la02x\lastrun\input\2099\tst\';
outdir8='F:\OperationalModelSystem\test02\';
outdir9='F:\OperationalModelSystem\test03\';
XBdims=getdimensions(outdir9);
s8=readvar([outdir8 'zb.dat'],XBdims);
s9=readvar([outdir9 'zb.dat'],XBdims);

xx=pathdistance(XBdims.x,XBdims.y);



plot(xx,s9(:,1,1),'k');hold on;
plot(xx,s9(:,1,end),'r');
plot(xx,s8(:,1,end),'b');


figure(3)
clf
for j=1:size(s5,3)
plot(XBdims.x,s5(:,1,j),'r');
pause(0.1)
end

figure(4)
clf
for j=1:size(s8,3)
plot(XBdims.x,s8(:,1,j),'r');
pause(0.1)
end

figure(5)
clf
for j=1:size(s9,3)
plot(XBdims.x,s9(:,1,j),'r');
pause(0.1)
end
