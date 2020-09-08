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

function kl2=search4lineinascii(xml_in,search4,stopsearch)

notfound=true;
kl2=1;
while notfound
    search4p=sprintf('(%s)',search4);
    tok2=regexp(xml_in{kl2,1},search4p,'tokens');
    if ~isempty(tok2)
        notfound=false;
    else
        kl2=kl2+1;
    end

    %prevent infinite
    stopsearchp=sprintf('(%s)',stopsearch);
    tokt=regexp(xml_in{kl2,1},stopsearchp,'tokens');
    if ~isempty(tokt)
        notfound=false;
    end
end %while

end %function