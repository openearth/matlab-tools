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

function modify_rtcruntimeconfig(path_xml,start_time,stop_time)

xml_in=read_ascii(path_xml);
nl=numel(xml_in);
for kl=1:nl
    tok=regexp(xml_in{kl,1},'(<startDate)','tokens');
    if ~isempty(tok)
        xml_in{kl,1}=sprintf('      <startDate date="%04d-%02d-%02d" time="%02d:%02d:%02d" />',year(start_time),month(start_time),day(start_time),hour(start_time),minute(start_time),second(start_time));
    end
    
    tok=regexp(xml_in{kl,1},'(<endDate)','tokens');
    if ~isempty(tok)
        xml_in{kl,1}=sprintf('      <endDate date="%04d-%02d-%02d" time="%02d:%02d:%02d" />',year(stop_time),month(stop_time),day(stop_time),hour(stop_time),minute(stop_time),second(stop_time));
    end
end
writetxt(path_xml,xml_in,'check_existing',0)

end %function