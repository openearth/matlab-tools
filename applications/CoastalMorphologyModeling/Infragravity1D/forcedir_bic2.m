function  [k_yb,f_yb,eta_b,y,yu,yv,R,Fx,Fy,Px,Py,Em,Evx]  = ...
   forcedir3(xr,zr,E0,w0,theta_0,E1,f1,f2,theta_1,theta_2,gamb,alfa,ndis,dx);
% 
% 
% compute long wave surface elevation on an arbitrary beach
%


g = 9.81;
rho = 1023;
cf = 0.005;
h0 = zr(1);
ni  = length(zr);


% calculate wave energy balance

k0 = disper(w0,zr);
fp = w0/2/pi;
c = w0./k0;
n = (.5 + k0.*zr./sinh(2*k0.*zr));
cg = n.*c;
a_0 = asin(c*sin(theta_0)/c(1));
cgca = max(cg.*cos(a_0),.001);
cgsa = cg.*sin(a_0);
dcgca = gradient(cgca,xr);

Emax = max((rho*g*(gamb*zr).^2)/8,.01);
Emax1(1:ni-1) = 0.5*(Emax(1:ni-1) + Emax(2:ni));
cgca1(1:ni-1) = 0.5*(cgca(1:ni-1) + cgca(2:ni));
cgsa1(1:ni-1) = 0.5*(cgsa(1:ni-1) + cgsa(2:ni));
dcgca1(1:ni-1) = 0.5*(dcgca(1:ni-1) + dcgca(2:ni)); 

% initialize

Em   = zeros(ni,1);
Dm   = zeros(ni,1);
Erm  = zeros(ni,1);
Drm  = zeros(ni,1);

Em(1) = E0;
Dm(1) = 0;
Erm(1) = 0;
Drm(1) = 0;

% solve mean energy balance (ignoring mean set-up here)

for j = 1:ni-1

p1 = -dx*( 2*alfa*fp*(1-exp(-(Em(j)/Emax(j))^ndis)) + dcgca(j) )*Em(j)/cgca(j);
p2 = -dx*( 2*alfa*fp*(1-exp(-((Em(j)+p1/2)/Emax1(j))^ndis)) + dcgca1(j) )*(Em(j) + p1/2)/cgca1(j);
p3 = -dx*( 2*alfa*fp*(1-exp(-((Em(j)+p2/2)/Emax1(j))^ndis)) + dcgca1(j) )*(Em(j) + p2/2)/cgca1(j);
p4 = -dx*( 2*alfa*fp*(1-exp(-((Em(j)+p3)/Emax(j+1))^ndis)) + dcgca(j+1) )*(Em(j) + p3)/cgca(j+1);
Em(j+1) = Em(j) +(p1+2*p2+2*p3+p4)/6;
Dm(j+1) = max(2*alfa*fp*(1-exp(-((Em(j+1))/Emax(j+1))^ndis))*Em(j+1),0); 

end

Em(ni) = 0;


Hrms = sqrt(Em*8/rho/g);  % root mean square wave height
Us = w0*Hrms./sinh(k0.*zr)/2/sqrt(2); % near bed orbital velocity
V2 = zeros(size(Us)); % longshore current

% mean dissipation characteristics

Em1(1:ni-1) = 0.5*(Em(1:ni-1) + Em(2:ni));
Em1(ni) = Em1(ni-1);
Dm1(1:ni-1) = 0.5*(Dm(1:ni-1) + Dm(2:ni));
Dm1(ni) = Dm1(ni-1);

% calculate long wave response

% short wave characteristics

w1 = 2*pi*f1;
w2 = 2*pi*f2;
w_m = (w1+w2)/2;

% bound long wave frequency

w_l = abs(w1-w2);
f_yb = w_l/2/pi;

% short wave numbers 

k1 = disper(w1,zr);
k2 = disper(w2,zr);
c1 = w1./k1;
c2 = w2./k2;
   
  
 theta1 = asin(c1*sin(theta_1)/c1(1));
 theta2 = asin(c2*sin(theta_2)/c2(1));
 theta_m = atan((k1.*sin(theta1)+k2.*sin(theta2))./(k1.*cos(theta1)+k2.*cos(theta2)));


% angle of intersection of carrier waves 

dtheta = (theta2-theta1) + pi;


% bound long wave number

k_l = sqrt(k1.^2 + k2.^2 + 2*k1.*k2.*cos(dtheta));


% direction of bound long wave

theta_l = atan((k1.*sin(theta1) - k2.*sin(theta2))./(k1.*cos(theta1)-k2.*cos(theta2)));

% alongshore and cross-shore component of bound long wave

