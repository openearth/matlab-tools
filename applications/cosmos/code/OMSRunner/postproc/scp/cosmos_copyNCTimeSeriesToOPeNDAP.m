function cosmos_copyNCTimeSeriesToOPeNDAP(hm,m)

model=hm.models(m);
archdir = model.archiveDir;

for i=1:model.nrTimeSeriesDatasets
    
    stName=model.timeSeriesDatasets(i).station;
    
    if model.timeSeriesDatasets(i).toOPeNDAP
        
        par=model.timeSeriesDatasets(i).parameter;
        
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
