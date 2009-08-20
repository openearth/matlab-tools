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
Plus = DuneErosionSettings('get','Plus');
dz = 0.05;
ztemp = [z-dz, z+dz];

%% Correct Tp_t
% This step should not be necessary whereas it is already done in the main function
% (getDuneEroision).
if strcmp(Plus,'') && Tp_t~=12
    Tp_t = 12;
end

if strcmp(Plus,'') | strcmp(Plus,'-plus')
    %% Calculate x coordinates
    % for all z values of z+dz and z-dz
    [c_hs c_tp c_1 cp_hs cp_tp cp_w c_w] = DuneErosionSettings('get','c_hs','c_tp','c_1','cp_hs','cp_tp','cp_w','c_w');
    % c_hs = 7.6;
    % c_tp = 12;
    % c_1 = 0.4714;
    % cp_hs = 1.28;
    % cp_tp = 0.45;
    % cp_w = 0.56;
    % c_w = 0.0268;
    dxparab = (((-(ztemp-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(18))/c_1).^2-18) / ((c_hs/Hsig_t).^cp_hs*(c_tp/Tp_t).^cp_tp*(w/c_w).^cp_w);
elseif (strcmp(Plus,'-plusplus1') | strcmp(Plus,'-plusplus2') | strcmp(Plus,'-plusplus3') | strcmp(Plus,'-plusplus4') | strcmp(Plus,'-plusplus5'))
%---------------------------------------------------------------------------------------------- 
%---------------------------------DUROS plusplus (variant 1)-----------------------------------
%---------------------------------------------------------------------------------------------- 
    [c_hs c_tp c_1 c_2 cp_hs cp_tp cp_w c_w cp_d c_d d_t] = DuneErosionSettings('get','c_hs','c_tp','c_1','c_2','cp_hs','cp_tp','cp_w','c_w','cp_d','c_d','d');
    if strcmp(Plus,'-plusplus1')
        %option 1: only coeff. cfA&cfB
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = -0.415038533300256; %A not influenced by Hs/d if cfA=0
        cfB      = -1.8656390445347; %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus2')
        %option 2: only coeff. cfA&cfB
        A        = 0.3193;
        B        = 17.2098;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = -1.234048201; %A not influenced by Hs/d if cfA=0
        cfB      = -2.989234623; %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus3')
        %option 3: only coeff. d
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = -0.38;        %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus4')
        %option 4: only coeff. d
        A        = 0.4714;
        B        = 18.0000;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = -0.17;        %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus5')
        %option 5: only coeff. A&B
        A        = 1.2773;
        B        = 490.9486;
        a        = 1.28;
        b        = 0.45;
        c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0
    end

    %including depth contribution into the 'constants' C1, C2 and 'two'
    c_1 = A*(Hsig_t/d_t)^cfA;
    c_2 = B*(Hsig_t/d_t)^cfB;
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation for DUROS and D+; by using this expression, the profile will exactly cross (x0,0)
    depthcmpt        = (d_t/refdepth)^d;
    fallvelocitycmpt = (w/c_w)^cp_w;
    waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
    waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;
    
    dxparab = (((-(ztemp-WL_t).*(c_hs/Hsig_t)+c_1*sqrt(c_2))/c_1).^2-c_2) / (waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*depthcmpt);
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end

%% Calculate value of derivative
rcparab = (2*dz)./diff(dxparab,1,2);