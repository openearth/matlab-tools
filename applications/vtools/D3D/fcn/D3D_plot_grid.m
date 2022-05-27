%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function D3D_plot_grid(fdir_sim)

simdef.D3D.dire_sim=fdir_sim;
simdef.flg.which_p='grid';
simdef.flg.print=NaN;
simdef=D3D_simpath(simdef,'break',1);
out_read=D3D_read(simdef,NaN);
D3D_figure_domain(simdef,out_read);