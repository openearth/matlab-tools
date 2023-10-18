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
%Check if fields in structure exist
%
%INPUT:
%   -stu = structure to check [struct]
%   -fn  = fieldnames to check [cell]
%
%OPTIONAL:
%   -

function err=check_fields_struct(stu,fn,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'break',1)

parse(parin,varargin{:})

do_br=parin.Results.break;

%% CALC

fns=fieldnames(stu);
bol_m=ismember(fn,fns);
err=0;
if ~all(bol_m)
    err=1;
    display_missing(bol_m,fn)
    switch do_br
        case 0
            warning('See above.')
        case 1
            error('See above.')
    end
    
end

end %function

%%

function display_missing(bol_m,fn)

fnd=fn(~bol_m);
nd=numel(fnd);
messageOut(NaN,'Expected field does not exist:')
for kd=1:nd
    fprintf('  %s \n',fnd{kd})
end

end %function