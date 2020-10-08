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
function out=D3D_figure_domain(simdef,in)

switch simdef.D3D.structure
    case 1
        d3dplotgrid(grd);
    case 2
        is1d=0;
        if isfield(in,'network1d_geom_x')
            is1d=1;
        end
        if is1d
            D3D_figure_domain_1D(simdef,in)
        else
            D3D_figure_domain_2D(simdef,in)
            %%
            figure
            scatter(in.mesh2d_node_x,in.mesh2d_node_y)
%             error('implement')
        end

end %function