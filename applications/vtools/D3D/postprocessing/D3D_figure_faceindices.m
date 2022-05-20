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
function D3D_figure_faceindices(han,in)

han.fig_fi=figure;
hold on
scatter3(in.x_face,in.y_face,[1:1:numel(in.x_face)],10,[1:1:numel(in.x_face)],'filled')
view([0,90])
axis equal
han.ta=gca;
linkaxes([han.sfig,han.ta],'xy')

