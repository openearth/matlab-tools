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

function in_p=gdm_parse_fig_margins(in_p)

%in [cm]
in_p=isfield_default(in_p,'fig_margin_top',1.5);
in_p=isfield_default(in_p,'fig_margin_bottom',1.5);
in_p=isfield_default(in_p,'fig_margin_right',0.5);
in_p=isfield_default(in_p,'fig_margin_left',2.0);
in_p=isfield_default(in_p,'fig_margin_separation_horizontal',0.5);
in_p=isfield_default(in_p,'fig_margin_separation_vertical',0.0);

end %function