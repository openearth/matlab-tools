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
%               d_t       = water depth [m]
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

Plus = DuneErosionSettings('get','Plus');

%%
[c_hs c_tp c_1 c_2 cp_hs cp_tp cp_w c_w cp_d c_d d_t] = DuneErosionSettings('get','c_hs','c_tp','c_1','c_2','cp_hs','cp_tp','cp_w','c_w','cp_d','c_d','d');

if isnan(c_2)
    c_2 = 18;
end
if isnan(c_d)
    c_d = 20;
end
if isnan(cp_d)
    cp_d = 1;
end

[xmax, y] = deal([]);
two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation; by using this expression, the profile will exactly cross (x0,0)
xmax = x0 + 250*(Hsig_t/c_hs)^cp_hs*(c_w/w)^cp_w;
%---------------------------------------------------------------------------------------------- 
%-------------------------------------------DUROS---------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
if strcmp(Plus,'')
    if exist('x','var') && ~isempty(x)
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(w/c_w)^cp_w*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
    end
%---------------------------------------------------------------------------------------------- 
%----------------------------------------DUROS plus-------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
elseif strcmp(Plus,'-plus')
    if exist('x','var') && ~isempty(x)
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(c_tp/Tp_t)^cp_tp*(w/c_w)^cp_w*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
    end
%---------------------------------------------------------------------------------------------- 
%---------------------------------DUROS plusplus (variant 1)-----------------------------------
%---------------------------------------------------------------------------------------------- 
elseif (strcmp(Plus,'-plusplus1') | strcmp(Plus,'-plusplus2') | strcmp(Plus,'-plusplus3') | strcmp(Plus,'-plusplus4') | strcmp(Plus,'-plusplus5')) & exist('x','var') %&& ~isempty(x)
    if strcmp(Plus,'-plusplus1')
        %option 1: only coeff. cfA&cfB                                             %%option 1: only coeff. cfA&cfB
        A        = 0.4714;							   %A        = 0.4714;
        B        = 18.0000;							   %B        = 18.0000;
        a        = 1.28;							   %a        = 1.28;
        b        = 0.45;							   %b        = 0.45;
        c        = 0.56;							   %c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0			   %d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;								   %refdepth = 25;
        cfA      = -0.415038533300256; %A not influenced by Hs/d if cfA=0	   %cfA      = -0.415038533300256; %A not influenced by Hs/d if cfA=0
        cfB      = -1.8656390445347; %B not influenced by Hs/d if cfB=0		   %cfB      = -1.8656390445347; %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus2')						   
        %option 2: only coeff. cfA&cfB						   %%option 2: only coeff. cfA&cfB
        A        = 0.3193;							   %A        = 0.3193;
        B        = 17.2098;							   %B        = 17.2098;
        a        = 1.28;							   %a        = 1.28;
        b        = 0.45;							   %b        = 0.45;
        c        = 0.56;							   %c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0			   %d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;								   %refdepth = 25;
        cfA      = -1.234048201; %A not influenced by Hs/d if cfA=0		   %cfA      = -1.234048201; %A not influenced by Hs/d if cfA=0
        cfB      = -2.989234623; %B not influenced by Hs/d if cfB=0		   %cfB      = -2.989234623; %B not influenced by Hs/d if cfB=0
        %overrule xmax
