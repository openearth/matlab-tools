
clear
%%
p=[85820.580246,444668.799451];

%%

tol=1000;
x_lims=p(1)+[tol,-tol];
y_lims=p(2)+[tol,-tol];

np=11;
x_v=linspace(p(1)-tol/3,p(1)+tol/3,np);
y_v=linspace(p(2)-tol/3,p(2)+tol/3,np);
[x_m,y_m]=meshgrid(x_v,y_v);
z=10*rand(11,11);

%%
han.fig=figure;
hold on
kr=1; kc=1;
han.sfig(kr,kc)=subaxis(1,1,1,1,1,1);

OPT.xlim=x_lims;
OPT.ylim=y_lims;
OPT.epsg_in=28992; %WGS'84 / google earth
OPT.tzl=tiles_zoom(diff(x_lims)); %zoom
OPT.save_tiles=false; %save mat file with tiles
OPT.path_tiles='C:\Users\chavarri\checkouts\riv\earth_tiles\'; %for saving the images
OPT.map_type=3;%map type
OPT.han_ax=han.sfig(kr,kc);

plotMapTiles(OPT);

surf(x_m,y_m,z);
