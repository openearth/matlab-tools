%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19197 $
%$Date: 2023-10-18 06:59:30 +0200 (Wed, 18 Oct 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken_str2double.m 19197 2023-10-18 04:59:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/branch_rijntakken_str2double.m $
%
%

function br_num=branch_rijntakken_str2double(br_str)

% a=unique(cellfun(@(X)X(1:2),rkm_str,'UniformOutput',false));

switch br_str
    case 'BO'
        br_num=1;
    case 'BR'
        br_num=2;
    case 'IJ'
        br_num=3;
    case 'LE'
        br_num=4;
    case 'NI'
        br_num=5;
    case 'NR'
        br_num=6;
    case 'PK'
        br_num=7;
    case 'RH'
        br_num=8;
    case {'WL','WA'}
        br_num=9;
    otherwise
        br_num=NaN;
end 

end %functions
