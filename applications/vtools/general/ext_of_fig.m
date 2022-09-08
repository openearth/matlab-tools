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

%We use this function for creating a movie. 
%If we have several types of figure, the movie
%will be with '.png' or '.jpg'.
if numel(fig_print)>1
    if any(fig_print==1)
        fig_print=1;
    elseif any(fig_print==4)
        fig_print=4;
    end
end

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