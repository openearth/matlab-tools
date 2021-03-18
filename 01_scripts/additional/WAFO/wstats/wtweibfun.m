function y=wtweibfun(phat,x,F,def,monitor)
% WTWEIBFUN Is an internal routine for wtweibfit
%

b =2; c1 = 0;

a = phat(1);
Np = length(phat);
if Np>1, b = phat(2);end
if Np>2, c1 = phat(3); end

c = abs(c1);

N = length(F);
%monitor = logical(1);
switch def
  case 1, % fit to sqrt(-log(1-F))
  if monitor
    plot(x,sqrt(-log(1-F)),....
	x,sqrt(((x+c)./a).^b-(c/a).^b)); drawnow
  end
  
  y=mean((-sqrt(-log(1-F))+...
      sqrt(((x+c)./a).^b-(c/a).^b)).^2) + N*c*(c1<0);
case 2, % fit to (-log(1-F))
  if monitor
    plot(x,(-log(1-F)),...
	x,(((x+c)./a).^b-(c/a).^b)); drawnow
  end
  y=mean((-(-log(1-F))+...
      (((x+c)./a).^b-(c/a).^b)).^2)+N*c*(c1<0);

case   3, % fit to (-log(1-F)).^(1/b)
  if monitor
    plot(x,(-log(1-F)).^(1/b),x,...
	(((x+c)./a).^b-(c/a).^b).^(1/b)); drawnow
  end
  y=mean((-(-log(1-F)).^(1/b)+...
      (((x+c)./a).^b-(c/a).^b).^(1/b)).^2)+N*c*(c1<0);
case 4,  % fit to (-log(1-F)+(c/a).^b).^(1/b)
  if monitor
    plot(x,(-log(1-F)+(c/a).^b).^(1/b),x,(x+c)./a); drawnow
  end
  y=mean((-(-log(1-F)+(c/a).^b).^(1/b)+(x+c)./a).^2)+N*c*(c1<0);
case 5, % fit x/a to ((-log(1-F)+abs(a)).^(1/b));
       
  tmp = ((-log(1-F)+abs(a)).^(1/b))-abs(a)^(1/b);  
  p = ([x ]\tmp).'; % Linear LS fit to find 1/a
  tmp = tmp/p(1);
  if monitor
    plot(x,x,x,tmp); drawnow
  end
  % Equal weigth on all x: 
  y = (mean(abs((tmp-x)).^(2)))+N*abs(a)*(a<0)+ (b-15)^2*(b>15)/N;
case 6, % fit x/a to ((-log(1-F)+abs(a)).^(1/b));
  
  cda = abs(a).^(1/b); % = c/a
  tmp = ((-log(1-F)+abs(a)).^(1/b))-cda;
  p = ([x ]\tmp).'; % Linear LS fit to find 1/a
  tmp = tmp/p(1);
  
  if 0 %monitor
    plot(x,x,x,tmp); drawnow
  end
  
  tmp3 =  (-log(1-F));
  tmp4 = (((x*p(1)+cda)).^b-abs(a));
  
  % fit to (-log(1-F))  
  % More weight on the tails: The tail is fitted very well
  y = mean(abs(x-tmp).^(2)+abs(tmp3-tmp4).^(2))+N*abs(a)*(a<0)+(b-6)*(b>10)/N;
  if monitor
    plot(x,[x, tmp],x,[tmp3,tmp4]); drawnow
  end
case 7
  pac=[0.00077598974699  -0.02620368505187   1.28552709525102  -0.73037371897582];
pba=[-0.00641052386506   0.13245900299368   0.45810897559486  -0.38495820627853];
  % c = abs((a^1.25-0.4)/1.41)+.2;
  %c = abs((a^1.25-0.2)/1.45);
  %a = polyval(pba,b);
  c = polyval(pac,a);
  %c = abs((a^1.25-0.57)/1.41);
  cda = abs(c/a);
  tmp = (((-log(1-F)+cda^b).^(1/b))-cda)*a;
  %tmp3 =  (-log(1-F));
  %tmp4 = ((x+c)/a).^b-cda^b;
  if monitor
    plot(x,[x, tmp]); drawnow
  end
  y = mean(abs(x-tmp).^(2))+N*abs(a)*(a<=0)+(b-6)*(b>6)/N;
case 8
  tmp = sqrt(-log(1-F));
  tmp2 = sqrt(-log(1-wtweibcdf(x,a,b,c)));
  if monitor
    plot(x,[ tmp tmp2]); drawnow
  end
  y = mean(abs(tmp-tmp2).^(2));
end

if monitor
  disp(['err = ' num2str(y,10)   ' a b c = ' num2str([a,b,c],4) ])
end







