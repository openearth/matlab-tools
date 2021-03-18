function dist2dparamplot(PV1,sPV1,plotflag),
%DIST2DPARAMPLOT Plot parameters of the conditional distribution
%
% CALL:  dist2dparamplot(PV,sPV,plotflag)
%
%       PV  = empirical parameters (structure array)
%       sPV = smoothed parameters  (structure array)
%  plotflag = 0 no plotting
%             1 Only parameter A is plotted
%             2 Only parameter B is plotted
%             3 Only parameter C is plotted
%             4 all  parameters are plotted in the same figure (default)
%
% Example: 
%   R = wraylrnd(2,1000,2); x1 = linspace(0,10)';
%   phat = dist2dfit(R(:,1),R(:,2),{'rayl','rayl'}); 
%   sphat = dist2dsmfun2(phat,x1,0); % smooth the parameters
%   dist2dparamplot(phat,sphat); 
%
% See also  dist2dfit, dist2dsmfun2

% history
% revised pab 19.01.2001
% - phat.CI may now be empty
% - better scaling of plots
% revised pab 12.11.2000
% - added  the possibility that phat is an array of structs
% revised pab 06.02.2000
% - added plotflag
% - simplified plotting
% by pab 




if nargin<3|isempty(plotflag)
  plotflag=4;
elseif plotflag<1
  return
end
Npv = prod(size(PV1));
ih=ishold;
if isstruct(PV1) & Npv>1
  cfig=gcf;
  for ix=1:Npv,
    if ih
      newplot
    else
      figure(cfig-1+ix)
    end
    if nargin<2|isempty(sPV1)
      dist2dparamplot(PV1(ix),[],plotflag)
    else
      dist2dparamplot(PV1(ix),sPV1(ix),plotflag)
    end
  end
  return
end


if nargin<2|isempty(sPV1)
  sPV=[];
elseif isstruct(sPV1)
  sPV=sPV1.x{1};
else
  sPV=sPV1;
end

dist=lower(PV1.dist{1});
if isfield(PV1,'CI') & ~isempty(PV1.CI);
  pvCI=PV1.CI{1};
  indCI=find(~isnan(pvCI(:,1)));
  isCI=any( pvCI(indCI,1:2:end));
  isCI=[isCI zeros(1,3-length(isCI))];
else
  isCI=zeros(1,3);
end
txtCI=' and 95 % CI';

pv=PV1.x{1};
np=size(pv,2)-1;

ind=find(~isnan(pv(:,1)));
  
Arange=[0 inf 0 inf];Brange=[0 inf -inf inf];Crange=[0 inf -inf inf];
switch lower(dist(1:2)),
  case {'tg','gu'},  txt='Gumbel';  
  case 'lo', txt='Lognormal';Arange=[0 inf -inf  inf];Brange=[0 inf 0 inf];
  case 'ga', txt='Gamma';Brange=[0 inf 0  inf];
  case 'gg', txt='Generalized Gamma';Brange=Arange;Crange = Arange; 
  case 'we', txt='Weibull';Brange=[0 inf 0 inf];
  otherwise, txt=[];
end
Arange(4)= min(max(pv(ind,2)),20);
if np>1, Brange(4)=min(max(pv(ind,3)),20);
 if np>2,  Crange(4)=min(max(pv(ind,4)),5);end
end

     
 
paramtxt='ABC';
if strcmpi(dist(1:2),'ra'),  % rayleigh distribution
  paramtxt(2)=[]; % No shape parameter
  Prange={Arange, Crange};
else
  Prange={Arange, Brange, Crange};
end
if plotflag>np, 
  nplots=1:np;
else
  nplots=plotflag;np=1;
end

for ix=nplots,
 
  subplot(np,1,ix-nplots(1)+1)
  if ih , hold on, end
  plot(pv(ind,1),pv(ind,ix+1),'bo'), hold on
  if isCI(ix)
    plot(pv(indCI,1),pvCI(indCI,2*ix-1:2*ix),'r--')
    title([txt ' parameter ' paramtxt(ix) txtCI])
  else
    title([txt ' parameter ' paramtxt(ix)])
  end
  
  if ~isempty(sPV),
    plot(sPV(:,1),sPV(:,ix+1),'b-')
  end
  if ~ih, hold off, end
  axis(Prange{ix})
  xlabel('x2')
  ylabel([paramtxt(ix) '(x2)'])
end
return
