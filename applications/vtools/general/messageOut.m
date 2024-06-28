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

function messageOut(fid,str,varargin)

%% PARSE

if nargin<3
    n_block=0;
else
    n_block=varargin{1};
end

%% CALC

str=strrep(str,'%','%%');
str_time=sprintf('%s %s',datestr(datetime('now')),str);
str_time=strrep(str_time,'\','/');
str_block=repmat('-',1,42);

if isnan(fid)==0
    str_file=strcat(str_time,'\r\n');
    for kb=1:n_block
        fprintf(fid,strcat(str_block,'\r\n'));
    end
    fprintf(fid,str_file);
    for kb=1:n_block
        fprintf(fid,strcat(str_block,'\r\n'));
    end
end

str_window=strcat(str_time,'\n');
for kb=1:n_block
    fprintf(strcat(str_block,'\n'));
end
fprintf(str_window);
for kb=1:n_block
    fprintf(strcat(str_block,'\n'));
end

end %function

