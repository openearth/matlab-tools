%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 27 $
%$Date: 2022-03-31 13:12:25 +0200 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 27 2022-03-31 11:12:25Z chavarri $
%$HeadURL: file:///P:/11208075-002-ijsselmeer/07_scripts/svn/create_mat_map_sal_mass_01.m $
%
%

function in_plot=create_mat_default_flags(in_plot)

if isfield(in_plot,'lan')==0
    in_plot.lan='nl';
end

if isfield(in_plot,'fig_map_sal_01')==0
    in_plot.fig_map_sal_01.do=0;
end

if isfield(in_plot,'fig_map_ls_01')==0
    in_plot.fig_map_ls_01.do=0;
end

if isfield(in_plot,'fig_map_sal_mass_01')==0
    in_plot.fig_map_sal_mass_01.do=0;
end

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