function n=n_offshore_boundary(t,h)
% n=n_offshore_boundary(t,h)

% t=12.5;
% h=13;
L1=9.81*t^2/2/pi;
L2=0;
er=1;
while er>0.01
L2=9.81*t^2/2/pi*tanh(2*pi*h/L1);
er=abs(L2-L1);
L1=L2;
end
k=2*pi/L1;
n=0.5+k*h/sinh(2*k*h);