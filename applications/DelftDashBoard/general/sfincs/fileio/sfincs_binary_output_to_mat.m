function sfincs_binary_output_to_mat(matfile,inpfile,tref,version)

[folder,name,ext] = fileparts(inpfile);
if ~isempty(folder)
    folder=[folder filesep];
end

inp=sfincs_initialize_input;
inp=sfincs_read_input(inpfile,inp);

[xg,yg]=meshgrid(0:inp.dx:(inp.mmax)*inp.dx,0:inp.dy:(inp.nmax)*inp.dy);
tstart=datenum(inp.tstart,'yyyymmdd HHMMSS');
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

zb=zeros(inp.nmax,inp.mmax);
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
    zs0=zeros(inp.nmax,inp.mmax);
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
        zs0=zeros(inp.nmax,inp.mmax);
        zs0(zs0==0)=NaN;
        zs0(indices)=zsv;
        %    zs0(zs0-zb<0.05)=NaN;
        cumprcp(it,:,:)=zs0;
    end
    fclose(fid);
end


% Read Hmax file
fid=fopen([folder inp.hmaxfile],'r');
idummy=fread(fid,1,'integer*4');
hmaxv=fread(fid,np,'real*4');
idummy=fread(fid,1,'integer*4');
fclose(fid);
hmax=zeros(inp.nmax,inp.mmax);
hmax(hmax==0)=NaN;
hmax(indices)=hmaxv;


% Read vmaxfile
inp.vmaxfile = 'vmax.dat';
inp.vmaxgeofile = 'vmaxgeo.dat';

fid=fopen([folder inp.vmaxfile],'r');
idummy=fread(fid,1,'integer*4');
vmaxv=fread(fid,np,'real*4');
idummy=fread(fid,1,'integer*4');
fclose(fid);
vmax=zeros(inp.nmax,inp.mmax);
vmax(vmax==0)=NaN;
vmax(indices)=vmaxv;

% % Read vmaxgeo file
% fid=fopen([folder vmaxgeo.dat],'r');
% idummy=fread(fid,1,'integer*4');
% vmaxv=fread(fid,np,'real*4');
% idummy=fread(fid,1,'integer*4');
% fclose(fid);
% vmax=zeros(size(x));
% vmax(vmax==0)=NaN;
% vmax(indices)=vmaxv;

% % Data file
% fid=fopen(datafile,'r');
% fread(fid,1,'int64'); % dummy line
% zv=fread(fid,np,'real*4');
% fclose(fid);


valout=zeros(size(val,1),inp.nmax+1,inp.mmax+1);
zbout=zeros(inp.nmax+1,inp.mmax+1);
valout(valout==0)=NaN;
zbout(zbout==0)=NaN;
hmaxout=zbout;
vmaxout=zbout;
cumprcpout=valout;


n=0;

valout(:,1:end-1,1:end-1)=val;
n=n+1;
s.parameters(n).parameter.name='water level';

s.parameters(n).parameter.time=tstart+t/86400;
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=valout;
s.parameters(n).parameter.size=[it 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';


hmaxout(1:end-1,1:end-1)=hmax;
n=n+1;
s.parameters(n).parameter.name='maximum water depth';
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=hmaxout;
s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

zbout(1:end-1,1:end-1)=zb;
n=n+1;
s.parameters(n).parameter.name='bed level';
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=zbout;
s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';

% if exist([folder 'vmaxgeo.dat'],'file')
vmaxout(1:end-1,1:end-1)=vmax;
n=n+1;
s.parameters(n).parameter.name='maximum current velocity';
s.parameters(n).parameter.x=x;
s.parameters(n).parameter.y=y;
s.parameters(n).parameter.val=vmaxout;
s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
s.parameters(n).parameter.quantity='scalar';
% end

% if ~isempty(inp.vmaxgeofile)
%     n=n+1;
%     s.parameters(n).parameter.name='maximum current velocity';
%     s.parameters(n).parameter.x=x;
%     s.parameters(n).parameter.y=y;
%     s.parameters(n).parameter.val=vmax;
%     s.parameters(n).parameter.size=[0 0 size(x,1) size(x,2) 0];
%     s.parameters(n).parameter.quantity='scalar';
% end

if exist([folder 'cumprcp.dat'],'file')
    cumprcpout(:,1:end-1,1:end-1)=cumprcp;
    n=n+1;
    s.parameters(n).parameter.name='cumulative precipitation';
    s.parameters(n).parameter.time=tstart+t/86400;
    s.parameters(n).parameter.x=x;
    s.parameters(n).parameter.y=y;
    s.parameters(n).parameter.val=cumprcpout;
    s.parameters(n).parameter.size=[it 0 size(x,1) size(x,2) 0];
    s.parameters(n).parameter.quantity='scalar';
end

if version == 7.3
	save(matfile,'-struct','s','-v7.3'); %For variables larger than 2GB use MAT-file version 7.3 or later. 
else
	save(matfile,'-struct','s');
end
