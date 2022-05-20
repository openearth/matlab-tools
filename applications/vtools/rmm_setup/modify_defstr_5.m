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

function modify_defstr_5(path_file,start_time,stop_time)

%%

fileo=read_ascii(path_file);
nl=numel(fileo);
for kl=1:nl
    [ini,fin]=regexp(fileo{kl,1},'''\d+/\d+/\d+;\d+:\d+:\d+''');
    if ~isempty(ini)
        fileo{kl,1}(ini:fin)=sprintf('''%04d/%02d/%02d;%02d:%02d:%02d''',year(start_time),month(start_time),day(start_time),hour(start_time),minute(start_time),second(start_time));
    end
end
writetxt(path_file,fileo,'check_existing',0);

end %function