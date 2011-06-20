function DataProperties=ImportXBeach(DataProperties,nr)

% fid=fopen(DataProperties(nr).DefFile,'r');
% nt=fread(fid,[1],'double');
% nx=fread(fid,[1],'double');
% ny=fread(fid,[1],'double');
% fclose(fid);
% 
% fixy=fopen(DataProperties(nr).XYFile,'r');
% xg=fread(fixy,[nx+1,ny+1],'double');
% yg=fread(fixy,[nx+1,ny+1],'double');
% fclose(fixy);
% 
%xg=xg(1:end-1,1:end-1);
%yg=yg(1:end-1,1:end-1);
% xg=xg(2:end,2:end);
% yg=yg(2:end,2:end);

def=load(DataProperties(nr).DefFile);
Size(1)=def(9);
Size(2)=0;
Size(3)=def(6);
Size(4)=def(7);
Size(5)=0;

x0=def(1);
y0=def(2);
rot=def(3);
dx=def(4);
dy=def(5);
nx=def(6);
ny=def(7);
dt=def(8);
nt=def(9);
refdat=def(10);
reftim=def(11);

dt=dt*60;

Dims=[1 0 1 1 0];

%[xg,yg]=meshgrid(x0:dx:x0+(nx-1)*dx,y0:dy:y0+(ny-1)*dy);
%[xg,yg]=meshgrid(x0:dx:x0+(nx)*dx,y0:dy:y0+(ny)*dy);
[xg0,yg0]=meshgrid(0:dx:nx*dx,0:dy:ny*dy);
xg0=xg0';
yg0=yg0';

xg0=load([DataProperties(nr).PathName 'x.grd']);
yg0=load([DataProperties(nr).PathName 'y.grd']);
xg0=xg0';
yg0=yg0';

rot=pi*rot/180;
r=[cos(rot) -sin(rot) ; sin(rot) cos(rot)];

for i=1:size(xg0,1)
    for j=1:size(xg0,2)
        v0=[xg0(i,j) yg0(i,j)]';
        v=r*v0;
        xg(i,j)=v(1);
        yg(i,j)=v(2);
    end
end

xg=xg+x0;
yg=yg+y0;

Size(1)=nt;
Size(2)=0;
Size(3)=nx;
Size(4)=ny;
Size(5)=0;


%dt=1.0;


fname=[DataProperties(nr).PathName DataProperties(nr).FileName];
fid=fopen(fname,'r');
Data=zeros(nt,nx+1,ny+1);

%Data=zeros(nt,nx,ny);
for k=1:nt
    dat=fread(fid,[nx+1,ny+1],'double');
%    dat=fread(fid,[nx,ny],'double');
    sz1=size(dat);
    sz2=size(Data);
    Data(k,:,:)=dat;
end
fclose(fid);

TRef=datenum('01-Jan-2000');

TRef=MatTime(refdat,reftim);
format long

for i=1:nt
    Times(i)=TRef+(i-1)*dt/86400;
    Times(i)=1e-6*ceil(Times(i)*1e6);
end

DateTime=datestr(DataProperties(nr).DateTime);

DateTime=DataProperties(nr).DateTime;
DateTime=1e-6*ceil(DateTime*1e6);

if DataProperties(nr).DateTime>0
    ITime=find(Times==DateTime);
else
    ITime=0;
end

if DataProperties(nr).Block>0
    ITime=DataProperties(nr).Block;
end

if isfield(DataProperties(nr),'DefFile')
    DataProps(nr).UseGrid=1;
end

if DataProperties(nr).M1==0
    M1=1;
    M2=Size(3);
else
    M1=DataProperties(nr).M1;
    M2=DataProperties(nr).M2;
end

if DataProperties(nr).N1==0
    N1=1;
    N2=Size(4);
else
    N1=DataProperties(nr).N1;
    N2=DataProperties(nr).N2;
end

if DataProperties(nr).K1==0 && Size(5)>0
    K1=1;
    K2=Size(5);
else
    K1=DataProperties(nr).K1;
    K2=DataProperties(nr).K2;
end

