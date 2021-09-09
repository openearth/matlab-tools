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

function out_val=sal2cl(flg_conv,in_val)

switch flg_conv
    case 1 %sal2cl
        out_val=in_val./1.80655*1000;
    case -1 %cl2sal
        out_val=in_val.*1.80655/1000;
end

end %function