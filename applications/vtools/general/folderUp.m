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
%Get path of one folder up from a given one

function [folder2sendup_win,folder_last]=folderUp(folder2send_win)

if strcmp(folder2send_win(end),'\')
    folder2send_win(end)='';
end
pathsplit=regexp(folder2send_win,'\','split');
npath=numel(pathsplit);
folder2sendup_win=strcat(pathsplit{1,1},'\');
for kpath=2:npath-1
    folder2sendup_win=strcat(folder2sendup_win,pathsplit{1,kpath},'\');
end
folder_last=pathsplit{1,end};

end %function