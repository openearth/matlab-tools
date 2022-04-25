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

function in_plot=create_mat_default_flags(in_plot)

if isfield(in_plot,'lan')==0
    in_plot.lan='nl';
end

%moved to each function
% if isfield(in_plot,'fig_map_sal_01')==0
%     in_plot.fig_map_sal_01.do=0;
% end
% 
% if isfield(in_plot,'fig_map_ls_01')==0
%     in_plot.fig_map_ls_01.do=0;
% end
% 
% if isfield(in_plot,'fig_map_sal_mass_01')==0
%     in_plot.fig_map_sal_mass_01.do=0;
% end

%% MAP

in_plot.map=0;
if any([in_plot.fig_map_sal_01.do,in_plot.fig_map_sal_01.do,in_plot.fig_map_sal_mass_01.do])
    in_plot.map=1;
end

%% copy flags

fn=fieldnames(in_plot);
nf=numel(fn);
for kf=1:nf
    if isstruct(in_plot.(fn{kf}))
        %lan
        in_plot.(fn{kf}).lan=in_plot.lan;
    end
end

end %function