function underlayer(C,i,lyrthk,frac,cs),
%UNDERLAYER Graded sediment cross-section plot
%    UNDERLAYER(NFSStruct,TimeStep,LayerThickness, ...
%        SedFraction,CrossSection)
%
%    CrossSection equals for instance {3, 1:61}
%
%    Supports COM and TRAM files.
%    Requires: GRID, ZLEVUL, NRDZDL, DEFF, DZR, P0LA, PTRLA

%(c) 1999-2000, WL | Delft Hydraulics, The Netherlands
%Author: H.R.A. Jagers
%Date:   June 1999

%cs={3 , 1:61};
%cs={1:5, 15};
%cs={1, 1:116};
vshift=0; %0.0505;

switch vs_type(C),
case 'Delft3D-com'
  xgrid =vs_get(C,'GRID','XCOR','quiet');
  ygrid =vs_get(C,'GRID','YCOR','quiet');
  zlevul=vs_get(C,'GRASEDTIM','ZLEVUL','quiet');
  nrdzdl=vs_get(C,'GRASEDTIM','NRDZDL','quiet');
  deff  =vs_get(C,'GRASEDTIM','DEFF','quiet');
  dzr   =vs_get(C,'GRASEDTIM','DZR','quiet');
  p0la  =vs_get(C,'GRASEDTIM','P0LA','quiet');
  ptrla =vs_get(C,'GRASEDTIM','PTRLA','quiet');
%  INFO=vs_disp(C,'BOTTIM',[]);
%  dp=vs_get(C,'BOTTIM',{INFO.SizeDim},'DP','quiet');
case 'Delft3D-tram'
  xgrid =vs_get(C,'GRID','XCOR','quiet');
  ygrid =vs_get(C,'GRID','YCOR','quiet');
  zlevul=vs_get(C,'MAPTTRAG',{i},'ZLEVUL','quiet');
  nrdzdl=vs_get(C,'MAPTTRAG',{i},'NRDZDL','quiet');
  deff  =vs_get(C,'MAPTTRAG',{i},'DEFF','quiet');
  dzr   =vs_get(C,'MAPTTRAG',{i},'DZR','quiet');
  p0la  =vs_get(C,'MAPTTRAG',{i},'P0LA','quiet');
  ptrla =vs_get(C,'MAPTTRAG',{i},'PTRLA','quiet');
end
nlayer=size(p0la,4);

dzr=dzr(cs{:});
deff=deff(cs{:});
zlevul=zlevul(cs{:})+vshift;
nrdzdl=nrdzdl(cs{:});
xgrid=xgrid(cs{:});
ygrid=ygrid(cs{:});
ptrla=ptrla(cs{:},:);
p0la=p0la(cs{:},:,:);
if size(deff,2)==1,
  dzr=dzr';
  xgrid=xgrid';
  ygrid=ygrid';
  deff=deff';
  nrdzdl=nrdzdl';
  zlevul=zlevul';
  szptrla=size(ptrla);
  szptrla(1:2)=szptrla([2 1]);
  ptrla=reshape(ptrla,szptrla);
  szp0la=size(p0la);
  szp0la(1:2)=szp0la([2 1]);
  p0la=reshape(p0la,szp0la);
end;

dist=pathdistance(xgrid,ygrid);

fig=gcf;
hold off
L3=plot(dist,zlevul,'k');
hold on
X=ones(2*nlayer,1)*dist;
ind=[0:nlayer-1; 1:nlayer];
dY=ones(2*nlayer+2,size(dist,2))*lyrthk;
dY(1:2:(2*nlayer),:)=0;
dY(2*nrdzdl+(2*nlayer+2)*(0:(size(dist,2)-1)))=dzr;
dY(2*nrdzdl+1+(2*nlayer+2)*(0:(size(dist,2)-1)))=NaN;
dY(1,:)=zlevul;
Y=cumsum(dY(1:end-2,:),1);
ind=[1:nlayer; 1:nlayer];
C=transpose(squeeze(p0la(1,:,frac,ind(:))));
S2=surface(X,Y,zeros(2*nlayer,size(dist,2)),C,'facecolor','interp');
dp=max(Y)+deff;
L1=plot(dist,dp,'k');
L2=plot(dist,dp-deff,'r');
set(L2,'linewidth',2);
S1=surface([dist;dist],[dp;dp-deff],zeros(2,size(dist,2)),[ptrla(:,:,frac);ptrla(:,:,frac)],'facecolor','interp');
set(gca,'clim',[0 1])

if 1,
  set([S1 S2],'edgecolor','none');
  set(L2,'color','k','linewidth',0.5);
end;
