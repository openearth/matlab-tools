function getMeteo(meteoname,meteoloc,t0,t1,xlim,ylim,outdir,cycleInterval,dt,pars,pr,varargin)

usertcyc=0;
outputMeteoName=meteoname;
tLastAnalyzed=now;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case{'cycle'}
                % user-specified cycle
                tcyc=varargin{i+1};
                usertcyc=1;
            case{'outputmeteoname'}
                % user-specified output name
                outputMeteoName=varargin{i+1};
            case{'tlastanalyzed'}
                % Time of last analyzed data
                tLastAnalyzed=varargin{i+1};
        end
%     elseif iscell(varargin{i})
%         for j=1:length(varargin{i})
%             pars{j}=varargin{i}{j};
%         end
    end
end

dcyc=cycleInterval/24;
dt=dt/24;

if ~exist(outdir,'dir')
    mkdir(outdir);
end

if cycleInterval>1000
    % All data in one nc file
    tt=[t0 t1];
    getMeteoFromNomads3(meteoname,outputMeteoName,0,0,tt,xlim,ylim,outdir,pars,pr);
else

    for t=t0:dcyc:t1

        tnext=t+dt;

        if ~usertcyc
            tcyc=t;
        end

        cycledate=floor(tcyc);
        cyclehour=(tcyc-floor(tcyc))*24;

        if tnext>tLastAnalyzed
            % Next meteo output not yet available, so get the
            % rest of the data from this cycle and then exit
            % loop after this
            tt=[t t1];
        else
            tt=[t t+dcyc-dt];
        end

        tt(2)=min(tt(2),t1);

        switch lower(meteoloc)
            case{'nomads'}
                getMeteoFromNomads3(meteoname,outputMeteoName,cycledate,cyclehour,tt,xlim,ylim,outdir,pars,pr);
            case{'matroos'}
                getMeteoFromMatroos(meteoname,cycledate,cyclehour,tt,[],[],outdir);
        end

        if tnext>tLastAnalyzed
            break;
        end

    end
end
