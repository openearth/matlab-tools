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
%   -Three lines per variable.
%   -First line with variable name. 
%       -Double colon (::) separates module name from variable name.
%   -Second line with variable type.
%       -Last parenthesis has dimensions.
%   -Third with value(s).
%       -Dollar symbol and integer for variable number followed by equal sign and values. 
%       -If multiple values, in parenthesis with comma as separator.
%
%E.G.
%m_flow::voltot
%type = REAL(8) (40)
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

lin=fgetl(fid); 
[var_name,mod_name]=fcn_variable_name(lin);

lin=fgetl(fid); 
[size_array,str_type]=fcn_size_array(lin);

lin=fgetl(fid); 

tok_num=fcn_variable_values(lin,sep,str_type,size_array);

data.(mod_name).(var_name)=tok_num;

end %function

%%
%% FUNCTION
%%

function [size_array,str_type]=fcn_size_array(lin)

tok=regexp(lin,'=','split');
if numel(tok)~=2
    error('One and only one equal is expected: %s',lin);
end %error
%remove type
str_aux=tok{1,2};
tok=regexp(str_aux,'([^\d\s]+\(\d*\))','tokens'); %INTEGER(4)
if isempty(tok)
    tok=regexp(str_aux,'([^\d\s]+\*\d*)','tokens'); %character*100 (40) -> character*100
%     tok=regexp(str_aux,'([^\d\(\)\s\*]+)','tokens'); %character*100 (40) -> character
end
%cycle structures
% if isempty(tok)
%     if strcmp(str_aux(2:5),'Type')
%         lin=fgetl(fid)
%     end
% end
if isempty(tok)
    error('variable type not captured: %s',lin)
end
if numel(tok{1,1})~=1
    error('Only one type is expected: %s',lin)
end
str_type=tok{1,1}{1,1};
str_aux=strrep(str_aux,str_type,'');
%remove PTR
str_aux=strrep(str_aux,'PTR TO ->','');
%remove parenthesis
str_aux=strrep(str_aux,'(','');
str_aux=strrep(str_aux,')','');
%remove spaces
str_size=deblank(strtrim(str_aux)); 
tok=strsplit(str_size,',');
dim=numel(tok);
size_array=cellfun(@(X)str2double(X),tok);
%change 0:1 to 2 (type = REAL(8) (0:1,3920))
bol_b1=cellfun(@(X)contains(X,':'),tok); 
size_array_b1=cellfun(@(X)diff(str2double(strsplit(X,':')))+1,tok,'UniformOutput',false); %0:1 -> {0} {1} -> [0,1] -> 2
size_array(bol_b1)=cell2mat(size_array_b1);
%if it is empty, it is read as single NaN. Hence, dimension 1. 
if size_array==0
    size_array=1;
end
%get size
if isempty(str_size) 
    size_array=[1,1];
elseif dim==1
    size_array=[size_array,1];
end
%check
if any(isnan(size_array))
    size_array = NaN; 
    warning('fcn_size_array: something needs to be processed')
end

end %function

%%

function tok_num=fcn_variable_values(lin,sep,str_type,size_array)

if isnan(size_array)
    tok_num = NaN; 
    return
end

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
if contains(str_type,'character')
    tok_num=NaN(size_array); %characters are not yet processed
elseif contains(str_type,'LOGICAL')
    if numel(tok)>1
        error('Dealing with vector of logicals needs to be added: %s',str_val)
    end
    if strcmp(strtrim(tok{1,1}),'.FALSE.') 
        tok_num=false;
    elseif strcmp(strtrim(tok{1,1}),'.TRUE.')
        tok_num=true;
    else
        %integer because not alocated
        tok_num=NaN;
    end
else
    tok_num=cellfun(@(X)str2double(X),tok);
end

tok_num=reshape(tok_num,size_array);

end %function

%%

function [var_name,mod_name]=fcn_variable_name(lin)

tok=regexp(lin,'::','split');
if numel(tok)~=2
    error('Two char are expected separated by a double colon (e.g., m_flow::epsmaxlevm) but this is read: %s',lin);
end %error
mod_name=tok{1,1};
var_name=tok{1,2};

end %function