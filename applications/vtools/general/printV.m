%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19009 $
%$Date: 2023-06-20 07:14:19 +0200 (Tue, 20 Jun 2023) $
%$Author: chavarri $
%$Id: create_mat_measurements_from_shp_01.m 19009 2023-06-20 05:14:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/create_mat_measurements_from_shp_01.m $
%
%

function printV(fig_han,fpath_fig)

%% PARSE

%% CALC

[fdir,fname,fext]=fileparts(fpath_fig);

switch fext
    case '.png'
        print(fig_han,fpath_fig,'-dpng','-r300')
    otherwise
        error('Unknown extension %s',fext);
end

end %function