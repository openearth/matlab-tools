%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20106 $
%$Date: 2025-03-24 14:38:05 +0100 (Mon, 24 Mar 2025) $
%$Author: chavarri $
%$Id: fig_1D_01.m 20106 2025-03-24 13:38:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/fig_1D_01.m $
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