%        xmax = x0 + 250  *  (Hsig_t/c_hs) * (Tp_t/c_tp)^cp_tp  * (c_w/w)^cp_w * ((refdepth/d_t)^d)^0.5;
    elseif strcmp(Plus,'-plusplus3')						   
        %option 3: only coeff. d						   %%option 3: only coeff. d
        A        = 0.4714;							   %A        = 0.4714;
        B        = 18.0000;							   %B        = 18.0000;
        a        = 1.28;							   %a        = 1.28;
        b        = 0.45;							   %b        = 0.45;
        c        = 0.56;							   %c        = 0.56;
        d        = -0.38;  %depthcomponent=1 if d=0				   %d        = -0.38;  %depthcomponent=1 if d=0
        refdepth = 25;								   %refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0		   %cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0		   %cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus4')						   
        %option 4: only coeff. d						   %%option 4: only coeff. d
        A        = 0.4714;							   %A        = 0.4714;
        B        = 18.0000;							   %B        = 18.0000;
        a        = 1.28;							   %a        = 1.28;
        b        = 0.45;							   %b        = 0.45;
        c        = 0.56;							   %c        = 0.56;
        d        = -0.17;        %depthcomponent=1 if d=0			   %d        = -0.17;        %depthcomponent=1 if d=0
        refdepth = 25;								   %refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0		   %cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0		   %cfB      = 0;            %B not influenced by Hs/d if cfB=0
    elseif strcmp(Plus,'-plusplus5')
        %option 5: only coeff. A&B                                                 %option 5: only coeff. A&B                                      
        A        = 1.2773;						           % A        = 1.2773;
        B        = 490.9486;						           % B        = 490.9486;
        a        = 1.28;						           % a        = 1.28;
        b        = 0.45;						           % b        = 0.45;
        c        = 0.56;						           % c        = 0.56;
        d        = 0;            %depthcomponent=1 if d=0		           % d        = 0;            %depthcomponent=1 if d=0
        refdepth = 25;							           % refdepth = 25;
        cfA      = 0;            %A not influenced by Hs/d if cfA=0	           % cfA      = 0;            %A not influenced by Hs/d if cfA=0
        cfB      = 0;            %B not influenced by Hs/d if cfB=0	           % cfB      = 0;            %B not influenced by Hs/d if cfB=0
    end
    %including depth contribution into the 'constants' C1, C2 and 'two'
    c_1 = A*(Hsig_t/d_t)^cfA;
    c_2 = B*(Hsig_t/d_t)^cfB;
    two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation for DUROS and D+; by using this expression, the profile will exactly cross (x0,0)
    depthcmpt        = (d_t/refdepth)^d;
    fallvelocitycmpt = (w/c_w)^cp_w;
    waveperiodcmpt   = (c_tp/Tp_t)^cp_tp;
    waveheightcmpt   = (c_hs/Hsig_t)^cp_hs;

    y = (c_1*sqrt(waveheightcmpt*waveperiodcmpt*fallvelocitycmpt*depthcmpt*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
    xmax = x0 + 250  *  (Hsig_t/c_hs) * (Tp_t/c_tp)^cp_tp  * (c_w/w)^cp_w * (refdepth/d_t)^0.5;

%---------------------------------------------------------------------------------------------- 
%--------------------------------------ALTERNATIVES-------------------------------------------- 
%---------------------------------------------------------------------------------------------- 
elseif strcmp(Plus,'-plusplus6') & exist('x','var') %&& ~isempty(x)

        gammabr = 0.625772953;  %gammabr = 0.6;   
        alfacf  = -0.680840129; %alfa    = -0.5   
        betacf  = 0.696954813;  %beta    = 0.6614;
        mucf    = 11.2607378;   %mu      = 16;    
        kappacf = 21.80640954;  %kappa   = 12;    

        %including depth contribution into the 'constants' C1, C2 and 'two'
        c_1 = alfacf*min(Hsig_t/d_t,gammabr)+betacf;
        c_2 = mucf*min(Hsig_t/d_t,gammabr)+kappacf;
        two = c_1*sqrt(c_2); % term in formulation which is 2 by approximation for D+; by using this expression, the profile will exactly cross (x0,0)
        
        xmax = x0 + 250*(Hsig_t/c_hs)^cp_hs*(c_w/w)^cp_w;
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(c_tp/Tp_t)^cp_tp*(w/c_w)^cp_w*(x-x0)+c_2)-two) / (c_hs/Hsig_t);

    %DUROS plusplus (variant 2)
elseif strcmp(Plus,'-plusplus7') & exist('x','var') && ~isempty(x)

    
        gammabr = 0.62;
        cp_d    = 0;
        depthcomponent = (d_t/c_d)^cp_d
    
        y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(c_tp/Tp_t)^cp_tp*(w/c_w)^cp_w*depthcomponent*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
        %y = (c_1*sqrt((c_hs/Hsig_t)^cp_hs*(c_tp/Tp_t)^cp_tp*(w/c_w)^cp_w*(d/c_d)^cp_d*(x-x0)+c_2)-two) / (c_hs/Hsig_t);
else
    error('Warning: variable "Plus" should be either '''' or ''-plus'' or ''-plusplus''')
end

% round to 8 decimal digits to prevent rounding problems later on
y = roundoff(y, 8);

%% translate y to z
z = WL_t-y;

