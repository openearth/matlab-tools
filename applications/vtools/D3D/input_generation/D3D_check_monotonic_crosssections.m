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
%checks if the cross-section is non-monotonic

%INPUT:
%   -path_cs: path to the cross-section definitions
%
%OUTPUT:
%   -       
%
%NOTES:
%   -

function D3D_check_monotonic_crosssections(path_cs_def)

[~,csdef]=S3_read_crosssectiondefinitions(path_cs_def,'file_type',2);

csdef_levels={csdef.levels};
non_monotonic_idx=find(cell2mat(cellfun(@isMonotonic,csdef_levels,'UniformOutput',false)));
if ~isempty(non_monotonic_idx)
    %I have not yet encountered this, hence, there may be a bug.
    warning('There are non-monotonic cross-sections:')
    nidx=numel(non_monotonic_idx);
    for kidx=1:nidx
        fprintf('Id: %s \n',csdef(non_monotonic_idx(kidx)).id)
    end
else
    fprintf('All cross-sections are monotonic \n')
end

end 


%%
%% FUNCTIONS
%%

function is_monotonic=isMonotonic(levels)

is_monotonic=any(diff(levels)<0);

end