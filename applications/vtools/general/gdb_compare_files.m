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
%Compares two files out of GDB. See `gdb_read_variables_file` for
%knowing the format of these files. 
%
%INPUT:
%   -fpath_1 = filepath to first file to compare [char]
%   -fpath_2 = filepath to second file to compare [char]
%
%OUTPUT:
%   -eq = variables which are the same in both files [struct, double]
%   -d1 = variables which are different in file 1 [struct, double]
%   -d2 = variables which are different in file 2 [struct, double]
%   -dd = difference between variables in files 1 and 2 [struct, double]

function [eq,d1,d2,dd,dm,di]=gdb_compare_files(fpath_1,fpath_2)

data_1=gdb_read_variables_file(fpath_1);
data_2=gdb_read_variables_file(fpath_2);

[eq,d1,d2,dd,dm,di]=comp_struct_diff(data_1,data_2,0,0,1e-16);

end %function