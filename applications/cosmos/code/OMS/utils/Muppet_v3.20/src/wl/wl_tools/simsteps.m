function [OutTxt,OutFig]=simsteps(C,i)
%SIMSTEPS Performs an timestep analysis
%     SIMSTEPS(NfsTrimFile,i)
%     analyses the i-th dataset written to the
%     Delft3D FLOW file. It returns information on
%     maximum allowed timestep and the used timestep.
%     By default the last dataset written is used.

Txt={};
if nargin==0
  C=vs_use;
end

switch lower(vs_type(C))
case 'delft3d-trim'
  T=C;
  C=vs_use(strrep(C.FileName,'trim-','com-'),'quiet');
  vs_use(T)
case 'delft3d-com'
  T=vs_use(strrep(C.FileName,'com-','trim-'),'quiet');
  vs_use(C)
end
if nargin<2,
  if isstruct(T)
    Info=vs_disp(T,'map-series',[]);
    i=Info.SizeDim;
  else
    Info=vs_disp(C,'CURTIM',[]);
    i=Info.SizeDim;
  end
end
if isstruct(T)
  ms=vs_get(T,'map-series',{i},'*','nowarn','quiet');
else
  ms=vs_get(C,'CURTIM',{i},'*','nowarn','quiet');
end
ms.U1=max(ms.U1,[],3);
ms.V1=max(ms.V1,[],3);
magU=sqrt(ms.U1.^2+ms.V1.^2);
magU(magU==0)=eps;

if isstruct(T)
  mc=vs_get(T,'map-const','*','quiet');
  mmc=mc;
else
  mc=vs_get(C,'GRID','*','quiet');
  mmc=vs_get(C,'KENMCNST','*','quiet');
end
X=mc.XCOR;
Y=mc.YCOR;
if isstruct(T)
  DP0=mc.DP0;
else
  Info=vs_disp(C,'BOTTIM',[]);
  DP0=vs_get(C,'BOTTIM',{Info.SizeDim},'DP','quiet');
end
DPZ=corner2center(DP0,'same');
H=ms.S1+DPZ;

distU=[];
distU(2:size(X,1),:)=sqrt(diff(X).^2+diff(Y).^2);
distV=[];
distV(:,2:size(X,2))=sqrt(diff(X,1,2).^2+diff(Y,1,2).^2);

distU=distU.*mmc.KCU;
distU=distU+setnan(~mmc.KCU);
distV=distV.*mmc.KCV;
distV=distV+setnan(~mmc.KCV);

dist=min(distU,distV);
isqdist=sqrt(distU.^(-2)+distV.^(-2));

if isfield(ms,'VICUV') & ~isempty(ms.VICUV) & ~isequal(size(ms.VICUV),[1 1])
  VICUV=ms.VICUV(:,:,end);
  VICUV(VICUV==0)=NaN;
  Dt1=1./(2*VICUV.*(isqdist.^2));
  dt1=min(Dt1(:));
  Txt{end+1}=sprintf('The maximum allowed timestep based on Reynolds stresses is %f seconds.',dt1);
  Txt{end+1}=sprintf('Note: this timestep is based on a model-wide analysis although');
  Txt{end+1}=sprintf('the restriction holds only near walls with partial slip.');
  Txt{end+1}=sprintf('See section 10.5.2 of the Delft3D-FLOW manual.\n');
else
  Dt1=1./(2*(isqdist.^2));
  dt1=min(Dt1(:));
  Txt{end+1}=sprintf('The maximum allowed timestep based on Reynolds stresses cannot be determined.',dt1);
  Txt{end+1}=sprintf('Use as an estimate %f/[horizontal viscosity] seconds.',dt1);
  Txt{end+1}=sprintf('Note: this suggestion is based on a model-wide analysis although');
  Txt{end+1}=sprintf('the restriction holds only near walls with partial slip.');
  Txt{end+1}=sprintf('See section 10.5.2 of the Delft3D-FLOW manual.\n');
  dt1=[];
end

AG=9.83;
vK=0.41;
maxCFLwav=10;
Dt2=maxCFLwav./(2*sqrt(AG*max(eps,H)).*isqdist);
%Dt2=dist./(sqrt(AG*max(eps,H)));
dt2=min(Dt2(:));
Txt{end+1}=sprintf('The maximum allowed timestep for accurate computation of wave propagation');
Txt{end+1}=sprintf('is %f seconds based on a maximum Courant number for free surface',dt2);
Txt{end+1}=sprintf('waves of 10. See equation (10.4.1) en section 10.4.2 of the Delft3D-FLOW manual.\n');

Dt3=dist./magU;
dt3=min(Dt3(:));
Txt{end+1}=sprintf('The maximum allowed timestep for horizontal advection is %f seconds.',dt3);
Txt{end+1}=sprintf('See equation (10.5.6) of the Delft3D-FLOW manual.\n');

if isstruct(T)
  rsp=strmatch('Secondary flow',mc.NAMCON,'exact');
else
  rsp=1;
end
if ~isempty(rsp) & ~isempty(C),
  RGH=vs_get(C,'ROUGHNESS','*','quiet');
  rgh=RGH.ROUFLO;
  RGH=(RGH.CFUROU+RGH.CFVROU)/2;
  switch rgh,
  case 'WHIT'
    RGH(RGH<=0)=NaN;
    RGH=18*log10(12*H./RGH);
  case 'MANN'
    RGH(RGH<=0)=NaN;
    RGH=H.^(1/6)./RGH;
  case 'Z   '
    RGH(RGH<=0)=NaN;
    RGH=18*log10(12*H./(30*RGH));
  end
  if isstruct(T)
    RSP=ms.R1(:,:,1,rsp);
  else
    RSP=ms.RSP;
  end
  alpha=sqrt(AG)./(vK.*RGH);
  denom=2*RSP.*(5*alpha-15.6*alpha.^2+37.5*alpha.^3);
  denom(denom==0)=NaN;
  Dt4=dist./abs(denom);
  dt4=min(Dt4(:));
  Txt{end+1}=sprintf('The maximum allowed value of Betac * Dt for spiral flow is %f seconds.',dt4);
  Txt{end+1}=sprintf('See equation (10.5.5) of the Delft3D-FLOW manual.\n');
elseif ~isempty(rsp),
  Txt{end+1}=sprintf('The maximum allowed value of Betac * Dt for spiral flow');
  Txt{end+1}=sprintf('is not applicable or it cannot be determined.\n');
end;

if isstruct(T)
  dtused=mc.DT*mc.TUNIT;
else
  dtused=vs_get(C,'PARAMS','DT','quiet')*60;
end
Txt{end+1}=sprintf('The flow timestep used in the simulation equals %f seconds.',dtused);

if ~isempty(dt1)
  Dt=min(Dt1,Dt2); dt=min(dt1,dt2);
else
  Dt=Dt2; dt=dt2;
end
Dt=min(Dt,Dt3); dt=min(dt,dt3);

X(X==0 & Y==0)=NaN;
Y(isnan(X))=NaN;
Fig=figure('colormap',flipud(jet));
S=surf(X,Y,Dt); view(0,90); shading interp
title('Spatial variation of the maximum allowed timestep')
A=get(S,'parent');
set(A,'clim',[min(dt,dtused) min(4*dt,4*dtused)],'da',[1 1 1]);
C=colorbar('horz');
axes(C);
xlabel('seconds \rightarrow')
set(Fig,'renderer','zbuffer')

if nargout==0
   fprintf('%s\n',Txt{:})
else
   OutTxt=Txt;
   if nargout>1
      OutFig=Fig;
   end
end
