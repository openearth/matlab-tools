%--------------------------------------------------------------------------
%
% EclMatrix: Transformation of equatorial to ecliptical coordinates
%
% Input:
%   Mjd_TT    Modified Julian Date (Terrestrial Time)
% 
% Output:
%   EclMat    Transformation matrix
%
% Last modified:   2015/08/12   M. Mahooti
%
%--------------------------------------------------------------------------
function EclMat = EclMatrix(Mjd_TT)

EclMat = R_x( MeanObliquity(Mjd_TT) );