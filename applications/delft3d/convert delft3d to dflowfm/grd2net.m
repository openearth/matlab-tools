warning off all;
fclose all; 
clc       ;

% Check if the directories have been set
pathin      = get(handles.edit1,'String');
pathout     = get(handles.edit2,'String');
if isempty(pathin);
    errordlg('The input directory has not been assigned','Error');
    return;
end
if isempty(pathout);
    errordlg('The output directory has not been assigned','Error');
    return;
end
if exist(pathin,'dir')==0;
    errordlg('The input directory does not exist.','Error');
    return;
end
if exist(pathout,'dir')==0;
    errordlg('The output directory does not exist.','Error');
    return;
end

% Read paths and modelname from screen
modelid                     = get(handles.listbox1,'Value');
modelentry                  = get(handles.listbox1,'String');
modelshort                  = modelentry(modelid,:);
modelshort(modelshort==' ') = [];
modelshort(end-3:end)       = [];

% Check net file (block analogue to previous block for ext-files)
netfileread = get(handles.edit6,'String');
netfileread(netfileread==' ') = [];
if isempty(netfileread);
    errordlg('The net-file name has not been assigned','Error');
    return;
end
if length(netfileread)>6;
    if strcmp(netfileread(end-6:end),'_net.nc');
        netfile    = netfileread(1:end-7);
    else
        netfile    = netfileread;
    end
else
    netfile = netfileread;
end

% Set file names
ddgrid      = [pathin,'/',modelshort,'.grd'];
netfile     = [pathout,'/',netfile,'_net.nc'];

% Read the sizes of the grid (more robust than OET-tools)
fid         = fopen(ddgrid,'r');
for i=1:10;
    tline   = fgetl(fid);
    if length(tline) >= 4;
        if strcmp(tline(1:4),' ETA') | strcmp(tline(1:4),' eta');
            startgrid   = i-2;  
            break;
        end
    end
end
fclose(fid);
fid         = fopen(ddgrid,'r');
for i=1:startgrid;
    tline   = fgetl(fid);
end
MN          = str2num(tline);
M           = MN(1);
N           = MN(2);
fclose(fid);

% Read the grid
G           = delft3d_io_grd('read',ddgrid);
xh          = G.cor.x;
yh          = G.cor.y;
xc          = G.cend.x;
yc          = G.cend.y;

% Check coordinate system
if strcmp(G.CoordinateSystem,'Spherical');
    spher   = 1;
else
    spher   = 0;
end

% Transpose the grid (x and y) if the sizes do not match with read M and N (the latter match with the bnd!)
if size(xh,1)~=M+1 & size(xh,2)~=N+1 & size(yh,1)~=M+1 & size(yh,2)~=N+1;
    xh = xh';
    yh = yh';
    xc = xc';
    yc = yc';
end

% Extrapolate boundaries: boundary conditions given at cell centers
xc(1  , : ) = 2.*xc(2  , : ) - xc(3  , : );
yc(1  , : ) = 2.*yc(2  , : ) - yc(3  , : );
xc( : ,1  ) = 2.*xc( : ,2  ) - xc( : ,3  );
yc( : ,1  ) = 2.*yc( : ,2  ) - yc( : ,3  );
xc(M+1, : ) = 2.*xc(M  , : ) - xc(M-1, : );
yc(M+1, : ) = 2.*yc(M  , : ) - yc(M-1, : );
xc( : ,N+1) = 2.*xc( : ,N  ) - xc( : ,N-1);
yc( : ,N+1) = 2.*yc( : ,N  ) - yc( : ,N-1);

% Read the depth data
depthid                     = get(handles.listbox11,'Value');
depthentry                  = get(handles.listbox11,'String');
depthentry(depthentry==' ') = [];
jabodem                     = ~isempty(depthentry);
if jabodem == 1;
    % Read the filename of the depth file
    depthid                     = get(handles.listbox11,'Value');
    depthentry                  = get(handles.listbox11,'String');
    depthshort                  = depthentry(depthid,:);
    depthshort(depthshort==' ') = [];
    depthshort(end-3:end)       = [];
    
    % Set file name of the depth file
    depdata      = [pathin,'/',depthshort,'.dep'];
    
    % Use 'wldep'-script
    depthdat     = wldep('read',depdata,[M+1 N+1],'multiple');
    zh           = depthdat.Data;
    zh(zh==-999) = NaN;
    zh           = -zh;
    zh(end,:  )  = [];
    zh(:  ,end)  = [];
    
    % Make file with bathymetry samples
    samples      = [pathout,'/',depthshort,'.xyz'];
    xsamp        = reshape(xh,[M.*N 1]);
    ysamp        = reshape(yh,[M.*N 1]);
    zsamp        = reshape(zh,[M.*N 1]);
    nannetjes    = isnan(xsamp);
    xsamp(nannetjes==1)   = [];
    ysamp(nannetjes==1)   = [];
    zsamp(nannetjes==1)   = [];
    dlmwrite(samples,[xsamp,ysamp,zsamp],'delimiter','\t','precision','%7.7f');
else
    % Set bottom to dummy value of -5.0 m w.r.t. reference (also default in mdu)
    zh           = -5.0.*ones(size(xh,1),size(xh,2));
end

% Write netCDF-file
net2cdf;

% Message
msgbox('The net file has been written.','Message');