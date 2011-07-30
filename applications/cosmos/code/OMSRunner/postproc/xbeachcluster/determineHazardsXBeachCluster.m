function determineHazardsXBeachCluster(hm,m)

model=hm.models(m);

dr=model.dir;

np=hm.models(m).nrProfiles;

for ip=1:np
    
    profile=model.profile(ip).name;
    
    inputdir=[dr 'lastrun' filesep 'input' filesep profile filesep];
    archivedir=[model.archiveDir hm.cycStr filesep 'netcdf' filesep profile filesep];
    xmldir=[model.archiveDir hm.cycStr filesep 'hazards' filesep profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '.nc'],'file')
        
        if ~exist(xmldir,'dir')
            mkdir(xmldir);
        end
        
        tref=model.tFlowStart;

        % Compute run-up etc.
        profile_calcs(inputdir,archivedir,xmldir,profile,tref);
        
    end
    
end
