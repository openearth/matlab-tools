function cosmos_getMeteoData(hm)


for i=1:hm.nrMeteoDatasets

    t0=1e9;
    t1=-1e9;

    meteoname=hm.meteo(i).name;
    meteoloc=hm.meteo(i).Location;
    meteosource=hm.meteo(i).source;

    xlim = hm.meteo(i).xLim;
    ylim = hm.meteo(i).yLim;

    % Check whether this meteo dataset needs to be downloaded
    useThisMeteo=0;
    inclh=0;
    for j=1:hm.nrModels
        if strcmpi(meteoname,hm.models(j).useMeteo)
            useThisMeteo=1;
            % Find start and stop time for meteo data
            t0=min(hm.models(j).tFlowStart,t0);
            t0=min(hm.models(j).tWaveStart,t0);
            t1=max(t1,hm.models(j).tStop);
            if hm.models(j).includeTemperature
                inclh=1;
            end
        end
    end

    if useThisMeteo

        display(meteoname);

        outdir=[hm.scenarioDir 'meteo' filesep meteoname filesep];

        s=xml_load([hm.dataDir 'meteo' filesep 'meteomodels.xml']);
        
        for im=1:length(s.models)
            if strcmpi(s.models(im).model.name,meteosource)
                meteomodel=s.models(im).model;
            end
        end
        
        parstr=[];
        pr=[];
        
        if inclh
            parstr{1}=meteomodel.uwindstr;
            parstr{2}=meteomodel.vwindstr;
            parstr{3}=meteomodel.pressstr;
            parstr{4}=meteomodel.tempstr;
            parstr{5}=meteomodel.humidstr;
            parstr{6}=meteomodel.cloudstr;
            pr={'u','v','p','airtemp','relhum','cloudcover'};
        else
            parstr{1}=meteomodel.uwindstr;
            parstr{2}=meteomodel.vwindstr;
            parstr{3}=meteomodel.pressstr;
            pr={'u','v','p'};
        end

        cycleInterval=str2double(meteomodel.cycleInterval);
        dt=str2double(meteomodel.dt);
        
        getMeteo(meteosource,meteoloc,t0,t1,xlim,ylim,outdir,cycleInterval,dt,parstr,pr,'tlastanalyzed',hm.meteo(i).tLastAnalyzed,'outputmeteoname',meteoname);
        
        fid=fopen([outdir 'tlastanalyzed.txt'],'wt');
        fprintf(fid,'%s\n',datestr(hm.meteo(i).tLastAnalyzed,'yyyymmdd HHMMSS'));
        fclose(fid);

    end
end
