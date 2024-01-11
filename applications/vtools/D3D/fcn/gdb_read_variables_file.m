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
%Reads data from a GDB output file. The format of the file is:
%   -Two lines per variable.
%   -First line with variable name. 
%       -Double colon (::) separates module name from variable name.
%   -Second with value(s).
%       -Dollar symbol and integer for variable number followed by equal sign and values. 
%       -If multiple values, in parenthesis with comma as separator.
%
%E.G.
%m_flow::voltot
%$312 = (12523863.333103318, 23863.333103317767, -7409.2358047277767, 16237081.164116737, 16205808.595208693, 31272.568908045545, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

function data=gdb_read_variables_file(fpath_in,varargin)


%% PARSE

parin=inputParser;

addOptional(parin,'separator',',');

parse(parin,varargin{:});

sep=parin.Results.separator;

%% CALC

fid=fopen(fpath_in,'r');

data=struct();

while ~feof(fid)

    %we expect here to have a variable name
    data=read_line(fid,data,sep);
    
end %while

fclose(fid);

end %function

%% 
%% FUNCTIONS
%%

function data=read_line(fid,data,sep)

%% PARSE


%% CALC

%variable name
lin=fgetl(fid); 
tok=regexp(lin,'::','split');
if numel(tok)~=2
    error('Two char are expected separated by a double colon (e.g., m_flow::epsmaxlevm) but this is read: %s',lin);
end %error
mod_name=tok{1,1};
var_name=tok{1,2};

%variable value
lin=fgetl(fid); 
tok=regexp(lin,'=','split');
if numel(tok)~=2
    error('One and only one equal is expected: %s',lin);
end %error
str_val=tok{1,2};

%remove parenthesis in case of vector
str_val=strrep(str_val,') (',','); 
str_val=strrep(str_val,'(',''); 
str_val=strrep(str_val,')',''); 

tok=regexp(str_val,sep,'split');
%deal with logicals
if strcmp(tok{1,1},'.FALSE.') 
    tok_num=false;
    if numel(tok)>1
        error('Dealing with vector of logicals needs to be added: %s',str_val)
    end
elseif strcmp(tok{1,1},'.TRUE.')
    tok_num=true;
    if numel(tok)>1
        error('Dealing with vector of logicals needs to be added: %s',str_val)
    end
else
    tok_num=cellfun(@(X)str2double(X),tok);
end

%add
% fn=fieldnames(data);
% if ismember(mod_name,fn)
    data.(mod_name).(var_name)=tok_num;
% else
%     data.
% end

end %function