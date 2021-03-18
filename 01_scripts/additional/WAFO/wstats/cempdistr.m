function [Fz1] = cempdistr(z,varargin) 
%CEMPDISTR Computes and plots the conditional empirical CDF 
%          of  X conditioned that  X>=c, F(x; X>=c),
%          and optionally compares it with distribution G.
%
%  CALL:  F = cempdistr(X,c,G,plotflag,sym);
%
%        F  = conditional empirical distribution of X, two column matrix.
%        X  = data vector.
%        c  = value to be conditioned on (default c = min(z,0)).
%        G  = cdf, two column matrix (optional).
%  plotflag = 0  no plotting
%             1 plot cdf F(x|X>=c) (default)
%             2 plot 1-F(x|X>=c) on a semilog y-scale
%             3 plot 1-F(x|X>=c) on a log log scale
%       sym = {s1,s2} cell array or comma separated list of plot 
%             symbols for F and G, respectively.
%             (default {'b','r--'})
% 
% NOTE:  SYM can be given anywhere after X
% 
% Example:
%   x=linspace(0,6,200)';
%   R = wraylrnd(2,100,1);
%   cempdistr(R,1,[x,wraylcdf(x,2)],'g','b')
%
% See also  cumtrapz, empdistr

% Tested on: Matlab 5.3, 5.2, 5.1
% History:
% revised PJ 01-Apr-2001: updated help text
% revised pab 23.06.2000
% - added ih = ishold
% - added sym
% - added varargin
% revised ms 13.06.2000
% - pdf usage removed (can't distinguish between a cdf and an increasing pdf)
% - changed axis labelling in figures
% - changed to staircaseplot when plotflag=2,3
% - revised header info
% revised pab 08.06.2000
% - fixed normalization of f if c>min(z)
% revised pab 07.03.2000
% - enabled so that f may be empty while plotflag is given 
% modified by Per A. Brodtkorb 10.11.98
% to accept both pdf and cdf's. Also enabled new plotting features,
% plotting of  probability of exceedances on a semilogy paper .... 

error(nargchk(1,6,nargin))
ih = ishold;

% default values
%~~~~~~~~~~~~~~~
c        = floor(min(min(z),0));
plotflag = 1; 
F=[];
sym ={[],'r--'}; % default plot symbols for the empirical
                              %  theoretical pdf,respectively

P  = varargin;
Np = length(P);
if Np>0
  strix = zeros(1,Np);
  cellix = strix;
  for ix=1:Np, % finding symbol strings or cell array of symbol strings
    strix(ix)  = ischar(P{ix});
    cellix(ix) = iscell(P{ix});
  end
  k  = find(strix);
  k1 = find(cellix);
  if any(k)
    Nk = length(k);
    if Nk>2,  warning('More than 2 strings are not allowed'),    end
    iy = 1;
    for ix=k      
      sym{iy} = P{ix};
      iy=iy+1;
    end
    Np = Np-Nk;
    P  = {P{find(~strix)}}; % remove strings from input
  elseif any(k1) % cell array of strings
    tmp = P{k1};
    Nk = length(tmp);
    if Nk>2,  warning('More than 2 strings are not allowed'),    end
    iy = 1;
    for ix=1:min(Nk,2)
      if ~isempty(tmp{ix}) & ischar(tmp{ix}), sym{ix}=tmp{ix};end
    end
    Np = Np-1;
    P  = {P{find(~cellix)}}; % remove cell array of strings from input
  end
  if Np>0 & ~isempty(P{1}), c        = P{1};end
  if Np>1 & ~isempty(P{2}), F        = P{2};end
  if Np>2 & ~isempty(P{3}), plotflag = P{3};end
end

if isempty(sym{1}), 
  sym{1}='b-';
%  if plotflag == 1, sym{1} = 'b-'; else sym{1}='b.'; end
end



if  ~isempty(F)
    I = find(F(:,1)>=c);
    if isempty(I),  
      error('The cdf  must be defined for at least one value >=c.'), 
    end

    i = min(I);
    if i > 1 & c>-inf,% Normalize the CDF
      fc = F(i-1,2)+(F(i,2)-F(i-1,2))/(F(i,1)-F(i-1,1))*(c-F(i-1,1));
      F = [c F(I,1)' ; 0  ( F(I,2)'-fc)/(1-fc)]';%normalizing
    end
    
    %F(:,2) = F(:,2)/F(N,2);
  end  


z = sort(z);
I = find(z>=c);
if isempty(I),  
  error('No data points  z  with  z>=c.'), 
end

z = z(I);
N = length(z);

Fz = (0.5:N-0.5)'/N;
p  = [0.001 0.01 0.05 0.10 0.25 0.5 0.75 0.90 0.96  0.99  0.999];

