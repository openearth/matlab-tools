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
%Reads:
%   -cross section definition file (FM or Sobek3)
%   -cross section location file (FM or Sobek3)
%
%INPUT
%   -path_csloc = path to the file to read
%
%OUTPUT
%   -file_content = content of the file as a cell array of strings
%   -cs_out = structure of cross-sections; struct array
%   -global_data = structure of [Global] block (if present); struct


function [file_content, cs_out, global_data]=S3_read_crosssectiondefinitions(path_csloc)

warning('This function is deprecated. Use D3D_io_input with "read" instead.');
file_content=read_ascii(path_csloc);
[cs_out, global_data]=D3D_read_crosssections(path_csloc);

end
