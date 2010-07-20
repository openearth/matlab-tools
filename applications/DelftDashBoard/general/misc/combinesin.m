function [a3,phi3]=combinesin(a1,phi1,a2,phi2)

c1=a1.*exp(i*phi1);
c2=a2.*exp(i*phi2);
c3=c1+c2;

a=real(c3);
b=imag(c3);

a3=sqrt(a.^2+b.^2);
phi3=atan2(b,a);
