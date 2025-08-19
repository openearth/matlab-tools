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