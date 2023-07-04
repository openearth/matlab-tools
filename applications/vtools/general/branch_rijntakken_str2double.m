%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19025 $
%$Date: 2023-07-03 08:46:37 +0200 (Mon, 03 Jul 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken_str2double.m 19025 2023-07-03 06:46:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/private/branch_rijntakken_str2double.m $
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
