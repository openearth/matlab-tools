function varargout = reducepoints(varargin);
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

%#function reducepoints_v5
%#function reducepoints_v6

if versionnumber>=6.5
  fcn='reducepoints_v6';
else
  fcn='reducepoints_v5';
end
[varargout{1:max(1,nargout)}]=feval(fcn,varargin{:});

