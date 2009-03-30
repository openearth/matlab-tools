function [xmax, y, Tp_t] = getParabolicProfile(Hsig_t, Tp_t, w, x0, x)
%GETPARABOLICPROFILE    routine to create the parabolic DUROS (-plus) profile 
% 
% This routine returns the most seaward x-coordinate of the parabolic DUROS
% (-plus) profile. If variable x with x-coordinates exists, than also the
% y-coordinates of the parabolic profile will be given
%
% Syntax:       [xmax, y, Tp_t] = getParabolicProfile(Hsig_t, Tp_t, w, x0, x)
%
% Input: 
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%               x0        = x-location of the origin of the parabolic
%                               profile
%               x         = array with x-coordinates to create the
%                               parabolic profile on
%
% Output:       Eventual output is stored in a variables xmax and y
%
%   See also getFallVelocity
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

Plus = DuneErosionSettings('get','Plus');

%%
[xmax, y] = deal([]);
two = 0.4714*sqrt(18); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
xmax = x0 + 250*(Hsig_t/7.6)^1.28*(0.0268/w)^.56;
if strcmp(Plus,'')
    if exist('x','var') && ~isempty(x)
        y = (0.4714*sqrt((7.6/Hsig_t)^1.28*(w/.0268)^.56*(x-x0)+18)-two) / (7.6/Hsig_t);
    end
elseif strcmp(Plus,'-plus')
    if exist('x','var') && ~isempty(x)
        y = (0.4714*sqrt((7.6/Hsig_t)^1.28*(12/Tp_t)^.45*(w/.0268)^.56*(x-x0)+18)-two) / (7.6/Hsig_t);
    end
else
    error('Warning: variable "Plus" should be either '''' or ''-plus''')
end

% round to 8 decimal digits to prevent rounding problems later on
y = roundoff(y, 8);