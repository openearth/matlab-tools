function handles=GenerateTransportBoundaryConditions(handles,id,par,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

wb = waitbox('Generating Transport Boundary Conditions ...');%pause(0.1);

Flow=handles.Model(md).Input(id);

nr=Flow.NrOpenBoundaries;

thick=Flow.Thick;
kmax=Flow.KMax;

for i=1:nr
    dp(i,1)=-Flow.OpenBoundaries(i).Depth(1);
    dp(i,2)=-Flow.OpenBoundaries(i).Depth(2);
end

t0=Flow.StartTime;
t1=Flow.StopTime;

%% Salinity
if Flow.Salinity.Include && (strcmpi(par,'Salinity') || strcmpi(par,'all'))
    switch lower(Flow.Salinity.BCOpt)
        case{'constant'}
            s=Flow.Salinity.BCConst;
        case{'linear'}
            pars=Flow.Salinity.BCPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=Flow.Salinity.BCPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(nr,2)+Flow.Salinity.BCPar(k,1);
            end
    end
    for j=1:nr
        Flow.OpenBoundaries(j).Salinity.NrTimeSeries=2;
        Flow.OpenBoundaries(j).Salinity.TimeSeriesT=[t0;t1];
        switch lower(Flow.Salinity.BCOpt)
            case{'constant'}
                Flow.OpenBoundaries(j).Salinity.Profile='uniform';
                Flow.OpenBoundaries(j).Salinity.TimeSeriesA=[s ; s];
                Flow.OpenBoundaries(j).Salinity.TimeSeriesB=[s ; s];
            case{'step'}
                Flow.OpenBoundaries(j).Salinity.Profile='step';
            otherwise
                Flow.OpenBoundaries(j).Salinity.Profile='3d-profile';
                ta=squeeze(s(j,1,:))';
                tb=squeeze(s(j,2,:))';
                ta=[ta;ta];
                tb=[tb;tb];
                Flow.OpenBoundaries(j).Salinity.TimeSeriesA=ta;
                Flow.OpenBoundaries(j).Salinity.TimeSeriesB=tb;
        end
    end
end

%% Temperature
if Flow.Temperature.Include && (strcmpi(par,'Temperature') || strcmpi(par,'all'))
    switch lower(Flow.Temperature.BCOpt)
        case{'constant'}
            s=Flow.Temperature.BCConst;
        case{'linear'}
            pars=Flow.Temperature.BCPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
        case{'block'}
            pars=Flow.Temperature.BCPar;
            s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
        case{'per layer'}
            for k=1:kmax
                s(:,:,k)=zeros(nr,2)+Flow.Temperature.BCPar(k,1);
            end
    end
    for j=1:nr
        Flow.OpenBoundaries(j).Temperature.NrTimeSeries=2;
        Flow.OpenBoundaries(j).Temperature.TimeSeriesT=[t0;t1];
        switch lower(Flow.Temperature.BCOpt)
            case{'constant'}
                Flow.OpenBoundaries(j).Temperature.Profile='uniform';
                Flow.OpenBoundaries(j).Temperature.TimeSeriesA=[s ; s];
                Flow.OpenBoundaries(j).Temperature.TimeSeriesB=[s ; s];
            case{'step'}
                Flow.OpenBoundaries(j).Temperature.Profile='step';
            otherwise
                Flow.OpenBoundaries(j).Temperature.Profile='3d-profile';
                ta=squeeze(s(j,1,:))';
                tb=squeeze(s(j,2,:))';
                ta=[ta;ta];
                tb=[tb;tb];
                Flow.OpenBoundaries(j).Temperature.TimeSeriesA=ta;
                Flow.OpenBoundaries(j).Temperature.TimeSeriesB=tb;
        end
    end
end

%% Sediments
if Flow.sediments.include
    for i=1:Flow.NrSediments
        if strcmpi(par,Flow.Sediment(i).Name) || strcmpi(par,'all')
            switch lower(Flow.Sediment(i).BCOpt)
                case{'constant'}
                    s=Flow.Sediment(i).BCConst;
                case{'linear'}
                    pars=Flow.Sediment(i).BCPar;
                    s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
                case{'block'}
                    pars=Flow.Sediment(i).BCPar;
                    s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
                case{'per layer'}
                    for k=1:kmax
                        s(:,:,k)=zeros(nr,2)+Flow.Sediment(i).BCPar(k,1);
                    end
            end
            for j=1:nr
                Flow.OpenBoundaries(j).Sediment(i).NrTimeSeries=2;
                Flow.OpenBoundaries(j).Sediment(i).TimeSeriesT=[t0;t1];
                switch lower(Flow.Sediment(i).BCOpt)
                    case{'constant'}
                        Flow.OpenBoundaries(j).Sediment(i).Profile='uniform';
                        Flow.OpenBoundaries(j).Sediment(i).TimeSeriesA=[s ; s];
                        Flow.OpenBoundaries(j).Sediment(i).TimeSeriesB=[s ; s];
                    case{'step'}
                        Flow.OpenBoundaries(j).Sediment(i).Profile='step';
                    otherwise
                        Flow.OpenBoundaries(j).Sediment(i).Profile='3d-profile';
                        ta=squeeze(s(j,1,:))';
                        tb=squeeze(s(j,2,:))';
                        ta=[ta;ta];
                        tb=[tb;tb];
                        Flow.OpenBoundaries(j).Sediment(i).TimeSeriesA=ta;
                        Flow.OpenBoundaries(j).Sediment(i).TimeSeriesB=tb;
                end
            end
        end
    end
end

%% Tracers
if Flow.Tracers
    for i=1:Flow.NrTracers
        if strcmpi(par,Flow.Tracer(i).Name) || strcmpi(par,'all')
            switch lower(Flow.Tracer(i).BCOpt)
                case{'constant'}
                    s=Flow.Tracer(i).BCConst;
                case{'linear'}
                    pars=Flow.Tracer(i).BCPar;
                    s=ddb_interpolateInitialConditions(dp,thick,pars,'linear');
                case{'block'}
                    pars=Flow.Tracer(i).BCPar;
                    s=ddb_interpolateInitialConditions(dp,thick,pars,'block');
                case{'per layer'}
                    for k=1:kmax
                        s(:,:,k)=zeros(nr,2)+Flow.Tracer(i).BCPar(k,1);
                    end
            end
            for j=1:nr
                Flow.OpenBoundaries(j).Tracer(i).NrTimeSeries=2;
                Flow.OpenBoundaries(j).Tracer(i).TimeSeriesT=[t0;t1];
                switch lower(Flow.Tracer(i).BCOpt)
                    case{'constant'}
                        Flow.OpenBoundaries(j).Tracer(i).Profile='uniform';
                        Flow.OpenBoundaries(j).Tracer(i).TimeSeriesA=[s ; s];
                        Flow.OpenBoundaries(j).Tracer(i).TimeSeriesB=[s ; s];
                    case{'step'}
                        Flow.OpenBoundaries(j).Tracer(i).Profile='step';
                    otherwise
                        Flow.OpenBoundaries(j).Tracer(i).Profile='3d-profile';
                        ta=squeeze(s(j,1,:))';
                        tb=squeeze(s(j,2,:))';
                        ta=[ta;ta];
                        tb=[tb;tb];
                        Flow.OpenBoundaries(j).Tracer(i).TimeSeriesA=ta;
                        Flow.OpenBoundaries(j).Tracer(i).TimeSeriesB=tb;
                end
            end
        end
    end
end

handles.Model(md).Input(id)=Flow;

ddb_saveBccFile(handles,id);

close(wb);
