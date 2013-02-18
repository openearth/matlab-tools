function hm=cosmos_determineHazards(hm,m)

model=hm.models(m);
archivedir=[hm.archiveDir filesep model.continent filesep model.name filesep 'archive' filesep];
cycledir=[archivedir hm.cycStr filesep];

% Create hazard xml folder and remove all existing xml files
hazarchdir=[cycledir 'hazards' filesep];
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
