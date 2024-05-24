
function [fse,fne] = fsfnexact(H,R,ust,z0,karman,z)
%function [fse,fne,Sne,ee] =
%fsfnexact(H,g,Ss,R,ust,nu,nu_num,karman,z0,z,ddz)

%z      = z0:(H-z0)/100:H-z0;
ddz    = diff(z);
acc    = 1e-10;  %Set accuracy of polylog
g      = 9.81;

%if z(end)==H;
z(end) = H-eps;
%end

%Streamwise solution ...
fse = ust/karman*log(z./z0);

%Determine transverse solution ...
%1. Integrate transverse momentum equation first time from z to H.
uk = (ust/karman)^2/R;    %constant
e1 = uk;
e2 = -2*uk;
e3 = -2*uk;     
e4 = -uk*H*((log(H/z0))^2-2*log(H/z0)); %-2*uk*z0;  
e3s=  g;       %Slope part included at end.
e4s=  0;       %Slope part included at end.

e =   e1.*(log(z./z0)).^2.*z + e2.*log(z./z0).*z + e3.*(H-z) + e4;
es = (e3s.*(H-z)+e4s);  %Slope part

%Integrate part by part 
%f1 is integral of e1, f2 integral of e2, etc ...

%Integrate[Log[x/z0]^2/(h - x), x] ==
%-2*((Log[1 - x/h]*Log[x/z0]^2)/2 + Log[x/z0]*PolyLog[2, x/h] -
%PolyLog[3,x/h])
Li2 = polylog(2,z./H,acc);
Li3 = polylog(3,z./H,acc);
f1=-2*(0.5*log(max(H-z,eps)./H).*(log(z/z0)).^2+Li2.*log(z./z0)-Li3);

%Integrate[Log[x/z0]/(h - x), x] ==
%-(Log[1 - x/h]*Log[x/z0]) - PolyLog[2, x/h]
f2=-log(z/z0).*log(max(H-z,eps)./H)-Li2;
f3=(log(z));

f4=log(z./max(H-z,eps))/H;

%When integrating 1/(z*(H-z)+nu_num) the result is:
%f4=(-2*atan((-H + 2*z)/sqrt(-H^2 - 4*nu_num)))/sqrt(-H^2 - 4*nu_num);

f   = (-ust*karman/H)^(-1)*(e1.*f1 + e2.*f2 + e3.*f3 + e4.*f4);
fss = (-ust*karman/H)^(-1)*((e3s).*f3 + e4s.*f4);
f = (f-f(1));
fss = (fss-fss(1));
%fm  = mean(f-f(1));     
%fssm= mean(fss-fss(1)); 
fm = (f(1:end-1)+f(2:end))*ddz'*0.5;
fssm = (fss(1:end-1)+fss(2:end))*ddz'*0.5;
Sne = -fm/fssm;   %Determine slope such that mean(fse,0);
fne = f+Sne*fss;
%ee  = -Ss*es;

