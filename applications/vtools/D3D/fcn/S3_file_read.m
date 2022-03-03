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
%Select output file depending on variable
%
%INPUT:
%
%OUTPUT:
%

function file_read=S3_file_read(which_v,file)

switch which_v
    case {2,12} %map
        file_read=file.map;
    case {10} %reachsegments
        file_read=file.reach;
    otherwise
        error('add')
end

end %function
