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

function br_s=branch_rt(br,rkm_s)

switch br
    case {'WL','BO','NI'}
        if rkm_s>960.15
            br_s='NI';
        elseif rkm_s>952.85
            br_s='BO';
        else
            br_s='WL';
        end
    otherwise
        error('do')
end

end %function
