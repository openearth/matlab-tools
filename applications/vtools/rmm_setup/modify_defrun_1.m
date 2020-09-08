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

function modify_defrun_1(path_file,start_time,stop_time)

%%

fileo=read_ascii(path_file);
[ini,fin]=regexp(fileo{1,1},'''\d+/\d+/\d+;\d+:\d+:\d+'' et ''\d+/\d+/\d+;\d+:\d+:\d+''');
fileo{1,1}(ini:fin)=sprintf('''%04d/%02d/%02d;%02d:%02d:%02d'' et ''%02d/%02d/%02d;%02d:%02d:%02d''',year(start_time),month(start_time),day(start_time),hour(start_time),minute(start_time),second(start_time),year(stop_time),month(stop_time),day(stop_time),hour(stop_time),minute(stop_time),second(stop_time));
writetxt(path_file,fileo,'check_existing',0);

end %function