if ~isempty(F),  
  k = find(F(:,2)<1); 
end

switch plotflag,
  case 0, %do nothing
  case 1, % CDF plot
    stairs(z,Fz,sym{1})
    if c~=-inf,
      axis([floor(c) ceil(max(z)) 0 1])
      ylabel(['F(X| X>=' num2str(c) ')'])
    else
      ylabel('F(x)')
    end
    title('CDF')
    xlabel('x')
    if ~isempty(F), 
      hold on, plot(F(:,1),F(:,2),sym{2}),    
    end
    tick=p;
  case 2, % SEMILOGY
    [xtmp,ytmp]=stairs(z,1-Fz);
    semilogy(xtmp,ytmp,sym{1})
    if ~isempty(F), 
      hold on, semilogy(F(k,1),1-F(k,2),sym{2}),    
    end
    title('The probability of X exceeding x')
    if c~=-inf,
      ylabel(['1-F(x| X>=' num2str(c) ')'])
    else
      ylabel('1-F(x)')
    end
    xlabel('x')
     %axis([floor(c) ceil(max(z)) 0.4/N 1])
     %axis('square') 
     tick  = 1-p;
   case 3,% LOGLOG
     [xtmp,ytmp]=stairs(z,-log(1-Fz));
     loglog(xtmp,ytmp,sym{1});
     if ~isempty(F), 
       hold on, loglog(F(k,1),-log(1-F(k,2)),sym{2}),    
     end
     title('The probability of X exceeding x')
     if c~=-inf
       ylabel(['-log(1-F(x| X>=' num2str(c) '))'])
     else
       ylabel('-log(1-F(x))')
     end
     xlabel('x')
     %tmp=min(0.4/N,0.001);
     %axis([floor(c) ceil(max(z)) tmp (1-tmp) ])
     %axis('square')
     tick  = -log(1-p);
   case 4, % SEMILOGX
     semilogx(z,log(-log(1-Fz)),sym{1})
     if ~isempty(F), hold on, semilogx(F(k,1),log(-log(1-F(k,2))),sym{2}),  end
     title('CDF')
     ylabel(['log(-log(1-F(X| X>=' num2str(c) ')))'])
     xlabel('X')
     %tmp=min(0.4/N,0.001);
     %axis([floor(min(log(z))) ceil(log(max(z))) log(-log(1-tmp)) log(-log(tmp)) ])
     % axis('square')
     tick  = log(-log(1-p));
     %set
   case 5, % LOGLOG
     loglog(z,1-Fz,sym{1})
     if ~isempty(F), hold on, loglog(F(k,1),(1-F(k,2)),sym{2}),  end
     title('CDF')
     ylabel(['1-F(X| X>=' num2str(c) ')'])
     xlabel('X')
    % tmp=min(0.4/N,0.001);
     %axis([floor(min(log(z))) ceil(log(max(z))) log(-log(1-tmp)) log(-log(tmp)) ])
     % axis('square')
     tick  = (1-p);
     %set
   case 6, % LOGLOG
     loglog(z,Fz,sym{1})
     if ~isempty(F), hold on, loglog(F(k,1),(F(k,2)),sym{2}),     end
     title('CDF')
     ylabel(['F(X| X>=' num2str(c) ')'])
     xlabel('X')
     %tmp=min(0.4/N,0.001);
     %axis([floor(min(log(z))) ceil(log(max(z))) log(-log(1-tmp)) log(-log(tmp)) ])
     % axis('square')
     tick  = p;
     %set
   case 7, % SEMILIGX
     semilogx(z,log(-log(1-Fz)),sym{1})
     if ~isempty(F), hold on, semilogx(F(k,1),log(1-log(F(k,2))),sym{2}),    end
     title('CDF')
     ylabel(['log(1-log(F(X| X>=' num2str(c) ')))'])
     xlabel('X')
     %tmp=min(0.4/N,0.001);
     %axis([floor(min(log(z))) ceil(log(max(z))) log(-log(1-tmp)) log(-log(tmp)) ])
     % axis('square')
     tick  = log(-log(1-p));
     set(gca,'YTick',tick,'YTickLabel',num2str(p(:)),'XScale','log');
     otherwise , error('Invalid plotflag')
end
   
if nargout>0
  Fz1 = [z(:) Fz];
end

%
if 0,
  ax=axis;hold on
  plot([ax(1) ax(2)],[tick; tick],'k:'); hold off
  for l=1:length(p)
    h1=figtext(1.01,tick(l),num2str(p(l)) ,'norm','data');
    set(h1,'FontSize',10,'FontAngle','Italic')
  end
  
  %axis([0 inf 0 inf])
  %grid on;
  
end

if ~ih, hold off,end
