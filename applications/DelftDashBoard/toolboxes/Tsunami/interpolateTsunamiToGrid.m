function interpolateTsunamiToGrid(varargin)

% Defaults
OPT.kmax=1;
OPT.gridcs.name='WGS 84';
OPT.gridcs.type='geographic';
OPT.tsunamics.name='WGS 84';
OPT.tsunamics.type='geographic';

OPT.inifile=[];

OPT.xgrid=[];
OPT.ygrid=[];
OPT.grdfile=[];

OPT.xtsunami=[];
OPT.ytsunami=[];
OPT.ztsunami=[];
OPT.tsunamifile=[];

OPT = setproperty(OPT,varargin{:});

% Ini file
if isempty(OPT.inifile)
    error('No initial conditions file specified!');
end

% Grid
if ~isempty(OPT.grdfile)
    % Read grid file
    [x,y,enc,cs,nodatavalue]=wlgrid('read',OPT.grdfile);
    [xz,yz] = getXZYZ(x,y);
elseif ~isempty(OPT.xgrid)
    xz=OPT.xgrid;
    yz=OPT.ygrid;
else
    error('No grid coordinates specified!');
end

% Tsunami
if ~isempty(OPT.tsunamifile)
    % Read tsunami asc file
    [xx yy zz info] = arc_asc_read(OPT.tsunamifile);
elseif ~isempty(OPT.xtsunami)
    xx=OPT.xtsunami;
    yy=OPT.ytsunami;
    zz=OPT.ztsunami;
else
    error('No tsunami data specified!');
end

mmax=size(xz,1);
nmax=size(xz,2);

% Convert grid to coordinate system of tsunami data
if ~strcmpi(OPT.gridcs.name,OPT.tsunamics.name)
    [xz,yz]=ddb_coordConvert(xz,yz,OPT.gridcs,OPT.tsunamics);
end

zz(isnan(zz))=0;
xz(isnan(xz))=0;
yz(isnan(yz))=0;
iniwl0=interp2(xx,yy,zz,xz,yz);

iniwl0=reshape(iniwl0,mmax,nmax);

u=zeros(mmax+1,nmax+1);
iniwl=u;

iniwl(1:end-1,1:end-1)=iniwl0;
iniwl(isnan(iniwl))=0;

if exist(OPT.inifile,'file')
    delete(OPT.inifile);
end
ddb_wldep('append',OPT.inifile,iniwl,'negate','n','bndopt','n');
for k=1:OPT.kmax
    ddb_wldep('append',OPT.inifile,u,'negate','n','bndopt','n');
    ddb_wldep('append',OPT.inifile,u,'negate','n','bndopt','n');
end
