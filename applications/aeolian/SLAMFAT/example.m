L  = 100;
dx = 1;
dt = .05;

wind = slamfat_wind('f_mean',3,'f_sigma',2.5,'dt',dt);

source = zeros(L,1);
source(1:20) = 1.5e-7 * dt * dx;

%%

result = slamfat_core('wind',wind,'source',source,'dx',dx,'dt',dt);

slamfat_plot(result,'slice',100,'window',100);

%%

figure; hold on;
scatter(result.input.wind(:,1), ...
        result.output.transport(:,end) .* result.input.wind(:,1), ...
        10, double(result.output.supply_limited(:,end)));
    

    
xlabel('Wind speed [m/s]');
ylabel('Concentration in transport [kg/m^2]');