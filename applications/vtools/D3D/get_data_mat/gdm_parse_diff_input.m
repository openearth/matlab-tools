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
%Based on the reference simulation, it removes input such as colormap and
%linestyle for plotting. 
%

function flg_loc=gdm_parse_diff_input(flg_loc)

%matrix
if isfield(flg_loc,'cmap')
    flg_loc.cmap(flg_loc.sim_ref,:)=[];
end

%cell array
if isfield(flg_loc,'ls')
    flg_loc.ls(flg_loc.sim_ref)=[];
end

end %function