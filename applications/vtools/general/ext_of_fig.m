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

function fext=ext_of_fig(fig_print)

switch fig_print
    case 0
        fext=''; %just to pass this function
    case 1
        fext='.png';
    case 2
        fext='.fig';
    case 3
        fext='.eps';
    case 4
        fext='.jpg';
    otherwise
        error('add')
end

end %function