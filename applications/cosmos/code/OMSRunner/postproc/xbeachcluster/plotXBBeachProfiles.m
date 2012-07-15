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
        
        %% Write html code
        fi2=fopen([model.dir 'lastrun' filesep 'figures' filesep profile '.html'],'wt');
        fprintf(fi2,'%s\n','<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
        fprintf(fi2,'%s\n','<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">');
        fprintf(fi2,'%s\n','<head>');
        fprintf(fi2,'%s\n','</head>');
        fprintf(fi2,'%s\n','<body>');
        fprintf(fi2,'%s\n',['<img src="' profile '.png">']);
        fprintf(fi2,'%s\n','</body>');
        fprintf(fi2,'%s\n','</html>');
        fclose(fi2);
                
    end
    
end
