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

function in_plot=gdm_check_deprecated_tag(in_plot,tag_check,tag_new)

if isfield(in_plot,tag_check)==1
    warning('Tag %s is deprecated. Use %s',tag_check,tag_new)
    in_plot.(tag_new)=in_plot.(tag_check);
end

end %function