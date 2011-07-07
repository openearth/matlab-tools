function copyNCTimeSeriesToOPeNDAP(hm,m)

Model=hm.Models(m);
archdir = Model.ArchiveDir;

for i=1:Model.NrStations
    
    stName=Model.Stations(i).Name;
    
    for k=1:Model.Stations(i).NrParameters

        if Model.Stations(i).Parameters(k).toOPeNDAP
            
            par=Model.Stations(i).Parameters(k).Name;
            
            ncfile=[archdir 'appended' filesep 'timeseries' filesep stName '.' par '.' num2str(year(hm.Cycle)) '.nc'];
            
            if exist(ncfile,'file')
                try
                    system('net use \\opendap\opendap 0rm0ndt /user:ormondt');
                    url=['\\opendap\opendap\deltares\cosmos\' hm.Scenario '\' Model.Continent '\' Model.Name '\'];
                    copyfile(ncfile,url);
                    system('net use \\opendap\opendap /delete');
                catch
                    disp('Could not copy to OPeNDAP server!');
                end
            end
            
        end
        
    end
end
