function handles=ddb_ModelMakerToolbox_XBeach_generateModel(handles)

% Settings
xori=handles.toolbox.modelmaker.xOri;
nx=handles.toolbox.modelmaker.nX;
dx=handles.toolbox.modelmaker.dX;
yori=handles.toolbox.modelmaker.yOri;
ny=handles.toolbox.modelmaker.nY;
dy=handles.toolbox.modelmaker.dY;
rot=pi*handles.toolbox.modelmaker.rotation/180;
zmax=handles.toolbox.modelmaker.zMax;
dmin=min(dx,dy);

% Find coordinates of corner points
x(1)=xori;
y(1)=yori;
x(2)=x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
y(2)=y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
x(3)=x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
y(3)=y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
x(4)=x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
y(4)=y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);

xl(1)=min(x);
xl(2)=max(x);
yl(1)=min(y);
yl(2)=max(y);
dbuf=(xl(2)-xl(1))/20;
xl(1)=xl(1)-dbuf;
xl(2)=xl(2)+dbuf;
yl(1)=yl(1)-dbuf;
yl(2)=yl(2)+dbuf;

coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;

[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

% Get bathymetry in box around model grid
[xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);

% xx and yy are in coordinate system of bathymetry (usually WGS 84)
% convert bathy grid to active coordinate system
if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
    dmin=min(dx,dy);
    [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
    [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
    zz=interp2(xx,yy,zz,xgb,ygb);
else
    xg=xx;
    yg=yy;
end
[x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,100,xg,yg,zz);


%% 3. Closure
if handles.toolbox.modelmaker.rotation < 0
    rotation = round(360 + handles.toolbox.modelmaker.rotation);
else
    rotation = round(handles.toolbox.modelmaker.rotation);
end

z2 = (z');
x2 = (x');
y2 = (y');
rotation_model = rotation;

% Simulation
tsimulation = handles.model.xbeach.domain.tstop;
depthneeded = round((handles.toolbox.modelmaker.Hs*2.5))*-1;

if handles.toolbox.modelmaker.domain1d == 1;
    xtmp = x; ytmp = y; ztmp = z;
    [nx ny] = size(z);
    x = x (:, round(ny/2));
    y = y (:, round(ny/2));
    z = z (:, round(ny/2));
end

if handles.toolbox.modelmaker.domain1d == 1
    
    % Optimize grid
    xtmp = x;
    ytmp = y;
    ztmp = z;
    
    %
    crossshore = ((x - x(1,1)).^2 + (y - y(1,1)).^2.).^0.5;
    [xopt zopt] = xb_grid_xgrid(crossshore, z);
    
    xori = x(1); yori = y(1);
    rotation_applied = rotation_model 
    yopt = zeros(1,length(xopt));
    xr = xori+ cosd(rotation_applied)*xopt
    yr = yori+ sind(rotation_applied)*xopt
    
    figure; hold on;
    plot(x,y)
    plot(xr,yr,'r--')
    plot(x(1),y(1),'bo')
    plot(x(end),y(end),'bo')
    plot(xr(1),yr(1),'bo')
    legend('org', 'opt')
    
    
    % Make structure
    xbm = xb_generate_model(...
    'bathy',...
            {'x', xr, 'y', yr, 'z', zopt,...
            'world_coordinates',true,...
            'optimize', false}, ...
    'waves',...
            {'Hm0', [handles.toolbox.modelmaker.Hs], 'Tp', [handles.toolbox.modelmaker.Tp], 'duration', [tsimulation] 'mainang', handles.toolbox.modelmaker.waveangle}, ...
    'tide',... 
            {'time', [0 tsimulation] 'front', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL], 'back', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL]},...
    'settings', ...
            {'outputformat','netcdf',... 
            'morfac', 1,...
            'morstart', 0, ...
            'break', 'roelvink_daly',...
            'bedfriction', 'manning', ...
            'CFL', handles.model.xbeach.domain.CFL,...
            'front', 'abs_2d', ...
            'back', 'abs_2d', ...
            'dtheta',abs(handles.model.xbeach.domain.thetamax - handles.model.xbeach.domain.thetamin),...
            'thetanaut', 1, ...
            'tstop', tsimulation, ...
            'tstart', 0,...
            'tintg', tsimulation/10,...
            'tintm', tsimulation/1,...
            'epsi',-1,...                   
            'meanvar',          {'zs', 'H','ue', 've'} ,...
            'globalvar',        {'zb', 'zs', 'H', 'ue', 've', 'sedero', 'hh'}});         
        
        
        % Change grid
        xbm.data(1).value = length(xr)-1;
        xbm.data(2).value = 0;
        xbm.data(7).value.data.value = xr;
        xbm.data(8).value.data.value = yr;
else
    xbm = xb_generate_model(...
    'bathy',...
            {'x', x, 'y', y, 'z', z,... 
            'xgrid', {'dxmin',dx, 'dxmax', handles.toolbox.modelmaker.dxmax},... 
            'ygrid', {'dymin',dy, 'dymax', handles.toolbox.modelmaker.dymax, 'area_size', handles.toolbox.modelmaker.areasize/100},...
            'rotate', rotation_model,...
            'crop', false,...
            'world_coordinates',true,...
            'finalise', {'actions', {'seaward_flatten', 'seaward_extend'},'zmin',depthneeded}}, ...
    'waves',...
            {'Hm0', [handles.toolbox.modelmaker.Hs], 'Tp', [handles.toolbox.modelmaker.Tp], 'duration', [tsimulation] 'mainang', handles.toolbox.modelmaker.waveangle}, ...
    'tide',... 
            {'time', [0 tsimulation] 'front', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL], 'back', [handles.toolbox.modelmaker.SSL handles.toolbox.modelmaker.SSL]},...
    'settings', ...
            {'outputformat','netcdf',... 
            'morfac', 1,...
            'morstart', 0, ...
            'break', 'roelvink_daly',...
            'bedfriction', 'manning', ...
            'CFL', handles.model.xbeach.domain.CFL,...
            'front', 'abs_2d', ...
            'back', 'abs_2d', ...
            'dtheta',abs(handles.model.xbeach.domain.thetamax - handles.model.xbeach.domain.thetamin),...
            'dtheta_s', 10,...
            'single_dir', 1,...
            'thetanaut', 1, ...
            'tstop', tsimulation, ...
            'tstart', 0,...
            'tintg', tsimulation/10,...
            'tintm', tsimulation/1,...
            'epsi',-1,...                   
            'swave',handles.model.xbeach.domain.swave,...
            'lwave',handles.model.xbeach.domain.lwave,...
            'flow',handles.model.xbeach.domain.flow,...
            'sedtrans',handles.model.xbeach.domain.sedtrans,...
            'morphology',handles.model.xbeach.domain.morphology,...
            'avalanching',handles.model.xbeach.domain.morphology,...
            'g',handles.model.xbeach.domain.g,...
            'rho',handles.model.xbeach.domain.rho,...
            'meanvar',          {'zs', 'H','ue', 've'} ,...
            'globalvar',        {'zb', 'zs', 'H', 'ue', 've', 'sedero'}});         
end
save('xbm') 

% Fix
xgrid                   = xs_get(xbm,'xfile.xfile');
ygrid                   = xs_get(xbm,'yfile.yfile');
zgrid                   = xs_get(xbm,'depfile.depfile');

zmin = min(min(min(z)), depthneeded);
id = zgrid < zmin; zgrid(id) = zmin;
id = zgrid > max(max(z)); zgrid(id) = max(max(z)); % nothing higher than org.

% Fix theta
xbm.data(18).value = handles.model.xbeach.domain.thetamin;
xbm.data(19).value = handles.model.xbeach.domain.thetamax;
xbm.data(20).value = abs(handles.model.xbeach.domain.thetamax - handles.model.xbeach.domain.thetamin);

% Lateral
gridcelss = 3;
if handles.toolbox.modelmaker.domain1d ~= 1
    [nx ny] = size(zgrid);
    for i = 1:gridcelss-1
        zgrid(i,:) = zgrid(gridcelss,:);
        zgrid(nx-i+1,:) = zgrid(nx-gridcelss,:);
    end
end

% Back
[nx ny] = size(zgrid);
    for i = 1:gridcelss-1
        zgrid(:,ny-i+1) = zgrid(:,ny-gridcelss);
    end

% Write
xbm.data(9).value.data.value = zgrid;
    
% G. Write the params
xb_write_input('params.txt', xbm)  


%% Update model data
handles.model.xbeach.domain(1).depth       = zgrid;
handles.model.xbeach.domain(1).bathymetry  = zgrid;
handles.model.xbeach.domain(1).grid.x      = xgrid;
handles.model.xbeach.domain(1).grid.y      = ygrid;
