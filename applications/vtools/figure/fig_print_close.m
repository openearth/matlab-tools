%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20156 $
%$Date: 2025-05-19 14:16:30 +0200 (Mon, 19 May 2025) $
%$Author: chavarri $
%$Id: fig_map_sal_01.m 20156 2025-05-19 12:16:30Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_map_sal_01.m $
%

function fig_print_close(in_p,han_fig,fig_print,fpath_fig)

%% PARSE

in_p=isfield_default(in_p,'fig_resolution','-r300');

%% CALC

if any(fig_print==1)
    print(han_fig,strcat(fpath_fig,'.png'),'-dpng',in_p.fig_resolution);
    messageOut(NaN,sprintf('Figure printed: %s',strcat(fpath_fig,'.png'))) 
end
if any(fig_print==2)
    savefig(han_fig,strcat(fpath_fig,'.fig'))
    messageOut(NaN,sprintf('Figure printed: %s',strcat(fpath_fig,'.fig'))) 
end
if any(fig_print==3)
    print(han_fig,strcat(fpath_fig,'.eps'),'-depsc2','-loose','-cmyk')
    messageOut(NaN,sprintf('Figure printed: %s',strcat(fpath_fig,'.eps'))) 
end
if any(fig_print==4)
    print(han_fig,strcat(fpath_fig,'.jpg'),'-djpeg',in_p.fig_resolution)
    messageOut(NaN,sprintf('Figure printed: %s',strcat(fpath_fig,'.jpg'))) 
end
if any(ismember(fig_print,[1,2,3,4]))
close(han_fig);
end

end %function