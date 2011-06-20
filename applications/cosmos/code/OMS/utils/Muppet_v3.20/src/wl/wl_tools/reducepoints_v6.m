function I = reducepoints(thresh,X,Y,Z);
%REDUCEPOINTS Filters a set points using a distance threshold.
%      I = REDUCEPOINTS(Thresh_Dist,X,Y,Z)
%      returns an array I of indices of points that form
%      together a set of points that are mutually separated
%      by at least a distance Thresh_Dist. The function
%      works in 1 (X), 2 (X and Y) and 3 (X, Y and Z) dimensions.
%
%      See also: REDUCEPNTSQ

% Copyright (c) 18/5/2000 by H.R.A. Jagers
%               WL | Delft Hydraulics, The Netherlands

%#mex
error('Missing MEX-file REDUCEPOINTS');
