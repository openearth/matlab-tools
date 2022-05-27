%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17803 $
%$Date: 2022-03-02 09:37:07 +0100 (Wed, 02 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_plot.m 17803 2022-03-02 08:37:07Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot.m $
%

function D3D_plot_grid(fdir_sim)

simdef.D3D.dire_sim=fdir_sim;
simdef.flg.which_p='grid';
simdef.flg.print=NaN;
simdef=D3D_simpath(simdef,'break',1);
out_read=D3D_read(simdef,NaN);
D3D_figure_domain(simdef,out_read);