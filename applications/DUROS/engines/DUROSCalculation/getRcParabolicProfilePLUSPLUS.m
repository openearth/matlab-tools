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
%               z         = vector (n x 1) with z coordinates
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
Plus                                    = DuneErosionSettings('get','Plus');
[c_hs c_tp c_w c_d c_1 c_2]             = DuneErosionSettings('get','c_hs','c_tp','c_w','c_d','c_1','c_2');
[cp_hs cp_tp cp_w cp_d cp_c1 cp_c2]     = DuneErosionSettings('get','cp_hs','cp_tp','cp_w','cp_d','cp_c1','cp_c2');
[d_t]                                   = DuneErosionSettings('get','d');
dz     = 0.05;
ztemp  = [z-dz, z+dz];
[dxparab, rcparab,waveheightcmpt,waveperiodcmpt,fallvelocitycmpt,depthcmpt] = deal([]);


%% -------------------------------------------------------------------------------------------- 
%-------------------------------------------DUROS---------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
if strcmp(Plus,'')
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
    Tp_t = 12;
    c_tp = 12;
    cp_tp = 0;   %waveperiodcmpt = 1
    d_t = 25;
    c_d = 25;
    cp_d = 0;    %depthcmpt = 1


%% -------------------------------------------------------------------------------------------- 
%----------------------------------------DUROS plus-------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
elseif strcmp(Plus,'-plus')
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
    d_t = 25;
    c_d = 25;
    cp_d = 0;    %depthcmpt = 1


%% -------------------------------------------------------------------------------------------
%  -----------------------DUROS plusplus (for testing purposes only)--------------------------
%  -------------------------------------------------------------------------------------------
elseif strcmp(Plus,'-plusplus')
    %including depth contribution into the 'constants' C1, C2 and 'two'
    c_1 = c_1*(Hsig_t/d_t)^cp_c1;
    c_2 = c_2*(Hsig_t/d_t)^cp_c2;
    two = c_1*sqrt(c_2);
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end


%% Calculate x coordinates
% for all z values of z+dz and z-dz
waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
fallvelocitycmpt = (w/c_w)^cp_w;
depthcmpt        = (d_t/c_d)^cp_d;    %Option to include depth contribution in the DUROS formulation (depthcmpt=1 for DUROS and D+)
dxparab = (((-(ztemp-WL_t).*(c_hs/Hsig_t)+two)/c_1).^2-c_2) / (waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*depthcmpt);

%% Calculate value of derivative
rcparab = (2*dz)./diff(dxparab,1,2);