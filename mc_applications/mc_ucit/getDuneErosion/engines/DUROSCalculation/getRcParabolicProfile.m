function rcparab = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z)
%GETRCPARABOLICPROFILE calculates the derivative of the parabolic profile given input and height
%
% This routine returns the derivative of the parabolic profile given the input
% WL_t, Hsig_t, Tp_t, w and z
%
% Syntax:
% rcparab = getRcParabolicProfile(WL_t, Hsig_t, Tp_t, w, z);
%
% Input:
%               WL_t      = Water level [m] ('Rekenpeil')
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               w         = fall velocity of the sediment in water
%		z	  = vector (n x 1) with z coordinates
%
% Output:       
%		rcparab   = vector the same size as z with
%				values of the derivative of the parabolic
%				profile at the heights specified in z
%
%   See also getParabolicProfile getIterationBounderies
%
% --------------------------------------------------------------------------
% Copyright (c) Deltares 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.0, November 2008 (Version 1.0, November 2008)
% By:           <Pieter van Geer (email: Pieter.vanGeer@deltares.nl)>
% --------------------------------------------------------------------------

%% initiate variables
Plus = DuneErosionSettings('get','Plus');
dz = 0.05;
ztemp = [z-dz, z+dz];

%% Correct Tp_t
% This step should not be necessary whereas it is already done in the main function
% (getDuneEroision).
if strcmp(Plus,'') && Tp_t~=12
    Tp_t = 12;
end

%% Calculate x coordinates
% for all z values of z+dz and z-dz
dxparab = (((-(ztemp-WL_t).*(7.6/Hsig_t)+0.4714*sqrt(18))/0.4714).^2-18) / (((7.6/Hsig_t).^1.28)*((12/Tp_t).^0.45)*((w/0.0268).^0.56));

%% Calculate value of derivative
rcparab = (2*dz)./diff(dxparab,1,2);