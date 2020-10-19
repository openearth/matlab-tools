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
%writes message to log file and screen with time stamp

function messageOut(fid,str)

str_time=sprintf('%s %s',datestr(datetime('now')),str);
str_time=strrep(str_time,'\','/');

if isnan(fid)==0
str_file=strcat(str_time,'\r\n');
fprintf(fid,str_file);
end

str_window=strcat(str_time,'\n');
fprintf(str_window);

