[c.x,c.y,c.x_shift    ] = surfer_read('private\x2c.grd');
[c.x,c.y,c.y_shift,OPT] = surfer_read('private\y2c.grd');

nn = 120;
mm = 140;

yRD = c.y(mm)+(0:100:2000);
xRD = c.x(nn)+zeros(size(yRD));
[x_shift y_shift] = rd_correction_shift(xRD, yRD);
plot(c.y(mm+[-1 0 1 2 3]),c.y_shift(mm+[-1 0 1 2 3],nn),'ro',yRD,y_shift,'b.')

xRD = c.x(mm)+(0:100:2000);
yRD = c.y(nn)+zeros(size(yRD));
[x_shift y_shift] = rd_correction_shift(xRD, yRD);
plot(c.x(mm+[-1 0 1 2 3]),c.x_shift(nn,mm+[-1 0 1 2 3]),'ro',xRD,x_shift,'b.')
