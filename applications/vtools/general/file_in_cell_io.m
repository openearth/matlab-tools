%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17184 $
%$Date: 2021-04-14 14:53:36 +0200 (Wed, 14 Apr 2021) $
%$Author: chavarri $
%$Id: writetxt.m 17184 2021-04-14 12:53:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/writetxt.m $
%
%Wrapper around functions I always forger the name. It reads or 
%writes a file in a cell array for easy modification. Don't
%use it for large files. It is inefficient. 
%
%INPUT
%   -what2do: either 'read' or 'write'.
%   -file_name: filename to read or to write.
%
%   in case what2do='write': 
%   -varargin{1}=cell array to write as ascii
%
%PAIR INPUT
%   in case what2do='write':
%       -check_existing: it checks if there is a existing file. If false, it overwrites. 
%
%OUTPUT
%   in case what2do='write':
%       -varargout{1}=cell array with each line of an ascii file in each row of the array.

function varargout=file_in_cell_io(what2do,file_name,varargin)

switch what2do
    case 'read'
        ascii_out=read_ascii(file_name);
        varargout{1}=ascii_out;
    case 'write'
        data=varargin{1};
        writetxt(file_name,data,varargin{2:end})
        varargout={};
end
        
end %function
