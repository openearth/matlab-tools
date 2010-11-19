function [XBdims XBdims_nc] = nc_getdimensions(url)

info=nc_info(url);

XBdims = struct();

% read dimensions
for i = 1:length(info.Dimension)
    XBdims.(info.Dimension(i).Name) = info.Dimension(i).Length;
end

XBdims_nc = XBdims;

% translate for backwards compatibility
XBdims.nt=XBdims.globaltime;
XBdims.nx=XBdims.x-1;
XBdims.ny=XBdims.y-1;
XBdims.ntheta=XBdims.wave_angle;
XBdims.kmax=[];
XBdims.ngd=XBdims.sediment_classes;
XBdims.nd=XBdims.bed_layers;
XBdims.ntp=[];
XBdims.ntc=[];
XBdims.ntm=[];
XBdims.tsglobal=nc_varget(url,'globaltime');
XBdims.tspoints=[];
XBdims.tscross=[];
XBdims.tsmean=[];

XBdims.x=nc_varget(url,'x');
XBdims.y=nc_varget(url,'y');
XBdims.xc=[];
XBdims.yc=[];