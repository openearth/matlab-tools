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

function ascii_out=read_ascii(path_ascii)

fileID_in=fopen(path_ascii,'r');
net_in=textscan(fileID_in,'%s','delimiter','\r\n','whitespace','');
fclose(fileID_in);

ascii_out=net_in{1,1};

end %function