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
    otherwise
        error('Unknown extension %s',fext);
end

end %function