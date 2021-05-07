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
%get absolute limits

function clim=absolute_limits(vperp)

aux1=max(abs(min(vperp(:))),abs(max(vperp(:))));
if isnan(aux1)
    clim=[-1,1];
else
    clim=[-aux1,aux1];
end

end %function
