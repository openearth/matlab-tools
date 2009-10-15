function w = getFallVelocity(D50, a, b, c)
%GETFALLVELOCITY    routine to compute fall velocity of sediment in water 
% 
% This routine returns the fall velocity of sediment with grain size D50 in
% water
%
% Syntax:       w         = getFallVelocity(D50, a, b, c)
%
% Input: 
%               D50       = Grain size D50 [m]
%               a         = coefficient in fall velocity formulation
%               b         = coefficient in fall velocity formulation
%               c         = coefficient in fall velocity formulation
%
% Output:       Eventual output is stored in a variable w 
%
%   See also 
% 

% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.1, January (Version 1.0, December 2007)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

%% check input/ set defaults
getdefaults('D50', 225e-6, 1);

if nargin <= 1
    [a, b, c] = deal(.476,  2.18,   3.226); %default values for the Dutch situation
end    

%% fall velocity formulation
w = 1./(10.^(a*(log10(D50)).^2+b*log10(D50)+c));