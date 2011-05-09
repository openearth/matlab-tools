function plotXBBeachProfiles(hm,m)

Model=hm.Models(m);

dr=Model.Dir;

np=hm.Models(m).NrProfiles;

for ip=1:np
    
    profile=Model.Profile(ip).Name;
    
    inputdir=[dr 'lastrun' filesep 'input' filesep profile filesep];
    outputdir=[dr 'lastrun' filesep 'output' filesep profile filesep];
    archivedir=[Model.ArchiveDir hm.CycStr filesep 'netcdf' filesep profile filesep];
    figuredir=[dr 'lastrun' filesep 'figures' filesep];
    xmldir=[Model.ArchiveDir hm.CycStr filesep 'hazards' filesep profile filesep];
    
    % Check if simulation has run
    if exist([archivedir profile '_proc.mat'],'file')
        
        plot_profilecalcs(figuredir,archivedir,xmldir,profile);
                
    end
    
end
