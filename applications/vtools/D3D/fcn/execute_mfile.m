%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17201 $
%$Date: 2021-04-16 19:15:25 +0200 (Fri, 16 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_read_input_m.m 17201 2021-04-16 17:15:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_input_m.m $
%
%Reads a .m-like text file and reconstructs in_plot struct.
%
%INPUT:
% filename = path to text file containing MATLAB assignments.

function execute_mfile(filename)

% Read file as text
txt = fileread(filename);

% Initialize output variable so eval works in this workspace
% in_plot = struct();

% Evaluate in current function workspace
eval(txt);

end %function