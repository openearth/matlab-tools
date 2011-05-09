function hm=getRestartTimes(hm)

% Restart times
for i=1:hm.NrModels

    ii=strmatch(hm.Models(i).UseMeteo,hm.MeteoNames,'exact');
    if ~isempty(ii)
        % We want to start with an analyzed wind field
        meteodir=[hm.ScenarioDir 'meteo' filesep hm.Models(i).UseMeteo filesep];
        tana=readTLastAnalyzed(meteodir);
        tana=rounddown(tana,hm.RunInterval/24);
    else
        tana=datenum(2100,1,1);
    end

    trst=-1e9;
    trst=max(trst,hm.Models(i).TWaveOkay); % Model must be spun-up
    trst=max(trst,hm.Models(i).TFlowOkay); % Model must be spun-up
    trst=max(trst,hm.Cycle+hm.RunInterval/24); % Start time of next cycle
    trst=min(trst,tana); % Restart time no later than last analyzed time in meteo fields
    hm.Models(i).restartTime=trst;

end
