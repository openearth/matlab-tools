function hm=cosmos_getRestartTimes(hm)

% Restart times
for i=1:hm.nrModels

    ii=strmatch(hm.models(i).useMeteo,hm.meteoNames,'exact');
    if ~isempty(ii)
        % We want to start with an analyzed wind field
        meteodir=[hm.scenarioDir 'meteo' filesep hm.models(i).useMeteo filesep];
        tana=readTLastAnalyzed(meteodir);
        tana=rounddown(tana,hm.runInterval/24);
    else
        tana=datenum(2100,1,1);
    end

    trst=-1e9;
    trst=max(trst,hm.models(i).tWaveOkay); % Model must be spun-up
    trst=max(trst,hm.models(i).tFlowOkay); % Model must be spun-up
    trst=max(trst,hm.catchupCycle+hm.runInterval/24); % Start time of next cycle
    trst=min(trst,tana); % Restart time no later than last analyzed time in meteo fields
    hm.models(i).restartTime=trst;

end
