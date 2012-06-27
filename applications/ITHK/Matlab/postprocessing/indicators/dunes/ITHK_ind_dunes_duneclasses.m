function ITHK_dunerules2(sens,varargin)

% dunerules_19apr12.m

% -------------------------------------------------------------------
% Alma de Groot
% Ecoshape, WUR
% 19 apr 2012

% Calculates potential for dune formation based on Unibest outcomes.
% Post-processing tool based on UNIBEST outcomes
% used in Interactive Design Tool
% -------------------------------------------------------------------

fprintf('ITHK postprocessing : Indicator for dune class identification\n');

%% Housekeeping
global S

%% EXTRACT AND INITIALISE MATRICES FOR COMPUTATIONS
% this is a temporary datafile stored locally
% => needs to be changed into correct local matrix
if nargin>1
    reference=1;
    PRNdata = S.UB(sens).data_ref.PRNdata;
else
    reference=0;
    PRNdata = S.UB(sens).results.PRNdata;
end
stored = PRNdata.stored;
if S.userinput.indicators.slr == 1
    for jj=1:length(S.PP(sens).settings.tvec)
        zminz0(:,jj) = PRNdata.zSLR(:,jj)-PRNdata.zSLR(:,1);
    end    
else
    zminz0 = PRNdata.zminz0;
end
% duneclasstemp = ones(size(stored(1),1));  % initialise matrix for calculations
% these matrices normally have rows = transects, columns = years.

% -------------------------------------------------------------------
%% STEP 1 DISTRIBUTE THE TOTAL VOLUME OVER THE BEACH, DUNES AND UNDERWATER
% WITH SIMPLIFIED CODE!

% calculate values per year
cellwidth = round(PRNdata.xdist(2) - PRNdata.xdist(1)) ;
volumeyear = (stored - circshift(stored, [0 1])).*1e+006./cellwidth;  % transform into deltaV per year, in m3/m*year
volumeyear (:,1) = stored(:,1).*1e+006./cellwidth;               % correct for the effect of circshift


% calculate volume changes per profile section per year
% obtain values from Netica
% [underwateryear, beachyear, dunesyear] = neticaread(volumeyear);  % FUL VERSION, STILL NEEDS TO BE MADE! WAIT FOR NETICA READ FILES FROM USGS/DIRK
[underwateryear, beachyear, dunesyear] = neticareadklad(volumeyear); 

% calculate cumulative values with respect to begin situation
cumdunes = dunesyear;
cumbeach = beachyear;
cumunderwater = underwateryear;
for p = 2:size(cumdunes,2)
    cumdunes(:,p) = cumdunes(:,p) + cumdunes(:,p-1) ;
    cumbeach(:,p) = cumbeach(:,p) + cumbeach(:,p-1) ;
    cumunderwater(:,p) = cumunderwater(:,p) + cumunderwater(:,p-1) ;
end


% -------------------------------------------------------------------
%% STEP 2 TRANSLATE CHANGES INTO DUNE CLASSES

% underwater is not taken into account, can be done for other applications
% if necessary

% Classes:
% - class 1 = erosive
% - class 2 = normal and slight progradation
% - class 3 = wide beach with potential for new dunes at the foot of the old
%             dune
% - class 4 = extremely wide beach with potential for new dunes
% - class 5 = extremely wide beach with potential for new dunes including
%             green beach 
% classes are compared to the current situation

% threshold values from one class to another (cumulatieve and yearly(?) volumes)
% and other settings
b1 = -30;                % from neutral to erosive (cumulative m3/m) 
b2 = 100;                % upper boundary of stable situation 
b3 = 400;                % upper boundary for slightly prograding situation 


duneclass = ones(size(cumdunes));
duneclass (cumdunes < b1)                     = 1;    % erosive
duneclass((cumdunes >= b1) & (cumdunes < b2)) = 2;    % stable
duneclass((cumdunes >= b2) & (cumdunes < b3)) = 3;    % potential for new dunes adjacent to dune foot
duneclass (cumdunes >= b3)                    = 4;    % mobile dunes

% taking into account temporal effects of vegetation establishment
thresholdyear = 10;                                        % how many years it takes before a wide beach becomes vegetated
for q = thresholdyear+1 : size(duneclass,2)
    duneclass_q = duneclass(:,q);                         % select only this year
    duneclass_temp = duneclass(:, q-thresholdyear: q-1);  % select previous couple of years
    duneclass_temp_sum = sum(duneclass_temp , 2);         % add up the ordinal classes
    
    % everywhere where at least 5 years with duneclass 4 have been => class 5
    % but when eroding, a beach that has gone from 5 to 3, it cannot shift back to 5 again.
    thresholdcrossed = (duneclass_temp_sum >= thresholdyear.*4) & (duneclass_temp(:, end) > 3);
    duneclass_q(thresholdcrossed) = 5;
    duneclass(:,q) = duneclass_q;
end

if reference==0
    S.PP(sens).dunes.duneclass = duneclass;
else
    S.PP(sens).dunes.duneclassref = duneclass;
end

for jj = 1:length(S.PP(sens).settings.tvec)
    S.PP(sens).dunes.duneclassRough(:,jj) = interp1(S.PP(sens).settings.s0,duneclass(:,jj),S.PP(sens).settings.sgridRough,'nearest');
end

[KMLdata]=ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough,S.PP(sens).dunes.duneclassRough,S.settings.indicators.dunes.icons,str2double(S.settings.indicators.dunes.offset));
S.PP(sens).output.kml_dunes_duneclasses = KMLdata;