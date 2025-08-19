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
%Factor for converting time units. Given an input and
%optionally an output unit, it provides the factor to
%convert them. 
%
%INPUT:
%   -str_in  = input unit [char]
%   -str_out = output unit [char] (optional)
%
%OUTPUT
%   -fact_out = factor for converting time [double(1,1)]
%
%E.G.:
%time_factor('H','S')
%
%ans =
%
%        3600

function fact_out=time_factor(str_in,str_out)

%% PARSE

if nargin<2
    str_out='S';
end

%% CALC

fact_1=fcn_tim(str_in);
fact_2=fcn_tim(str_out);

fact_out=fact_1/fact_2;

end %function

%%
%% FUNCTIONS
%%

function fact_1=fcn_tim(str)

switch str
    case {'S','seconds'}
        fact_1=1;
    case {'M','minutes'}
        fact_1=60;
    case {'H','hours'}
        fact_1=3600;
    otherwise
        error('Add')
end

end