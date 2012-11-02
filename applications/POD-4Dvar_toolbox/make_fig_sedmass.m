close all

% path to: calculate_accretion_erosion.m
addpath('p:\x0385-gs-mor\ivan\paper_2\')

themarkersize = 4;
h = figure;
calculate_accretion_erosion(dps_zero_concentration_at_boundary.vectors.dps,0.5*0.5,'r -.','r --','r :');

hold on
calculate_accretion_erosion(dps_normal.vectors.dps,0.5*0.5,'b -.','b --','b :');
xlim([0,217/3/24])

title('Effects of: \it Equilibrium sand concentration profile at inflow boundary')
legend('Deactivated','Activated','location','southwest')

print(h,'-depsc2','volumetric_sediment_change')