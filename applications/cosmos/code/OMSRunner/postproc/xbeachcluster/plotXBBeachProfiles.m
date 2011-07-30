function plotXBBeachProfiles(hm,m)

model=hm.models(m);

dr=model.dir;

np=hm.models(m).nrProfiles;

for ip=1:np
    
    profile=model.profile(ip).name;
    
    inputdir=[dr 'lastrun' filesep 'input' filesep profile filesep];
    outputdir=[dr 'lastrun' filesep 'output' filesep profile filesep];
    archivedir=[model.archiveDir hm.cycStr filesep 'netcdf' filesep profile filesep];
    figuredir=[dr 'lastrun' filesep 'figures' filesep];
    xmldir=[model.archiveDir hm.cycStr filesep 'hazards' filesep profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '_proc.mat'],'file')
        
        plot_profilecalcs(figuredir,archivedir,xmldir,profile);
                
    end
    
end
