%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18545 $
%$Date: 2022-11-15 13:06:55 +0100 (di, 15 nov 2022) $
%$Author: chavarri $
%$Id: D3D_io_input.m 18545 2022-11-15 12:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_io_input.m $
%
%

function br_num=br_str2double(br_str)

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
    case 'WL'
        br_num=9;
    otherwise
        br_num=NaN;
end 

end %functions
