function getMeteo(meteoname,meteoloc,t0,t1,xlim,ylim,outdir,cycleInterval,dt,delay,varargin)

usertcyc=0;
for i=1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case{'cycle'}
                % user-specified cycle
                tcyc=varargin{i+1};
                usertcyc=1;
        end
    end
end

dcyc=cycleInterval/24;
dt=dt/24;


if cycleInterval>1000
    % All data in one nc file
    tt=[t0 t1];
    getMeteoFromNomads(meteoname,0,0,tt,xlim,ylim,outdir,1);
else

    for t=t0:dcyc:t1

        %     tnext=t+dt;

        if ~usertcyc
            tcyc=t;
        end

        cycledate=floor(tcyc);
        cyclehour=(tcyc-floor(tcyc))*24;

        %     if tnext>hm.Meteo(i).tLastAnalyzed
        %         % Next meteo output not yet available, so get the
        %         % rest of the data from this cycle and then exit
        %         % loop after this
        %         tt=[t t1];
        %     else
        tt=[t t+dcyc-dt];
        %     end

        tt(2)=min(tt(2),t1);

        switch lower(meteoloc)
            case{'nomads'}
                getMeteoFromNomads3(meteoname,cycledate,cyclehour,tt,xlim,ylim,outdir,1);
                %            getMeteoFromNomads(meteoname,cycledate,cyclehour,t0:dt:t1,xlim,ylim,outdir,0);
            case{'matroos'}
                getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
        end

        %     if tnext>hm.Meteo(i).tLastAnalyzed
        %         break;
        %     end

    end
end
