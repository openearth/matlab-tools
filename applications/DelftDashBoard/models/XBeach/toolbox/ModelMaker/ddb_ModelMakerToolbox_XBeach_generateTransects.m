function handles=ddb_ModelMakerToolbox_XBeach_generateTransects(handles)


% Settings
dxmin = handles.toolbox.modelmaker.dX;
dxmax = handles.toolbox.modelmaker.dxmax;
Tmean = handles.toolbox.modelmaker.Tp/1.1;
depthneeded  = handles.toolbox.modelmaker.depth;
D50 = handles.toolbox.modelmaker.D50;
tsimulation = handles.model.xbeach.domain.tstop;
ntransects = handles.toolbox.modelmaker.xb_trans.ntransects;
mainfolder = pwd;

for ii = 1:ntransects
    
    %% Get bathy data
    % Find coordinates of corner points
    x = [handles.toolbox.modelmaker.xb_trans.xoff(ii) handles.toolbox.modelmaker.xb_trans.xback(ii)];
    y = [handles.toolbox.modelmaker.xb_trans.yoff(ii) handles.toolbox.modelmaker.xb_trans.yback(ii)];

    % Sizes
    xl(1)=min(x);
    xl(2)=max(x);
    yl(1)=min(y);
    yl(2)=max(y);
    dbuf=(xl(2)-xl(1))/20;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;

    % Coordinate coversion
    coord=handles.screenParameters.coordinateSystem;
    iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
    dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    [xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

    % Get bathymetry in box around model grid
    [xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dxmin);

    % xx and yy are in coordinate system of bathymetry (usually WGS 84)
    % convert bathy grid to active coordinate system
    if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
        dmin=dxmin;
        [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
        [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
        zz=interp2(xx,yy,zz,xgb,ygb);
    else
        xg=xx;
        yg=yy;
    end
    xline = linspace(x(1), x(2),1000); yline =  linspace(y(1), y(2),1000);
    id = ~isnan(zz);    F1 = scatteredInterpolant(xg(id), yg(id), zz(id),'natural', 'none');
    zline = F1(xline, yline); 

    %% Update cross-sections
	crossshore = ((xline - xline(1,1)).^2 + (yline - yline(1,1)).^2.).^0.5;
    
    % Create Dean profile
    D = D50*10^-3;
    A = -0.21*D^0.48;
    xs = linspace(0, max(crossshore)*10, 1000);
    h = A*xs.^(2/3);
    id = find (h < depthneeded*-1);
    xs = xs(1:id(1)); h = h(1:id(1));
    
    if handles.toolbox.modelmaker.dean == 1

        % Apply if Dean
        id = find( zline > 0);
        zline_TMP = zline(id(1):end)
        X_TMP = crossshore(id(1):end); X_TMP = X_TMP - min(X_TMP);
        X_TMP2 = [xs X_TMP+max(xs)+0.01];
        Z_TMP2 = [fliplr(h) zline_TMP];

        % Store
        crossshore = X_TMP2;
        zline = Z_TMP2;

    else
        
        % Check created grid 
        if min(zline) > depthneeded*-1;
            dz = round(abs(depthneeded - min(zline)));

            % Determine slope
            id = find( (depthneeded + min(zline))/2 > h);
            slope = (h(id(1)+1) - h(id(1)) )/  (xs(id(1)+1) - xs(id(1)) );
            slope = -1/slope;

            dx = dz * slope; % slope of 1/100;
            zline = [depthneeded*-1 zline];
            crossshore = [0 crossshore+dx];
        end
    end
    
    %% Optimalise grid
    [xopt zopt] = xb_grid_xgrid(crossshore, zline, 'dxmin', dxmin, 'dxmax', dxmax, 'Tm', Tmean, 'CFL', 0.7);
    xori = xline(end); yori = yline(end);
    rotation_applied = 270-handles.toolbox.modelmaker.xb_trans.coast(ii);
    yopt = zeros(1,length(xopt));
    xr = xori- sind(rotation_applied-90)*xopt;
    yr = yori- cosd(rotation_applied-90)*xopt;

    %% Make structure
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
            'front', 'abs_1d', ...
            'back', 'abs_1d', ...
            'dtheta',abs(handles.model.xbeach.domain.thetamax - handles.model.xbeach.domain.thetamin),...
            'thetanaut', 1, ...
            'tstop', tsimulation, ...
            'tstart', 0,...
            'tintg', tsimulation/100,...
            'tintm', tsimulation/5,...
            'epsi',-1,...                   
            'meanvar',          {'zs', 'H','ue', 've', 'hh'} ,...
            'globalvar',        {'zb', 'zs', 'H', 'ue', 've', 'sedero', 'hh'}});         


    % Create folder
    cd(mainfolder)
    if ii > 99
        filename = ['Transect_', num2str(ii)];
    end
    if ii > 9
        filename = ['Transect_0', num2str(ii)];
    else
        filename = ['Transect_00', num2str(ii)];
    end
    mkdir(filename); cd(filename);
        
    % Change grid
    xbm.data(1).value = length(xr)-1;
    xbm.data(2).value = 0;
    xbm.data(3).value = 0;  xbm.data(4).value = 0; 
    xbm.data(7).value.data.value = xr;
    xbm.data(8).value.data.value = yr;
    save('xbm') 

    % Fix
    xgrid                   = xs_get(xbm,'xfile.xfile');
    ygrid                   = xs_get(xbm,'yfile.yfile');
    zgrid                   = xs_get(xbm,'depfile.depfile');

    zmin = min(min(min(zopt)), depthneeded);
    id = zgrid < zmin; zgrid(id) = zmin;
    id = zgrid > max(max(zopt)); zgrid(id) = max(max(zopt)); % nothing higher than org.

    % Write
    xbm.data(9).value.data.value = zgrid;

    % G. Write the params
    xb_write_input('params.txt', xbm);  
end
end
