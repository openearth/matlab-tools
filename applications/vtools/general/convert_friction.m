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
%

function Cf=convert_friction(conv,C_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81,@isnumeric);

parse(parin,varargin{:});

g=parin.Results.g;

%% CALC

switch conv
    case 'C2Cf'
        Cf=g./C_in.^2;
    otherwise
        error('do')
end

end