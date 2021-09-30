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
%

function nt=NC_nt(nc_map)

        nci=ncinfo(nc_map);
        idx_t=find_str_in_cell({nci.Dimensions.Name},{'time'});
        nt=nci.Dimensions(idx_t).Length;
        
end 