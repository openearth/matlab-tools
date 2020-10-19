%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: accents2latex.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/accents2latex.m $
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

