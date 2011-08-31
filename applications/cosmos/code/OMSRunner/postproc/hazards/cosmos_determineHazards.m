function hm=cosmos_determineHazards(hm,m)

% Create hazard xml folder and remove all existing xml files
hazarchdir=[hm.models(m).archiveDir hm.cycStr filesep 'hazards' filesep];
if ~exist(hazarchdir,'dir')
    mkdir(hazarchdir);
end
delete([hazarchdir '*.xml']);

for j=1:hm.models(m).nrHazards
    switch lower(hm.models(m).hazards(j).type)
        case{'ripcurrents'}
            disp('Rip currents ...');
            hm=cosmos_determineRipCurrents(hm,m,j);
    end
end
