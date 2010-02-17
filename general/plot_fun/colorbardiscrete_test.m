clear all;
close all;
clc;

%% Example 1
figure
mypeaks = peaks(20);
mylevels = [-8 -6 -4 -2 0 2 4 6 7];
[c,h] = contourf(mypeaks,mylevels);
colorbartitle = 'peaks';
cbd = colorbardiscrete(colorbartitle,mylevels);
axpos = get(gca,'position');
set(gca,'position',axpos+[-0.05 0 0 0]);
cbdpos = get(cbd,'position');
set(cbd,'position',cbdpos+[-0.05 0 0 0]);

%% Example 2
figure;
colormap(hot);
ax1 = subplot(2,1,1);
mypeaks = peaks(20);
mylevels1 = [-8 -6 -4 -2 0 2 4 6 7];
[c,h] = contourf(mypeaks,mylevels1);
colorbartitle = 'peaks';

ax2 = subplot(2,1,2);
mypeaks = peaks(20);
mylevels2 = [-8 -5 0 5 7];
[c,h] = contourf(mypeaks,mylevels2);
colorbartitle = 'peaks';
cbd1 = colorbardiscrete(colorbartitle,mylevels1,'unit','m/s','fmt','%6.2f','peer',ax1);
cbd2 = colorbardiscrete(colorbartitle,mylevels2,'unit','m/s','fmt','%6.2f','peer',ax2,'dx',0.02,'dy',0.02);

ax1pos = get(ax1,'position');
set(ax1,'position',ax1pos+[-0.07 0 0 0]);
ax2pos = get(ax2,'position');
set(ax2,'position',ax2pos+[-0.07 0 0 0]);

cbd1pos = get(cbd1,'position');
set(cbd1,'position',cbd1pos+[-0.07 0 0 0]);
cbd2pos = get(cbd2,'position');
set(cbd2,'position',cbd2pos+[-0.07 0 0 0]);
