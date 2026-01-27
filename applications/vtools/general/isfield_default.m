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
%Assing default value to structure if it does not exist.

function out=isfield_default(struct,var,def,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'replace_empty',false);
addOptional(parin,'output','structure');

parse(parin,varargin{:});

replace_empty=parin.Results.replace_empty;
output=parin.Results.output;

%%

%I am breaking backward compatibility here. Repare the caller when found where. 
% if nargin<4
%     replace_empty=false;
% else
%     replace_empty=varargin{1,1};
% end

%% CALC
if ~isfield(struct,var)
    struct.(var)=def;
end

if replace_empty && isempty(struct.(var))
    struct.(var)=def;
end

switch output
    case 'structure'
        out=struct;
    case 'array'
        out=struct.(var);
    otherwise
        error('Unknown output type %s',output);
end

end %function