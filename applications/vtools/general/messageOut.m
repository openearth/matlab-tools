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
%Writes message to log file and screen with time stamp.

function messageOut(fid,str,varargin)

%% PARSE

if nargin<3
    n_block=0;
    do_time_string=true;
elseif nargin<4
    n_block=varargin{1};
    do_time_string=true;
else
    n_block=varargin{1};
    do_time_string=varargin{2};
end

%% CALC

str=strrep(str,'%','%%');
str=fcn_add_timestamp(str,do_time_string);
str=strrep(str,'\','/');

str_block=repmat('-',1,42);

if ~isnan(fid)
    str_file=strcat(str,'\r\n');
    for kb=1:n_block
        fprintf(fid,strcat(str_block,'\r\n'));
    end
    fprintf(fid,str_file);
    for kb=1:n_block
        fprintf(fid,strcat(str_block,'\r\n'));
    end
end

str_window=strcat(str,'\n');
for kb=1:n_block
    fprintf(strcat(str_block,'\n'));
end
fprintf(str_window);
for kb=1:n_block
    fprintf(strcat(str_block,'\n'));
end

end %function

%%
%% FUNCTIONS
%%

function str=fcn_add_timestamp(str,do_time_string)

if ~do_time_string
    return
end

str=sprintf('%s %s',datestr(datetime('now')),str);

end %function