%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Description

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

path_add_fcn='c:\Users\chavarri\checkouts\openearthtools_matlab\applications\vtools\general\';

%% ADD OET

addpath(path_add_fcn)
addOET(path_add_fcn) 

%% INPUT

gridfile='trial_grd_net.nc';
dx=500;
dy=250;
L=10000;
B=5000;

%% CALC

xr=0:dx:L;
yr=0:dy:B;

[x,y]=meshgrid(xr,yr);
[nr,nc]=size(x);

n=reshape(1:length(x(:)),[nr,nc]);

lnk=[[reshape(n(1:nr-1,:), [(nr-1)*nc, 1]), reshape(n(2:nr,:), [(nr-1)*nc, 1])]; ...
    [reshape(n(:,1:nc-1), [nr*(nc-1), 1]), reshape(n(:,2:nc), [nr*(nc-1), 1])]];

%rename
x_v=x(:);
y_v=y(:);
lnk_v=lnk.';

lnk_x=[x_v(lnk(:,1)),x_v(lnk(:,2))];
lnk_y=[y_v(lnk(:,1)),y_v(lnk(:,2))];

%% SAVE

dflowfm.writeNet(gridfile,x_v,y_v,lnk_v);

%% PLOT

figure
hold on
scatter(x(:),y(:),'ok')
plot(lnk_x',lnk_y','r')

