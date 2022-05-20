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



function ncwrite_class(file,varname,var_original,var_new)

    switch class(var_original)
        case 'double'
            var_new_class=double(var_new);
        case 'int32'
            var_new_class=int32(var_new);
        otherwise
            error('include a new case')
    end
    
    ncwrite(file,varname,var_new_class)

end %function