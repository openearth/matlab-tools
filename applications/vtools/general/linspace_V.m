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
%`linspace` with options

function v=linspace_V(v1,v2,np,varargin)

%% PARSE

if nargin<4
    type='lin';
else
    type=varargin{1,1};
end

% parin=inputParser;
% 
% addOptional(parin,'sedTrans',0,@isnumeric);
% 
% parse(parin,varargin{:});
% 
% sedTrans=parin.Results.sedTrans;

%% CALC

switch type
    case 'lin'
        v=linspace(v1,v2,np);
    case 'log10'
        v=10.^(linspace(log10(v1),log10(v2),np));
    otherwise
        error('do')
end %swithc

end %function