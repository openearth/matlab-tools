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

function C_out=convert_friction(conv,C_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'g',9.81,@isnumeric);

parse(parin,varargin{:});

g=parin.Results.g;

%% CALC

switch conv
    case 'C2Cf'
        C_out=g./C_in.^2;
    case 'Cf2C'
        C_out=sqrt(g/C_in);
    otherwise
        error('do')
end

end