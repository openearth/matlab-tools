Cw0=.00063;Cw100=.00723;Chezy=65;g=9.81;rho=1025;Cd=g/Chezy^2;
uw=20;
rhoa=1.;
Cw=Cw0+uw/100*(Cw100-Cw0);
tauw=rhoa*Cw*uw^2;
t=tauw/rho/g;
h0=20.
for ia=1:5;
   alfa=.002*ia
   x0=h0/alfa
   dx=x0/10000;
   x=[0:dx:x0];
   h=alfa*(x0-x);
   eta1(1,ia)=0;
   eta2(1,ia)=0;
   for i=2:length(x);
      eta1(i,ia)=eta1(i-1,ia)+dx*(tauw/rho/g/h(i-1));
      h(i)=h(i)+eta1(i,ia);
      eta2(i,ia)=-tauw/rho/g/alfa*log((x0-x(i))/x0);
   end
end
figure(1)
plot(x/x0,eta1(:,1),x/x0,eta1(:,2),x/x0,eta1(:,3),x/x0,eta1(:,4),x/x0,eta1(:,5),'linewidth',2)
hold on
plot(x/x0,eta2(:,1),x/x0,eta2(:,2),x/x0,eta2(:,3),x/x0,eta2(:,4),x/x0,eta2(:,5),'linewidth',1)
set(gca,'fontsize',11,'fontweight','bold')
set(gca,'ylim',[ 0 0.2])
xlabel('alfa*x/h_0');
ylabel('setup (m)');
title('Setup as function of slope alfa, u_1_0=20 m/s');
legend('alfa=0.002','alfa=0.004','alfa=0.006','alfa=0.008','alfa=0.010','location','northwest')
print('-depsc','windsetup.eps')