% NrArg=0;
% 
% if SedNr>0
%     NrArg=NrArg+1;
%     Arg{NrArg}=SedNr;
% end
% 
% switch FileInfo.SubType,
%     case{'Delft3D-trim','Delft3D-com','Delft3D-hwgxy','Delft3D-waq-map'}
%         if Dims(1)>0
%             NrArg=NrArg+1;Arg{NrArg}=ITime;
%         end
%         NrArg=NrArg+1;Arg{NrArg}=M1:M2;
%         NrArg=NrArg+1;Arg{NrArg}=N1:N2;
%         if Dims(5)>0
%             NrArg=NrArg+1;Arg{NrArg}=K1:K2;
%         end
%     case{'Delft3D-trih','Delft3D-waq-history'}
%         NrArg=NrArg+1;Arg{NrArg}=ITime;
%         NrArg=NrArg+1;Arg{NrArg}=NrStation;
%         if Dims(5)>0
%             NrArg=NrArg+1;Arg{NrArg}=K1:K2;
%         end
% end
% 
% switch NrArg,
%     case{1}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1});
%     case{2}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1},Arg{2});
%     case{3}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1},Arg{2},Arg{3});
%     case{4}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1},Arg{2},Arg{3},Arg{4});
%     case{5}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1},Arg{2},Arg{3},Arg{4},Arg{5});
%     case{6}
%         Data=qpread(FileInfo,DataProperties(nr).Parameter,'griddata',Arg{1},Arg{2},Arg{3},Arg{4},Arg{5},Arg{6});
% end
% 
% if isfield(Data,'Val')
%     Val=Data.Val;
% else
%     if NVal(NrParameter)>1
%         switch lower(DataProperties(nr).Component),
%             case('magnitude')
%                 Val=sqrt(Data.XComp.^2+Data.YComp.^2);
%             case('angle (radians)')
%                 Val=mod(0.5*pi-atan2(Data.YComp,Data.XComp),2*pi);
%             case('angle (degrees)')
%                 Val=mod(90-atan2(Data.YComp,Data.XComp),2*pi)*180/pi;
%             case('m-component')
%                 Val=Data.XComp;
%             case('n-component')
%                 Val=Data.YComp;
%             case('u-component')
%                 Val=Data.XComp;
%             case('v-component')
%                 Val=Data.YComp;
%         end
%     end
% end
% 

size(Data);
ITime;
bbb=Data(ITime,:,:);

x=0;
y=0;
z=0;
if DataProperties(nr).DateTime==0
    DataProperties(nr).Type='TimeSeries';
    x=Times;
    y=Data(:,M1,N1);
else
    if M2>M1 && N2>N1
        % 2D
        DataProperties(nr).Type='2DScalar';
        x=xg;
        y=yg;
        z=squeeze(Data(ITime,:,:));
    elseif ((M2>M1 && N2==N1) || (M2==M1 && N2>N1))
        % CrossSection
        DataProperties(nr).Type='XYSeries';

        switch(lower(DataProperties(nr).XCoordinate)),
            case{'x'}
                x=squeeze(xg(M1:M2,N1:N2));
            case{'y'}
                x=squeeze(yg(M1:M2,N1:N2));
            case{'pathdistance'}
                x=pathdistance(squeeze(xg(M1:M2,N1:N2)),squeeze(yg(M1:M2,N1:N2)));
            case{'revpathdistance'}
                x=pathdistance(squeeze(xg(M1:M2,N1:N2)),squeeze(yg(M1:M2,N1:N2)));
                x=x(end:-1:1);
        end                
%        x=pathdistance(squeeze(xg(M1:M2,N1:N2)),squeeze(yg(M1:M2,N1:N2)));
        y=squeeze(Data(ITime,M1:M2,N1:N2));
    end
end

DataProperties(nr).x=squeeze(x);
DataProperties(nr).y=squeeze(y);
DataProperties(nr).z=squeeze(z);
DataProperties(nr).zz=squeeze(z);

if DataProperties(nr).DateTime==0 || Size(1)<2
    DataProperties(nr).TC='c';
else
    DataProperties(nr).TC='t';
    DataProperties(nr).AvailableTimes=Times;
    DataProperties(nr).AvailableMorphTimes=Times;
end    

clear x y z Data Times
