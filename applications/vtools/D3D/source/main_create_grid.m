%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 14 $
%$Date: 2021-08-04 13:25:20 +0200 (Wed, 04 Aug 2021) $
%$Author: chavarri $
%$Id: main_plot_all.m 14 2021-08-04 11:25:20Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/rmm_plot/main_plot_all.m $
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

