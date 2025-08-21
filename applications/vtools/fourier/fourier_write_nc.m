%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Write result of steady-state Fourier for alternate bars in NetCDF format.

function fourier_write_nc(filename,x,y,t,Q_rec,noise_Lbx,noise_W,etab_max,c,w)

nx=numel(x);
ny=numel(y);
nt=numel(t);

ncid=netcdf.create(filename,'CLOBBER');

% Define dimensions
% v_dim=netcdf.defDim(ncid,'variable',ne);
x_dim=netcdf.defDim(ncid,'x-coordinate',nx);
y_dim=netcdf.defDim(ncid,'y-coordinate',ny);
t_dim=netcdf.defDim(ncid,'time',nt);

% Define variables
% v_var=netcdf.defVar(ncid,'variable','NC_FLOAT',[v_dim,x_dim,y_dim,t_dim]);
% netcdf.putAtt(ncid,v_var,'units','[m,m^2/s,m^2/s,m]');
% netcdf.putAtt(ncid,v_var,'long_name','[flow depth, specific discharge in x direction, specific discharge in y direction, bed elevation]');

x_var=netcdf.defVar(ncid,'x','NC_FLOAT',x_dim);
netcdf.putAtt(ncid,x_var,'units','m');
netcdf.putAtt(ncid,x_var,'long_name','x-coordinate');

y_var=netcdf.defVar(ncid,'y','NC_FLOAT',y_dim);
netcdf.putAtt(ncid,y_var,'units','m');
netcdf.putAtt(ncid,y_var,'long_name','y-coordinate');

t_var=netcdf.defVar(ncid,'t','NC_FLOAT',t_dim);
netcdf.putAtt(ncid,t_var,'units','s');
netcdf.putAtt(ncid,t_var,'long_name','time');

h_var=netcdf.defVar(ncid,'h','NC_FLOAT',[x_dim,y_dim,t_dim]);
netcdf.putAtt(ncid,h_var,'units','m');
netcdf.putAtt(ncid,h_var,'long_name','flow depth');

qx_var=netcdf.defVar(ncid,'qx','NC_FLOAT',[x_dim,y_dim,t_dim]);
netcdf.putAtt(ncid,qx_var,'units','m^2/s');
netcdf.putAtt(ncid,qx_var,'long_name','specific discharge in x-direction');

qy_var=netcdf.defVar(ncid,'qy','NC_FLOAT',[x_dim,y_dim,t_dim]);
netcdf.putAtt(ncid,qy_var,'units','m^2/s');
netcdf.putAtt(ncid,qy_var,'long_name','specific discharge in y-direction');

etab_var=netcdf.defVar(ncid,'etab','NC_FLOAT',[x_dim,y_dim,t_dim]);
netcdf.putAtt(ncid,etab_var,'units','m');
netcdf.putAtt(ncid,qy_var,'long_name','bed elevation');

% Add attributes
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'title','Linear solution alternate bars.');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'wavelength in x-direction [m]',noise_Lbx); 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'wavelength in y-direction [m]',noise_W*2); 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'initial perturbation in bed level [m]',etab_max); 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'celerity [m s-1]',c); 
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'growth rate [rad s-1]',w); 

% End define mode
netcdf.endDef(ncid);

% Write data
% netcdf.putVar(ncid,v_var,Q_rec);
netcdf.putVar(ncid,x_var,x);
netcdf.putVar(ncid,y_var,y);
netcdf.putVar(ncid,t_var,t);
netcdf.putVar(ncid,h_var,Q_rec(1,:,:,:));
netcdf.putVar(ncid,qx_var,Q_rec(2,:,:,:));
netcdf.putVar(ncid,qy_var,Q_rec(3,:,:,:));
netcdf.putVar(ncid,etab_var,Q_rec(4,:,:,:));

% Close file
netcdf.close(ncid);

messageOut(NaN,sprintf('file written: %s',filename));

end %function