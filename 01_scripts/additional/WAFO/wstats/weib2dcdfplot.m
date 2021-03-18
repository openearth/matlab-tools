function weib2dcdfplot(V,H,varargin) 
%WEIB2DCDFPLOT Plot conditional empirical CDF of X1 given X2=x2
%               and optionally compares it with distribution defined
%               by the parameter vector phat.
%  
%  CALL: weib2dcdfplot(x1,x2,phat,res,plotflag,figdata,sym);
% 
%       x1,x2 = data
%       phat  = [A1 B1 A2 B2 C12] parameter vector
%       res   = resolution (default range(x2)/12)
%    plotflag = 0  no plotting
%               1 plot cdf F(x1|x2)                  (default)
%               2 plot 1-F(x1|x2) on a semilog y-scale 
%               3 plot F(x1|x2) on a log log scale
%     figdata = [rows cols Nfig], gives number of rows, columns of which
%               each figure is divided into and and the total number of figures.
%               (default [3 3 1])
%         sym = {s1,s2} cell array of plot symbols for 
%               plotting empirical and theoretical cdf, respectively.
%               (default {'b.','r--'})
%  
%  WEIB2DCDFPLOT plots the  empirical CDF of X1 given X2 or 
%  X2 given X1 and compares it a 2D Weibull distribution with parameters
%  given by phat.
% 
% NOTE:  SYM can be given anywhere after X1 and X2
% 
% Example:
%  phat = [2 2 2 3 .9];
%  [R1 R2]= weib2drnd(phat,1000,1); 
%  weib2dcdfplot(R1,R2,phat,[],2,[3 3 1],{'k-','g-'});
%
%  See also  weib2dcdf, empdistr


%  tested on: matlab 5.2
% history
% by pab 25.10.2000





% default values
%~~~~~~~~~~~~~~~
sym = {[],[]}; % default plot symbols for the empirical
                              %  theoretical pdf,respectively
phat =[];
res    = [];
condon = 2;
flag   = 1;
row=3;col=3;Nfig=1;
figdata = [];
ih = ishold; % save hold state



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
  if Np>0 & ~isempty(P{1}), phat   = P{1};end
  if Np>1 & ~isempty(P{2}), res    = P{2};end
  if Np>2 & ~isempty(P{3}), flag    = P{3};end
  if Np>3 & ~isempty(P{4}), figdata = P{4};end
end

if isempty(res)
  if condon==1,
    res=range(V(:))/12;
  else
    res=range(H(:))/12;
  end
end

if flag<1,  return,end

nf=length(figdata);
if (nf>0) 
  if ~isnan(figdata(1)),         row  = figdata(1);end
  if (nf>1) & ~isnan(figdata(2)),col  = figdata(2);end
  if (nf>2) & ~isnan(figdata(3)),Nfig = figdata(3);end
end

Nmesh=40;
v1=[];cdfgH=[];
if condon==2,
  
  Xc      = V;
  grp     = floor(H/res)+1; % dividing the data into groups 
  Ngrp    = max(grp);
  h1      = linspace(res/2, (Ngrp-0.5)*res, Ngrp)';
  if ~isempty(phat)
    v1      =linspace(eps,max(V)+range(V)/4,Nmesh);
    [X1,X2] = meshgrid(v1,h1);
    cdfgH   = weib2dcdf(X1,X2,phat,condon);
  end
  %max(cdfgH')
  %min(cdfgH')
  xmax    = max(V);
 
else
  Xc      = H;
  grp     = floor(V/res)+1; % dividing the data into groups 
   Ngrp    = max(grp);
  h1      = linspace(res/2, (Ngrp-0.5)*res, Ngrp)';
  if ~isempty(phat)
    v1      = linspace(eps,max(H)+range(H)/4,Nmesh);
    [X1,X2] = meshgrid(v1,h1);
    cdfgH   = weib2dcdf(X2,X1,phat,condon);
  end
  xmax    = max(H);
end


%xmax=min(xmax,4);

fignr    = gcf;
fignrold = fignr;
%figure(fignr)

iy=0;
for ix=Ngrp:-1:min(grp),
  if iy==row*col,iy=0; 
    fignr=fignr+1;
    if Nfig<=fignr-fignrold, break, end
    figure(fignr);
  end
  tmp = Xc(grp==ix);%find data in group number ix
  if length(tmp)>max(3,0),% if less than 6 observations in the group 
    iy=iy+1;
    subplot(row,col,iy)
    if ih, hold on, end % make sure we have hold on for each subplot
    if ~isempty(phat)
      cempdistr(tmp,0,[v1; cdfgH(ix,:)]',flag,sym)
    else
      cempdistr(tmp,0,[],flag,sym)
    end
    %grid on
    
    axis square
    Ns = 2;
    switch  flag,
      case 1,
	ylabel(['F(x1|x2=' num2str(h1(ix),Ns) ')'])
	xlabel('x1')
	title('')
	axis([0 ceil(xmax) 0 1])
	% title(['Cumulative density function v given h=' num2str(h1(ix),3) ])
      case 2,
	%figtext(0.1,0.1,['1-F(v| h=' num2str(h1(ix),Ns)  ')'],'norm');
	ylabel(['1-F(x1|x2=' num2str(h1(ix),Ns)  ')'])
	xlabel('x1')
	grid off
	title('')
	axis([0 ceil(xmax) 1e-4 1])
	%  title(['The probability of exceeding v given h=' num2str(h1(ix),3)  ])
      case 3 ,
	ylabel(['-log(-log(F(x1|x2=' num2str(h1(ix),Ns)  ')))'])
	xlabel('x1')
	title('')
      case 4,
	ylabel(['(-log(F(x1|x2=' num2str(h1(ix),Ns)  ')))'])
	xlabel('x1')
	title('')
	%  title(['T
    end
    
    %if printflag, print -Pmhlaser ; end   %print -Pmhlaser
  end
end

if ~ih, hold off, end
