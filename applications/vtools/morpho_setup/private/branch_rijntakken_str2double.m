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

function br_num=br_str2double(br_str)

% a=unique(cellfun(@(X)X(1:2),rkm_str,'UniformOutput',false));

warning('deprecated, use `branch_rijntakken`')

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
