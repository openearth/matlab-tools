%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19509 $
%$Date: 2024-03-28 08:59:52 +0100 (Thu, 28 Mar 2024) $
%$Author: chavarri $
%$Id: printV.m 19509 2024-03-28 07:59:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/printV.m $
%
%

function printV(fig_han,fpath_fig)

%% PARSE

if nargin==1
    fpath_fig=fullfile(pwd,'fig.png');
end

%% CALC

[fdir,fname,fext]=fileparts(fpath_fig);

switch fext
    case '.png'
        print(fig_han,fpath_fig,'-dpng','-r300')
    case '.fig'
        savefig(fig_han,fpath_fig);
    otherwise
        error('Unknown extension %s',fext);
end

end %function