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
%Runs the plotting routine reading the input from a matlab script
%
%INPUT:
%   -path_input: path to the matlab script (char)

function out_read=D3D_plot_from_file(path_input)

messageOut(NaN,'start plotting')
[def,simdef,in_read]=D3D_read_input_m(path_input);
out_read=D3D_plot(simdef,in_read,def);
messageOut(NaN,'finished plotting')

end %function