% Example to create XBeach grid

%TODO: make XBeach_Write_Inp suitable for 2D grids 

close all
clear
clc

%% read data
fname = 'frfsurvey.htm';

[X Y Z] = readhtmldata(fname);

%%
[X Y Z alfa propertyCell] = XBeach_GridOrientation(X, Y, Z,...
    'xori', max(X),...
    'yori', max(Y),...
    'xend_y0', [min(X) max(Y)],...
    'x_yend', [min(X) min(Y)]);

%% make grid
XB = XBeach_selectgrid(X, Y, Z,...
    CreateEmptyXBeachVar,...
    propertyCell{:},...
    'alfa', alfa,...
    'posdwn', -1);

%% plot grid
figure
pcolor(XB.Input.xInitial, XB.Input.yInitial, XB.Input.zInitial)
axis equal