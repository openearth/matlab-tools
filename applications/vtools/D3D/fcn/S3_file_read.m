%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17029 $
%$Date: 2021-02-01 13:23:23 +0100 (Mon, 01 Feb 2021) $
%$Author: chavarri $
%$Id: function_layout.m 17029 2021-02-01 12:23:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/function_layout.m $
%
%Select output file depending on variable
%
%INPUT:
%
%OUTPUT:
%

function file_read=S3_file_read(which_v,file)

switch which_v
    case {12} %map
        file_read=file.map;
    case {10} %reachsegments
        file_read=file.reach;
    otherwise
        error('add')
end

end %function
