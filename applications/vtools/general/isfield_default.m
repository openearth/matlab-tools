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

function struct=isfield_default(struct,var,def,varargin)

%% PARSE

if nargin<4
    replace_empty=false;
else
    replace_empty=varargin{1,1};
end

%% CALC
if ~isfield(struct,var)
    struct.(var)=def;
end

if replace_empty && isempty(struct.(var))
    struct.(var)=def;
end

end %function