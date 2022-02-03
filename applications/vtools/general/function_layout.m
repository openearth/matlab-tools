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
%This does A and B
%
%INPUT:
%
%OUTPUT:
%

function 

%% PARSE

parin=inputParser;

addOptional(parin,'sedTrans',0,@isnumeric);

parse(parin,varargin{:});

sedTrans=parin.Results.sedTrans;

end %function