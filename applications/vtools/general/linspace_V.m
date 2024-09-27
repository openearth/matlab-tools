%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
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