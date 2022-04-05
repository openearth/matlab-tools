%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17748 $
%$Date: 2022-02-10 07:51:59 +0100 (Thu, 10 Feb 2022) $
%$Author: chavarri $
%$Id: absolute_limits.m 17748 2022-02-10 06:51:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%maximum difference

function [absd,eq]=max_diff(a,b,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'display',1)
addOptional(parin,'tol',1e-16)
addOptional(parin,'break',0)

parse(parin,varargin{:})

do_disp=parin.Results.display;
tol=parin.Results.tol;
do_break=parin.Results.break;

if any(size(a)~=size(b))
    error('input arrays have different dimension')
end

%% CALC

d=a-b;
absd=max(abs(d(:)));

%% DISP

if absd<tol
    eq=1;
    if do_disp
        fprintf('They are equal \n')
    end
else
    eq=0;
    if do_disp
        fprintf('They are NOT equal \n')
    end
    if do_break
        error('see above')
    end
end

end %function
