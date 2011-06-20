function Active=avi_active,
% AVI_ACTIVE indicates whether an AVI creation process is active
%   AVI_ACTIVE returns 1 if an AVI creation process is active
%   and 0 otherwise

global AVI_animation
Active=isstruct(AVI_animation);
