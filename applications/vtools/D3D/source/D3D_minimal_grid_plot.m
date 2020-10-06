
%% INPUT

simdef.D3D.dire_sim='C:\Users\chavarri\temporal\200930_bendeffect\05_waal\r001\';

%% CALC

simdef.flg.print=NaN; %do not print
simdef.flg.which_p='grid';
simdef=D3D_simpath(simdef);
out_read=D3D_read(simdef,NaN);
D3D_figure_domain(simdef,out_read);