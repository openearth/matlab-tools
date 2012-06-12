function ITHK_mapUBtoGE(sens)

global S

%% General PP settings
% Extract MDAdata for original and updated coastline
[S.PP.settings.MDAdata_ORIG_OLD]=readMDA('BASIS_ORIG_OLD.MDA');
[S.PP.settings.MDAdata_ORIG]=readMDA('BASIS_ORIG.MDA');
[S.PP.settings.MDAdata_NEW]=readMDA('BASIS.MDA');

% time settings
S.PP.settings.tvec = S.UB(sens).results.PRNdata.year;
S.PP.settings.t0 = 2005;

% initial coast line
S.PP.settings.x0              = S.PP.settings.MDAdata_ORIG.Xcoast; 
S.PP.settings.y0              = S.PP.settings.MDAdata_ORIG.Ycoast; 
S.PP.settings.s0              = distXY(S.PP.settings.MDAdata_ORIG.Xcoast,S.PP.settings.MDAdata_ORIG.Ycoast);

% settings
S.PP.settings.dsRough         = str2double(S.settings.plotting.barplot.dsrough); % grid size rough grid
S.PP.settings.dsFine          = str2double(S.settings.plotting.barplot.dsfine);  % grid size fine grid
S.PP.settings.dxFine          = str2double(S.settings.plotting.barplot.widthfine); % distance from suppletion location where fine grid is used
S.PP.settings.sVectorLength   = str2double(S.settings.plotting.barplot.barscalevector);   % scaling factor for vector length

% Rough & fine grids
S.PP.settings.sgridRough      = S.PP.settings.s0(1):S.PP.settings.dsRough:S.PP.settings.s0(end);
S.PP.settings.sgridFine       = S.PP.settings.s0(1):S.PP.settings.dsFine:S.PP.settings.s0(end);
S.PP.settings.idplotrough     = ones(length(S.PP.settings.sgridRough),1);
S.PP.settings.widthRough      = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP.settings.dsRough/2);
S.PP.settings.widthFine       = max(mean(diff(S.UB(sens).results.PRNdata.xdist)),S.PP.settings.dsFine/2);

% Find ids of fine grid corresponding to rough grid
for ii=1:length(S.PP.settings.sgridRough)
    distFR{ii} = abs(S.PP.settings.sgridFine-S.PP.settings.sgridRough(ii));
    S.PP.settings.idFR(ii) = find(distFR{ii} == min(distFR{ii}),1,'first');
end

%% Map UB coastline to GE grid
for jj = 1:length(S.PP.settings.tvec)
    %% Original coastline data (for comparing to reference)
    x0 = S.PP.settings.MDAdata_ORIG_OLD.Xcoast;
    y0 = S.PP.settings.MDAdata_ORIG_OLD.Ycoast;
    s0 = distXY(S.PP.settings.MDAdata_ORIG_OLD.Xcoast,S.PP.settings.MDAdata_ORIG_OLD.Ycoast);

    %% Interpolate PRN data to original UB grid
    xcoast = S.UB(sens).results.PRNdata.x(:,jj);      % x-position of coast line
    ycoast = S.UB(sens).results.PRNdata.y(:,jj);      % y-position of coast line

    % coast line change relative to reference coast line at t=tvec(jj)
    % omit double x-entries in interpolation
    [AA,ids1]=unique(xcoast);
    [BB,ids2]=unique(S.UB(sens).data_ref.PRNdata.x(:,jj));  

    % coastline changes relative to t0
    zPRN = S.UB(sens).results.PRNdata.z(sort(ids1),jj);
    zPRN1 = S.UB(sens).results.PRNdata.z(sort(ids1),1);
    z = zPRN-zPRN1;

    % Interpolate to original grid (now interpolation in 2 steps, because direct interpolation gave unstable results) 
    if  length(z)~=length(s0)
        z=interp1(xcoast(sort(ids1)),z,x0); 
    end

    %% Interpolate PRN data to GE grid
    zgridRough = interp1(s0,z,S.PP.settings.sgridRough);
    x0gridRough = interp1(s0,x0,S.PP.settings.sgridRough);
    y0gridRough = interp1(s0,y0,S.PP.settings.sgridRough);
    S.PP.GEmapping.zminz0(jj,:) = zgridRough; 
    S.PP.GEmapping.x0(jj,:) = x0gridRough;
    S.PP.GEmapping.y0(jj,:) = y0gridRough;
end

%% Initialize measures
% Pas op dit is gebaseerd op gehele kustlijn, nu nog op GE grid rough!!!
S.PP.GEmapping.supp_beach = zeros(length(S.PP.settings.tvec),length(x0));
S.PP.GEmapping.supp_foreshore = zeros(length(S.PP.settings.tvec),length(x0));
S.PP.GEmapping.supp_mega = zeros(length(S.PP.settings.tvec),length(x0));
S.PP.GEmapping.rev = zeros(length(S.PP.settings.tvec),length(x0));
S.PP.GEmapping.gro= zeros(length(S.PP.settings.tvec),length(x0));

for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).supids)
            ss = S.userinput.phase(jj).supids(ii); 
            if S.userinput.suppletion(ss).volperm < 400
                S.PP.GEmapping.supp_beach(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            elseif  S.userinput.suppletion(ss).volperm > 1000
                S.PP.GEmapping.supp_mega(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            else
                S.PP.GEmapping.supp_foreshore(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            end
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ss = S.userinput.phase(jj).revids(ii); 
            S.PP.GEmapping.revetment(S.userinput.revetment(ss).start+1:S.userinput.revetment(ss).stop,S.userinput.revetment(ss).idRANGE) = 1;
        end
    end    
end