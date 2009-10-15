function BSS = BrierSkillScore(xc,zc,xm,zm,x0,z0,nx)

%% clear all nan values in input (to avoid problems with interpolation)
x0(isnan(z0))=[];
z0(isnan(z0))=[];
xc(isnan(zc))=[];
zc(isnan(zc))=[];
xm(isnan(zm))=[];
zm(isnan(zm))=[];

%% determine new grid covered by all profiles
newxlow = max([min(x0) min(xc) min(xm)]);
newxhigh = min([max(x0) max(xc) max(xm)]);
xextends = newxhigh - newxlow;

x_new = newxlow:xextends/nx:newxhigh;

%% interpolate profiles onto new grid
z0_new = interp1(x0,z0,x_new);
zc_new = interp1(xc,zc,x_new);
zm_new = interp1(xm,zm,x_new);

%% calculate BSS
mse_p=mean((zm_new - zc_new).^2);
mse_0=mean((zm_new - z0_new).^2);
BSS = 1. - (mse_p/mse_0);