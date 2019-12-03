function [h_p1,Kk] = h_phase_one(n,xdata)

load tmp.mat

Kk = (10^(log10(((h1-phi_sa0*h_ini)/((zeta_m*((2-n)/(1-n)))^((1-n)/(2-n))))/t1.^(1/(2-n)))/(1/(2-n))))/(Delta*(n-2)); 
h_p1(:,1) = (zeta_m*((2-n)/(1-n)))^((1-n)/(2-n))*(Kk*Delta*(n-2))^(1/(2-n)).*xdata.^(1/(2-n)); 

% h_p1(:,1) = (zeta*((2-n)/(1-n)))^((1-n)/(2-n))*((10^(log10((h1/((zeta*((2-n)/(1-n)))^((1-n)/(2-n))))/t1.^(1/(2-n)))/(1/(2-n))))/(Delta*(n-2))*Delta*(n-2))^(1/(2-n)).*xdata.^(1/(2-n)); %eq 4.51 from Merkelbach, 2000
end