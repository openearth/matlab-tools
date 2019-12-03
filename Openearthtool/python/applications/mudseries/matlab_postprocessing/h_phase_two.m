function [y] = h_phase_two(K_p)

load tmp2.mat
y = abs(h_inf_meas - (zeta_s+(n/(n-1))*(K_p./(9.81*(rho_s-rho_w)))*((9.81*(rho_s-rho_w)*zeta_m)/K_p)^((n-1)/n)));
end