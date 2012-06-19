function ITHK_add_SLR(sens)

global S

% Get settings
SLR = str2double(S.settings.postprocessing.slr.slrperyr);      %SLR per year
slope = str2double(S.settings.postprocessing.slr.coastslope);  %Avg coastal slope
dSLR = SLR/slope;                                              %Coastal retreat per year

% Coastal angles
angles = S.PP.settings.MDAdata_NEW.ANGLEcoast;
dxcoast = dSLR*sind(angles);
dycoast = dSLR*cosd(angles);

% Make PRNdata with SLR equal to PRNdata without SLR
S.UB(sens).results.PRNdata.xSLR = S.UB(sens).results.PRNdata.x;
S.UB(sens).results.PRNdata.ySLR = S.UB(sens).results.PRNdata.y;
S.UB(sens).results.PRNdata.zSLR = S.UB(sens).results.PRNdata.z;

for tt=1:length(S.PP.settings.tvec)
    % Check for revetments
    idphase = find(tt-1>= S.userinput.phases,1,'last');
    REVdata = ITHK_readREV(S.userinput.phase(idphase).REVfile);
    revids = [];ids = 1:length(S.UB(1).results.PRNdata.x(:,tt));
    % Find ids of revetments on coastline
    for ii=1:length(REVdata);
        dist1 = ((S.PP.settings.MDAdata_NEW.Xcoast-REVdata(ii).Xw(1)).^2 + (S.PP.settings.MDAdata_NEW.Ycoast-REVdata(ii).Yw(1)).^2).^0.5;
        dist2 = ((S.PP.settings.MDAdata_NEW.Xcoast-REVdata(ii).Xw(end)).^2 + (S.PP.settings.MDAdata_NEW.Ycoast-REVdata(ii).Yw(end)).^2).^0.5;
        id1  = find(dist1==min(dist1));
        id2  = find(dist2==min(dist2));
        if id2>id1
            revids = [revids id1:id2];
        else
            revids = [revids id2:id1];
        end
        clear id1 id2
    end
    % Shift coast backward only where no revetments exist
    S.UB(sens).results.PRNdata.xSLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.x(~ismember(ids,revids),tt)-dxcoast(~ismember(ids,revids))*(tt-1);
    S.UB(sens).results.PRNdata.ySLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.y(~ismember(ids,revids),tt)-dycoast(~ismember(ids,revids))*(tt-1);
    S.UB(sens).results.PRNdata.zSLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.z(~ismember(ids,revids),tt)-dSLR*(tt-1);
end