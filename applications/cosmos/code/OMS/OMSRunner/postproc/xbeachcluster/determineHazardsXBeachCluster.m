function determineHazardsXBeachCluster(hm,m)

Model=hm.Models(m);

dr=Model.Dir;

np=hm.Models(m).NrProfiles;

for ip=1:np
    
    profile=Model.Profile(ip).Name;
    
    inputdir=[dr 'lastrun' filesep 'input' filesep profile filesep];
    archivedir=[Model.ArchiveDir hm.CycStr filesep 'netcdf' filesep profile filesep];
    xmldir=[Model.ArchiveDir hm.CycStr filesep 'hazards' filesep profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '.nc'],'file')
        
        if ~exist(xmldir,'dir')
            mkdir(xmldir);
        end
        
        tref=Model.TFlowStart;

        % Compute run-up etc.
        profile_calcs(inputdir,archivedir,xmldir,profile,tref);
        
    end
    
end
