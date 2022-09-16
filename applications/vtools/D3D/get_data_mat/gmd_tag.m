%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 06:18:42 +0200 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_tag_fig.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_tag_fig.m $
%
%

function in_plot_fig=gmd_tag(in_plot,tag_check,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fig','');

parse(parin,varargin{:});

tag_fig_str=parin.Results.fig;

%% CALC

in_plot_fig=in_plot.(tag_check);

if isfield(in_plot_fig,'tag')==0
    in_plot_fig.tag=strrep(tag_check,'fig_','');
end

if ~isempty(tag_fig_str)
    in_plot_fig.tag_fig=sprintf('%s_%s',in_plot_fig.tag,tag_fig_str);
end

end %function