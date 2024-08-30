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

function river=which_river(ident_pol_str)

if any(contains(ident_pol_str,{'BR','IJ','LE','NI','NR','PK','RH','WL','WA'}))
    river=1;
elseif any(contains(ident_pol_str,{'MA'}))
    river=2;
else
    error('A cell array is found with information about the name of each polygon. This is expected to contain the information of the branch and the river kilometer. However, the branch is not known.')
end

end %function