function [ax11, h11, h22  ]=weib2dstatplot(V,H,phat,res,varargin)
% WEIB2DSTATPLOT Computes and plots the conditional mean and standard deviation
% 
%   CALL: weib2dstatplot(x1,x2,phat,res,sym);
%
%      x1,x2 = data 
%      phat  = [A1 B1 A2 B2 C12], i.e., 2D weibull parameters.     
%      res   = resolution (default range(X2)/12)
%      sym   = {s1,s2,s3,s4} cell array of plot symbols for 
%              plotting empirical mean and standard deviation and 
%              theoretical mean and standard deviation, respectively.
%              (default {'bo','rx','b-','r--'})
%
% WEIB2DSTATPLOT plots the  empirical conditional mean and standard
% deviation of X1 given X2 and optionally compares it with
% a 2D weibull distribution with parameters given in phat.
%
% Example
%  phat = [1 2 1.5 1 .8];
%  [y1,y2] = weib2drnd(phat,1000,1);
%  weib2dstatplot(y1,y2,phat);
%
% See also   weib2dstat

% tested on matlab 5.2
% history:
% revised pab 03.11.2000
% changed var(tmp) to std(tmp)^2
% by Per A. Brodtkorb 23.11.98
  
%default values
sym = {'bo','rx','b-','r--'}; % default plot symbols for the empirical
                              % mean and std, and theoretical mean and
                              % std,respectivel
			      
error(nargchk(2,8,nargin))
if nargin<4|isempty(res),   res=range(H(:))/12; end
Np=min(length(varargin),4);
if Np>0,
  if Np>1
    sym(1:Np)=varargin(1:Np);
  elseif iscell(varargin{1}),
    Np= min(length(varargin{1}),4);
    sym(1:Np)=varargin{1}(1:Np);
  end
end
grp=floor(H/res)+1; % dividing the data into groups 
Ngrp=max(grp);
Nmesh=40;
h1=linspace(res/2, (Ngrp-0.5)*res, Ngrp)';
%v1=linspace(eps,max(V),Nmesh)';
h2=linspace(0, max(H), Nmesh)';


m=h1;v=h1;
for ix=1:Ngrp,
  tmp=V(grp==ix);%find data in group number ix
  
  if length(tmp)>max(4,0),% if less than 4 observations in the group 
    m(ix)=mean(tmp);
    v(ix)=std(tmp).^2;
  else 
    m(ix)=NaN;
    v(ix)=NaN;
  end
end

ih = ishold;
plot(h1,m,sym{1},h1,sqrt(v),sym{2});  hold on
if ~isempty(phat), 
  [M1 V1]= weib2dstat(phat,2,h2);
  plot(h2,M1,sym{3},h2,sqrt(V1),sym{4}),  
end
if ~ih, hold off,end

title('Conditional mean and standard deviation')
xlabel('x2')
if nargout>0
  ax11=gca;
end
