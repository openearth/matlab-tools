function GetMeteoData(hm)


for i=1:hm.NrMeteoDatasets

%    hm.MeteoNames{i}=hm.Meteo(i).Name;
%    hm.Meteo(i).tLastAnalyzed=rounddown(now-hm.Meteo(i).Delay/24,hm.Meteo(i).CycleInterval/24);
%     hm.Meteo(i).tLastAnalyzed=rounddown(now-hm.Meteo(i).Delay/24,hm.RunInterval/24);

    t0=1e9;
    t1=-1e9;

    meteoname=hm.Meteo(i).Name;
    meteoloc=hm.Meteo(i).Location;
    meteosource=hm.Meteo(i).source;

    xlim = hm.Meteo(i).XLim;
    ylim = hm.Meteo(i).YLim;

    % Check whether this meteo dataset needs to be downloaded
    useThisMeteo=0;
    inclh=0;
    for j=1:hm.NrModels
        if strcmpi(meteoname,hm.Models(j).UseMeteo)
            useThisMeteo=1;
            % Find start and stop time for meteo data
            t0=min(hm.Models(j).TFlowStart,t0);
            t0=min(hm.Models(j).TWaveStart,t0);
            t1=max(t1,hm.Models(j).TStop);
            if hm.Models(j).includeTemperature
                inclh=1;
            end
        end
    end

    if useThisMeteo

        display(meteoname);

        outdir=[hm.ScenarioDir 'meteo' filesep meteoname filesep];

        dt=hm.Meteo(i).CycleInterval/24;

        %         switch lower(hm.Scenario)
        %
        %             case{'forecasts'}
        %
        for t=t0:dt:t1

            tnext=t+dt;

            tcyc=t;
            cycledate=floor(tcyc);
            cyclehour=(tcyc-floor(tcyc))*24;

            if tnext>hm.Meteo(i).tLastAnalyzed
                % Next meteo output not yet available, so get the
                % rest of the data from this cycle and then exit
                % loop after this
                tt=[t t1];
            else
                tt=[t t+dt];
            end

            switch lower(meteoloc)
                case{'nomads'}
%                    GetMeteoFromNomads(meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir);
%                    GetMeteoFromNomads2(meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir,inclh);
                    GetMeteoFromNomads3(meteosource,meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir,'includeHeat',inclh);
                case{'matroos'}
                    disp(['Getting HIRLAM ' datestr(tt(1)) ' to ' datestr(tt(end)) ' ...']);
                    getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
            end

            if tnext>hm.Meteo(i).tLastAnalyzed
                break;
            end

        end

        fid=fopen([outdir 'tlastanalyzed.txt'],'wt');
        fprintf(fid,'%s\n',datestr(hm.Meteo(i).tLastAnalyzed,'yyyymmdd HHMMSS'));
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
        %                     tt=[t t+dt-hm.Meteo(i).TimeStep/24];
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
