function [xmax, z, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x)
%GETPARABOLICPROFILE    routine to create the parabolic DUROS (-plus) profile 
% 
% This routine returns the most seaward x-coordinate of the parabolic DUROS
% (-plus) profile. If variable x with x-coordinates exists, than also the
% y-coordinates of the parabolic profile will be given
% 
% Syntax:       [xmax, y, Tp_t] = getParabolicProfile(WL_t, Hsig_t, Tp_t, w, x0, x)
% 
% Input: 
%               WL_t      = Maximum storm surge level [m]
%               Hsig_t    = wave height [m]
%               Tp_t      = peak wave period [s]
%               d_t       = water depth [m] (derived from DUROS settings!)
%               w         = fall velocity of the sediment in water
%               x0        = x-location of the origin of the parabolic
%                               profile
%               x         = array with x-coordinates to create the
%                               parabolic profile on
% 
% Output:       Eventual output is stored in a variables xmax and z
% 
%   See also ParabolicProfileMain getFallVelocity
% 
% --------------------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY 
% Version:      Version 1.0, January 2008 (Version 1.0, January 2008)
% By:           <C.(Kees) den Heijer (email: C.denHeijer@tudelft.nl)>                                                            
% --------------------------------------------------------------------------

Plus                                    = DuneErosionSettings('get','Plus');
[c_hs c_tp c_w c_d c_1 c_2]             = DuneErosionSettings('get','c_hs','c_tp','c_w','c_d','c_1','c_2');
[cp_hs cp_tp cp_w cp_d cp_c1 cp_c2]     = DuneErosionSettings('get','cp_hs','cp_tp','cp_w','cp_d','cp_c1','cp_c2');
[d_t]                                   = DuneErosionSettings('get','d');
[xref]                                  = DuneErosionSettings('get','xref');
[xmax,y,waveheightcmpt,waveperiodcmpt,fallvelocitycmpt,depthcmpt] = deal([]);


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
    %xmax = x0 + 250*(Hsig_t/c_hs)^cp_hs*(c_w/w)^cp_w;


%% -------------------------------------------------------------------------------------------- 
%----------------------------------------DUROS plus-------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
elseif strcmp(Plus,'-plus')
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
    d_t = 25;
    c_d = 25;
    cp_d = 0;    %depthcmpt = 1
    %xmax = x0 + 250*(Hsig_t/c_hs)^cp_hs*(c_w/w)^cp_w;


%% --------------------------------------------------------------------------------------------
%-------------------------DUROS plusplus (for testing purposes only)---------------------------
%----------------------------------------------------------------------------------------------
elseif strcmp(Plus,'-plusplus') & exist('x','var') %&& ~isempty(x)
    %Option to include depth contribution into the 'constants' C1, C2 and 'two'
    c_1 = c_1*(Hsig_t/d_t)^cp_c1;
    c_2 = c_2*(Hsig_t/d_t)^cp_c2;
    two = c_1*sqrt(c_2);
    %xmax = x0 + 250  *  (Hsig_t/c_hs)^cp_hs * (c_w/w)^cp_w * (c_d/d_t)^0.5;
    %xmax = x0 + 250  *  (Hsig_t/c_hs)^cp_hs * (Tp_t/c_tp)^cp_tp  * (c_w/w)^cp_w * (c_d/d_t)^0.5;
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end

waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
fallvelocitycmpt = (w/c_w)^cp_w;
depthcmpt        = (d_t/c_d)^cp_d;    %Option to include depth contribution in the DUROS formulation (depthcmpt=1 for DUROS and D+)

y      = (c_1*sqrt(waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*depthcmpt*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
xmax   = x0 + xref  *  waveheightcmpt^-1*waveperiodcmpt^-1*fallvelocitycmpt^-1*depthcmpt^-1;

% round to 8 decimal digits to prevent rounding problems later on
y = roundoff(y, 8);

%% translate y to z
z = WL_t-y;

