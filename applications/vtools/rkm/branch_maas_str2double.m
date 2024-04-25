%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19540 $
%$Date: 2024-04-11 16:54:42 +0200 (Thu, 11 Apr 2024) $
%$Author: chavarri $
%$Id: branch_rijntakken_str2double.m 19540 2024-04-11 14:54:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/rkm/branch_rijntakken_str2double.m $
%
%

function br_num=branch_maas_str2double(br_str)

% a=unique(cellfun(@(X)X(1:2),rkm_str,'UniformOutput',false));

switch br_str
    case 'MA'
        br_num=1;
    otherwise
        br_num=NaN;
end 

end %functions
