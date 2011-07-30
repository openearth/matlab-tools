function copyNCTimeSeriesToOPeNDAP(hm,m)

model=hm.models(m);
archdir = model.archiveDir;

for i=1:model.nrStations
    
    stName=model.stations(i).name;
    
    for k=1:model.stations(i).nrParameters

        if model.stations(i).parameters(k).toOPeNDAP
            
            par=model.stations(i).parameters(k).name;
            
            ncfile=[archdir 'appended' filesep 'timeseries' filesep stName '.' par '.' num2str(year(hm.cycle)) '.nc'];
            
            if exist(ncfile,'file')
                try
                    system('net use \\opendap\opendap 0rm0ndt /user:ormondt');
                    url=['\\opendap\opendap\deltares\cosmos\' hm.scenario '\' model.continent '\' model.name '\'];
                    copyfile(ncfile,url);
                    system('net use \\opendap\opendap /delete');
                catch
                    disp('Could not copy to OPeNDAP server!');
                end
            end
            
        end
        
    end
end
