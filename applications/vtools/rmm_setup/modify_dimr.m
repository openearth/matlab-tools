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

function modify_dimr(path_xml,start_time,stop_time)

xml_in=read_ascii(path_xml);
nl=numel(xml_in);
for kl=1:nl
    tok=regexp(xml_in{kl,1},'<time>(\d+) (\d+) (\d+)</time>','tokens');
    if ~isempty(tok)
        xml_in{kl,1}=sprintf('        <time>%s %s %.0f</time>',tok{1,1}{1,1},tok{1,1}{1,2},seconds(stop_time-start_time));
    end
end
writetxt(path_xml,xml_in,'check_existing',0)

end %function