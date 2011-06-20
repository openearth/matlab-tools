close all; clear all;

%% input
Hrms = 3.5/sqrt(2);
Tp   = 8.1;
h0   = 25;

g    = 9.81;
rho  = 1025;
alfa = 1;
gamma= 0.6;

df   = 0.0001;

%% compute spectrum

f    = 0.00001:df:1.2;
fpeak= 1/Tp;
Ef   = g^2*(2*pi)^-4*f.^-5.*exp(-5/4*(f./fpeak).^-4);
Hrmst= sqrt(8*sum(Ef(~isnan(Ef))*df));
Ef   = Hrms^2/Hrmst^2*Ef;

% figure; plot(f,Ef,'b'); axis([0 1.4 0 1.25*max(Ef)]);

m0   = sum(Ef(~isnan(Ef))*df);
Hm0  = 4*sqrt(m0);

a    = sqrt(2*Ef*df);
w    = 2*pi*f;
phi  = 2*pi*rand(1,length(f));

%% compute energy time series

t = 0:0.4:25000;
eta = zeros(1,length(t));
for i = 1:length(f)
    eta = eta + a(i)*sin(w(i)*t+phi(i));
end
env = abs(hilbert(eta));

T = t(end);
df2 = 1/T;
n  = length(env);
envf = fft(env);
fsplit = 1/2/Tp;
nsplit = round(fsplit/df2);
set = zeros(1,length(env));
set(1:nsplit-1) = 1;
set(n-nsplit+3:n) = 1;

envf = set.*envf;
env2 = real(ifft(envf));
env2 = sqrt(mean(env.^2)/mean(env2.^2).*env2.^2); % keep the same energy at model boundary!

figure; plot(t,eta,'b'); hold on; plot(t,env,'b','LineWidth',2); plot(t,env2,'g','LineWidth',3);

% use filtered or non-filtered envelope...
E_ft = 1/2*rho*g*env2.^2;

Hm02 = sqrt(2*mean(E_ft)*8/1000/9.81);

eta_lf = zeros(1,length(t));
temp_ft= eta_lf;

fid = fopen('Gen_brad.ezs','w')
fprintf(fid,'%s\n',['*    t (s) eta LF(m)  E (J/m2) eta BI(m)  eta F(m)']);
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i\t %i\n',length(t),5);
for i = 1:length(t)
    fprintf(fid,'%5.3f\t %5.3f\t %5.3f\t %5.3f\t %5.3f\n',t(i),eta_lf(i),E_ft(i),temp_ft(i),temp_ft(i));
end
fclose(fid);

save Gen_brad.mat