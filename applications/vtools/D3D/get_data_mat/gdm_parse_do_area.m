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
%By default, do area plot to sediment transport per size fraction to
%have a stack. 

function flg_loc=gdm_parse_do_area(flg_loc,simdef)

if isfield(flg_loc,'do_area')==0
    flg_loc.do_area=zeros(size(flg_loc.var));
end
bol_stot=strcmp('stot',flg_loc.var);
flg_loc.do_area(bol_stot)=true;

end %function
