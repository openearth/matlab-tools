function [meanSal,Time]=salavg(filename,m,n,k)
%2:11, 2:17, 1:10
n=max(min(n(:)),2):max(n(:));
m=max(min(m(:)),2):max(m(:));
N=[n(1)-1 n];
M=[m(1)-1 m];

TRIM=vs_use(filename,'quiet');
Params=vs_get(TRIM,'map-const','*','quiet');
X0=vs_get(TRIM,'map-const','XCOR',{N,M},'quiet');
Y0=vs_get(TRIM,'map-const','YCOR',{N,M},'quiet');

DnX=diff(X0); DnX=(DnX(:,1:end-1)+DnX(:,2:end))/2;
DnY=diff(Y0); DnY=(DnY(:,1:end-1)+DnY(:,2:end))/2;
DmX=diff(X0,1,2); DmX=(DmX(1:end-1,:)+DmX(2:end,:))/2;
DmY=diff(Y0,1,2); DmY=(DmY(1:end-1,:)+DmY(2:end,:))/2;
Area=abs(DnX.*DmY-DmX.*DnY);

ZB=-dps(TRIM);
ZB=ZB(n,m);

if nargin<4
   info=vs_disp('map-const','THICK');
   k=1:info.SizeDim;
end
th=vs_get(TRIM,'map-const','THICK',{k},'quiet');
thTot=sum(th);
NLayers=length(th);
th=repmat(reshape(th,[1 1 NLayers]),[length(n) length(m)]);
Area3D=repmat(Area,[1 1 NLayers]);

info=vs_disp(TRIM,'map-series',[]);
NTimes=info.SizeDim;
meanSal=repmat(NaN,1,NTimes);
Time=vs_let(TRIM,'map-info-series','ITMAPC','quiet');
T0=tdelft3d(Params.ITDATE(1),Params.ITDATE(2));
Time=T0+Time*Params.DT*Params.TUNIT/3600/24;
for t=1:NTimes
   fprintf('%i of %i\n',t,NTimes)

   ZW=vs_get(TRIM,'map-series',{t},'S1',{n,m},'quiet');
   H=ZW-ZB;
   TotVol=thTot*H.*Area; TotVol=sum(TotVol(:));
   
   dz=th.*repmat(H,[1 1 NLayers]);

   Sal=vs_get(TRIM,'map-series',{t},'R1',{n,m,k,1},'quiet');
   Sal=Sal.*dz.*Area3D;
   TotSal=sum(Sal(:));
   
   meanSal(t)=TotSal/TotVol;
end
