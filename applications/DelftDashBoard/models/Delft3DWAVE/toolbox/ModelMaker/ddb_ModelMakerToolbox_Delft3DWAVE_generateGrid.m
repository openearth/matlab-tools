function handles=ddb_ModelMakerToolbox_Delft3DWAVE_generateGrid(handles,varargin)

% Function generates and plots rectangular grid can be called by ddb_ModelMakerToolbox_quickMode_Delft3DFLOW or
% ddb_CSIPSToolbox_initMode

filename=[];
opt='new';

for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
        case{'option'}
            opt=varargin{ii+1};
    end
end

if isempty(filename)
    [filename, ok] = gui_uiputfile('*.grd', 'Grid File Name',[handles.model.delft3dwave.domain.attName '.grd']);
    if ~ok
        return
    end
end

attname=filename(1:end-4);

switch opt
    case{'new'}
        for ii=1:handles.model.delft3dwave.domain.nrgrids
            if strcmpi(attname,handles.model.delft3dwave.domain.domains(ii).gridname)
                ddb_giveWarning('text','A wave domain with this name already exists. Try again.');
                return
            end
        end
end

wb = waitbox('Generating grid ...');pause(0.1);

xori=handles.toolbox.modelmaker.xOri;
%nx=round(handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.dX/handles.toolbox.modelmaker.wavedX);
nx=handles.toolbox.modelmaker.nX;
dx=handles.toolbox.modelmaker.wavedX;
yori=handles.toolbox.modelmaker.yOri;
%ny=round(handles.toolbox.modelmaker.nY*handles.toolbox.modelmaker.dY/handles.toolbox.modelmaker.wavedY);
ny=handles.toolbox.modelmaker.nY;
dy=handles.toolbox.modelmaker.wavedY;
rot=pi*handles.toolbox.modelmaker.rotation/180;
zmax=handles.toolbox.modelmaker.zMax;

% Find minimum grid resolution (in metres)
dmin=min(dx,dy);
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    dmin=dmin*111111;
end
%    dmin=dmin/2;
%     dmin=15000;

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

% Convert limits to cs of bathy data
coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;

[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

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

[x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);

close(wb);

switch opt
    case{'new'}
        handles.model.delft3dwave.domain.nrgrids=handles.model.delft3dwave.domain.nrgrids+1;
        nrgrids=handles.model.delft3dwave.domain.nrgrids;
        handles.model.delft3dwave.domain.gridnames{nrgrids}=filename(1:end-4);
        handles.model.delft3dwave.domain.domains=ddb_initializeDelft3DWAVEDomain(handles.model.delft3dwave.domain.domains,nrgrids);
        handles.activeWaveGrid=nrgrids;
        if nrgrids>1
            handles.model.delft3dwave.domain.domains(nrgrids).nestgrid=handles.model.delft3dwave.domain.domains(1).gridname;
            for ii=1:handles.activeWaveGrid-1
                handles.model.delft3dwave.domain.nestgrids{ii}=handles.model.delft3dwave.domain.domains(ii).gridname;
            end
        else
            handles.model.delft3dwave.domain.domains(nrgrids).nestgrid='';
        end
    case{'existing'}
        nrgrids=handles.model.delft3dwave.domain.nrgrids;
        handles.model.delft3dwave.domain.gridnames{nrgrids}=filename(1:end-4);
end

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end
ddb_wlgrid('write','FileName',filename,'X',x,'Y',y,'CoordinateSystem',coord);

handles.model.delft3dwave.domain.domains(nrgrids).coordsyst = coord;
handles.model.delft3dwave.domain.domains(nrgrids).grid=[attname '.grd'];
handles.model.delft3dwave.domain.domains(nrgrids).bedlevelgrid=[attname '.grd'];
handles.model.delft3dwave.domain.domains(nrgrids).gridname=attname;

handles.model.delft3dwave.domain.domains(nrgrids).gridx=x;
handles.model.delft3dwave.domain.domains(nrgrids).gridy=y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.delft3dwave.domain.domains(nrgrids).depth=nans;

handles.model.delft3dwave.domain.domains(nrgrids).mmax=size(x,1);
handles.model.delft3dwave.domain.domains(nrgrids).nmax=size(x,2);

% Plot new domain
handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);

% Refresh all domains
ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);
