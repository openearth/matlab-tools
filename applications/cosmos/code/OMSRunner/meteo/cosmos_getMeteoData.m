function cosmos_getMeteoData(hm)


for i=1:hm.nrMeteoDatasets

%    hm.meteoNames{i}=hm.meteo(i).name;
%    hm.meteo(i).tLastAnalyzed=rounddown(now-hm.meteo(i).Delay/24,hm.meteo(i).cycleInterval/24);
%     hm.meteo(i).tLastAnalyzed=rounddown(now-hm.meteo(i).Delay/24,hm.runInterval/24);

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

        dt=hm.meteo(i).cycleInterval/24;

        %         switch lower(hm.scenario)
        %
        %             case{'forecasts'}
        %
        for t=t0:dt:t1

            tnext=t+dt;

            tcyc=t;
            cycledate=floor(tcyc);
            cyclehour=(tcyc-floor(tcyc))*24;

            if tnext>hm.meteo(i).tLastAnalyzed
                % Next meteo output not yet available, so get the
                % rest of the data from this cycle and then exit
                % loop after this
                tt=[t t1];
            else
                tt=[t t+dt];
            end

            switch lower(meteoloc)
                case{'nomads'}
                    getMeteoFromNomads3(meteosource,meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir,'includeHeat',inclh);
                case{'matroos'}
                    disp(['Getting HIRLAM ' datestr(tt(1)) ' to ' datestr(tt(end)) ' ...']);
                    getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
            end

            if tnext>hm.meteo(i).tLastAnalyzed
                break;
            end

        end

        fid=fopen([outdir 'tlastanalyzed.txt'],'wt');
        fprintf(fid,'%s\n',datestr(hm.meteo(i).tLastAnalyzed,'yyyymmdd HHMMSS'));
        fclose(fid);
        %                 tcyc=t0;
        %                 cycledate=floor(tcyc);
        %                 cyclehour=(tcyc-floor(tcyc))*24;
        %                 tt=[t0 t1];
        %
        %                 switch lower(meteoloc)
        %                     case{'nomads'}
        %                         GetMeteoFromNomads(meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir);
        %                     case{'matroos'}
        %                         getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
        %                 end

        %             otherwise
        %
        %                 for t=t0:dt:t1
        %
        %                     tcyc=t;
        %
        %                     cycledate=floor(tcyc);
        %                     cyclehour=(tcyc-floor(tcyc))*24;
        %
        %                     tt=[t t+dt-hm.meteo(i).timeStep/24];
        %
        %                     switch lower(meteoloc)
        %                         case{'nomads'}
        %                             GetMeteoFromNomads(meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir);
        %                         case{'matroos'}
        %                             getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
        %                     end
        %                 end
        %
        %         end
    end
end