k_yb = k_l(1)*sin(theta_l(1))
k_xb = k_l(1)*cos(theta_l(1));

% wave group modulation

Ev = E1/E0.*Em;
Dv = E1/E0.*Dm;


% cross-shore modulation energy
kx(1) = 0;
dk = k_l.*cos(theta_l);

for j = 2:ni
kx(j) = kx(j-1) + dk(j)*(xr(j)-xr(j-1));
end


Evx = (Ev.*exp(-i*kx'));

% compute radiation stresses

Sxxv = ((n.*(1+ cos(theta_m).^2) - 0.5).*Evx) ;
Sxyv = (cos(theta_m).*sin(theta_m)).*(n.*Evx);
Syyv = ((n.*(1+ sin(theta_m).^2) - 0.5).*Evx );


% determine gradients

DSxxv = gradient(Sxxv,xr);
D2Sxxv = gradient(DSxxv,xr);
DSxyv = gradient(Sxyv,xr);

% construct forcing vector

   R = -((D2Sxxv - 2*i*k_yb.*DSxyv - k_yb.*k_yb.*Syyv)/rho/g)*dx*dx;

% bottom slope

hx = gradient(zr,xr);

% coefficients 
ar = hx/2;
b = (w_l*w_l/g - i*Us.*cf.*w_l/g./zr -k_yb*k_yb*zr)/2;

% offshore boundary conditions for bound long waves
a_out=((asin(k_yb(1)*sqrt(g*h0)/w_l)))
eta_b = (Sxxv.*cos(theta_l).^2+2*Sxyv.*cos(theta_l).*sin(theta_l)+Syyv.*sin(theta_l).^2)/rho./((w_l./k_l).^2 + ...
          i*Us*w_l.*cf./k_l./k_l./zr-g*zr);
c01 = (-i*w_l - i*k_yb(1).*sin(a_out)*sqrt(g*h0))*2*dx/sqrt(g*h0)/cos(a_out);
c02 = (i*k_xb.*(sqrt(g*h0)*cos(a_out) + w_l/k_l(1)*cos(theta_l(1))) + ...
       i*k_yb(1).*(sqrt(g*h0)*sin(a_out) + w_l/k_l(1)*sin(theta_l(1))))*eta_b(2)*2*dx/sqrt(g*h0)/cos(a_out);
c00 = (2*dx*dx*b(2) -zr(2)*2 + c01*(zr(2)-ar(2)*dx));
b1 = -c02*(zr(2)-ar(2)*dx);


% shore line boundary condition

cn = (-2*zr(ni-1) + 2*dx*dx*b(ni-1));
bn = -(DSxxv(ni-1) - i*k_yb*Sxyv(ni-1))/rho/g/zr(ni-1);

% inner matrix coefficients

c1 = zr-ar.*dx;
c2 = -zr.*2 + 2.*dx*dx*b;
c3 = zr+ dx*ar;

% right hand side
B = zeros(ni-2,1);
B(1) = b1 + R(2);
B(2:ni-3) = R(3:ni-2);
B(ni-2) = R(ni-1) - (zr(ni-1)*2*dx + ...
                         ar(ni-1)*2*dx*dx)*bn;

% construct matrix

AA(:,1) = c2(2:ni-1);
AA(1,1) = c00;
AA(ni-2,1) = cn;
AA(:,2) = c3(1:ni-2);
AA(1,2) = 0;
AA(2,2) = 2*zr(2);
AA(:,3) = c1(3:ni);
AA(ni-3,3) = 2*zr(ni-1);
AA(ni-2,3) = 0;

% infragravity surface elevation

y(2:ni-1) = gauss_3(AA,B);

% boundary conditions

% offshore
y(1) = c02 + c01*y(2) + y(3);
% shore line
y(ni) =  y(ni-2) + bn*2*dx;

% compute infragravity velocities

% cross-shore

Fx =(DSxxv-i*k_yb*Sxyv)/rho./zr;  % radiation stress gradient
Px = g*conj(gradient(y,xr)'); % pressure gradient
yu = (-g*conj(gradient(y,xr)')- Fx)./(i*(w_l-k_yb.*V2) + Us.*cf./zr); % cross-shore velocity
yu(end) = yu(end-1);  % last point gradient of eta not defined, assume deta/dx = 0

% and alongshore 

Fy =(DSxyv-i*k_yb*Syyv)/rho./zr;  % radiation stress gradient
Py = -i*g*k_yb.*conj(y');   % alongshore pressure gradient
yv = (i*g*k_yb.*conj(y')-gradient(V2,xr).*yu-Fy)./(i*(w_l-k_yb.*V2)+ Us.*cf./zr); % alongshore velocity
yv(end) = yv(end-1);



