function [h_p1,Kk] = h_phase_one_merkelbach(n,xdata)

load tmp.mat

Kk = (10^(log10((h1/((h_ini*phi_0*((2-n)/(1-n)))^((1-n)/(2-n))))/t1.^(1/(2-n)))/(1/(2-n))))/(Delta*(n-2)); %eq. 4.51 solved for h=h1 at t=t1
h_p1(:,1) = (h_ini*phi_0*((2-n)/(1-n)))^((1-n)/(2-n))*(Kk*Delta*(n-2))^(1/(2-n)).*xdata.^(1/(2-n)); %eq 4.51 from Merkelbach, 2000

% h_p1(:,1) = (zeta*((2-n)/(1-n)))^((1-n)/(2-n))*((10^(log10((h1/((zeta*((2-n)/(1-n)))^((1-n)/(2-n))))/t1.^(1/(2-n)))/(1/(2-n))))/(Delta*(n-2))*Delta*(n-2))^(1/(2-n)).*xdata.^(1/(2-n)); %eq 4.51 from Merkelbach, 2000
end