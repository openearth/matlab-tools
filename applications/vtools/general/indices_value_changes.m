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
%Get the indices of the first and last positions in a vector in which a
%value changes. This is useful for reducing a vector in which
%interpolation happens for the given values. The repeated values do not add
%information.
%
%E.G.
% val=[8 8 8 8 8 7 7 7 7 7 10 10 10 5 5 5 5 5 5 5 5 5 5 8 8 8 8 8 8 8 8 8 8 8 8 8];
% idx=[1,5,6,10,11,13,14,23,24,36];
%
%
% val=[5 5 5 5 5 5 ];
% idx=[1,6];

function [idx]=indices_value_changes(val)

if isempty(val)
    idx=[];
    return
end

% Find where values change
changeIdx = find(diff(val) ~= 0);

% Compute starts and ends of blocks
starts = [1, changeIdx + 1];
ends   = [changeIdx, numel(val)];

% Interleave starts and ends
idx = reshape([starts; ends], 1, []);

end %function