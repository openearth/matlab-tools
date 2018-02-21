function sfincs_binary_output_to_mat(matfile,inpfile,tref)

[folder,name,ext] = fileparts(inpfile);
if ~isempty(folder)
    folder=[folder filesep];
end

inp=sfincs_initialize_input;
inp=sfincs_read_input(inpfile,inp);

tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');

[xg,yg]=meshgrid(0:inp.dx:(inp.mmax-1)*inp.dx,0:inp.dy:(inp.nmax-1)*inp.dy);
rot=inp.rotation*pi/180;
x=inp.x0+cos(rot)*xg-sin(rot)*yg;
y=inp.y0+sin(rot)*xg+cos(rot)*yg;

% Read index file
fid=fopen([folder inp.indexfile],'r');
np=fread(fid,1,'integer*4');
indices=fread(fid,np,'integer*4');
fclose(fid);

% Read depth file
fid=fopen([folder inp.depfile],'r');
zbv=fread(fid,np,'real*4');
fclose(fid);
zb=zeros(size(x));
zb(zb==0)=NaN;
zb(indices)=zbv;

% Read data file
it=0;
fid=fopen([folder inp.zsfile],'r');
while 1
    idummy=fread(fid,1,'integer*4');
    if isempty(idummy)
        break
    end
    it=it+1;
    zsv=fread(fid,np,'real*4');
    idummy=fread(fid,1,'integer*4');
    zs0=zeros(size(x));
    zs0(zs0==0)=NaN;
    zs0(indices)=zsv;
%    zs0(zs0-zb<0.05)=NaN;
    val(it,:,:)=zs0;
    t(it)=(it-1)*inp.dtout;
end
fclose(fid);

if exist([folder 'cumprcp.dat'],'file')
    % Read data file
    it=0;
    fid=fopen([folder 'cumprcp.dat'],'r');
    while 1
        idummy=fread(fid,1,'integer*4');
        if isempty(idummy)
            break
        end
        it=it+1;
        zsv=fread(fid,np,'real*4');
        idummy=fread(fid,1,'integer*4');
        zs0=zeros(size(x));
        zs0(zs0==0)=NaN;
        zs0(indices)=zsv;
        %    zs0(zs0-zb<0.05)=NaN;
        cumprcp(it,:,:)=zs0;
    end
    fclose(fid);
end

if ~isempty(inp.hmaxfile)
    % Read Hmax file
    fid=fopen([folder inp.hmaxfile],'r');
    idummy=fread(fid,1,'integer*4');
    hmaxv=fread(fid,np,'real*4');
    idummy=fread(fid,1,'integer*4');
    fclose(fid);
    hmax=zeros(size(x));
    hmax(hmax==0)=NaN;
    hmax(indices)=hmaxv;
end

if ~isempty(inp.vmaxfile)
    % Read vmax file
    fid=fopen([folder inp.vmaxfile],'r');
    idummy=fread(fid,1,'integer*4');
    vmaxv=fread(fid,np,'real*4');
    idummy=fread(fid,1,'integer*4');
    fclose(fid);
    vmax=zeros(size(x));
    vmax(vmax==0)=NaN;
    vmax(indices)=vmaxv;
end

n=0;

n=n+1;
s.parameters(n).parameter.name='water level';
s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=val;
s.parameters(n).parameter.size=[it 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

if ~isempty(inp.hmaxfile)
    n=n+1;
    s.parameters(n).parameter.name='maximum water depth';
    s.parameters(n).parameter.x=x;
    s.parameters(n).parameter.y=y;
    s.parameters(n).parameter.val=hmax;
    s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
    s.parameters(n).parameter.quantity='scalar';
end

if ~isempty(inp.vmaxfile)
    n=n+1;
    s.parameters(n).parameter.name='maximum current velocity';
    s.parameters(n).parameter.x=x;
    s.parameters(n).parameter.y=y;
    s.parameters(n).parameter.val=vmax;
    s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
    s.parameters(n).parameter.quantity='scalar';
end

if exist([folder 'cumprcp.dat'],'file')
    n=n+1;
    s.parameters(n).parameter.name='cumulative precipitation';
    s.parameters(n).parameter.time=tstart+t/86400;
    s.parameters(n).parameter.x=x;
    s.parameters(n).parameter.y=y;
    s.parameters(n).parameter.val=cumprcp;
    s.parameters(n).parameter.size=[it 0 size(x,1) size(x,2) 0];
    s.parameters(n).parameter.quantity='scalar';
end

n=n+1;
s.parameters(n).parameter.name='bed level';
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=zb;
s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

save(matfile,'-struct','s');
