%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_adapt_time.m $
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

function [eq,d1,d2,dd]=gdb_compare_files(fpath_1,fpath_2)

data_1=gdb_read_variables_file(fpath_1);
data_2=gdb_read_variables_file(fpath_2);

[eq,d1,d2,dd]=comp_struct_diff(data_1,data_2);

end %function