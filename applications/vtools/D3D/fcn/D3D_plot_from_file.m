%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17190 $
%$Date: 2021-04-15 10:24:15 +0200 (Thu, 15 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_plot.m 17190 2021-04-15 08:24:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_plot.m $
%
function out_read=D3D_plot_from_file(path_input)

messageOut(NaN,'start plotting')
run(path_input)
out_read=D3D_plot(simdef,in_read,def);
messageOut(NaN,'finished plotting')

end %function