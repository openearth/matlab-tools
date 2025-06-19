%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18923 $
%$Date: 2023-04-28 11:11:01 +0200 (Fri, 28 Apr 2023) $
%$Author: chavarri $
%$Id: D3D_diff_val.m 18923 2023-04-28 09:11:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_diff_val.m $
%
%Reorders the columns of matrix `y` to match the column order of matrix `x`,
%assuming they contain the same data (possibly permuted), including handling:
%   - Approximate equality due to floating-point rounding
%   - NaN values (NaNs are matched positionally)
%
%INPUT:
%     x         = Reference matrix of size [m x n]
%     y         = Matrix of the same size and content (permuted columns)
%     precision = (optional) Scaling factor to control tolerance.
%                 Default is 1e12, which corresponds to ~12 decimal digits.
%
%OUTPUT:
%     y_sorted  = Matrix `y` with columns reordered to match `x`
%     idx       = 
%
%E.G.:
%x = [1 NaN 2; 3 4 NaN];
%y = [2 1 NaN; NaN 3 4];
%y_sorted = reorder_columns_like(x, y);

function [y_sorted,idx] = reorder_matrix(x, y, precision)

%% PARSE

if nargin < 3
    precision = 10^order(x(1));
end

nan_marker = -999999999;  % Must not exist in rounded data

%% CALC

%Round to specified precision
xr = round(x * precision);
yr = round(y * precision);

%Replace NaNs with a unique marker
xr(isnan(x)) = nan_marker;
yr(isnan(y)) = nan_marker;

%Transpose for column-wise comparison
[~, idx] = ismember(xr', yr', 'rows');

%Check for unmatched columns
if any(idx == 0)
    error('Some columns in x were not matched in y (even with tolerance and NaN handling).');
end

%Reorder
y_sorted = y(:, idx);

end %function