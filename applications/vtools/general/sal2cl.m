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
% 1: convert [psu]    -> [mgCl/l]
%-1: convert [mgCl/l] -> [psu]

function out_val=sal2cl(flg_conv,in_val)

if iscell(in_val)
    out_val=cellfun(@(X)sal2cl(flg_conv,X),in_val,'UniformOutput',false);
    return
end

switch flg_conv
    case 1 %sal2cl
        out_val=in_val./1.80655*1000;
    case -1 %cl2sal
        out_val=in_val.*1.80655/1000;
end

end %function