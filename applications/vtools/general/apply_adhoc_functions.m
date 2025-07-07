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

function apply_adhoc_functions(in_p)

if ~isfield(in_p,'function_handles')
    return
end
function_handles=in_p.function_handles;

if ~iscell(function_handles)
    error('Function handles should be a cell array')
end

nf=numel(function_handles);

for kf=1:nf
    function_handles{kf}();
end %nf

end %function