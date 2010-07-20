function handles=ddb_addOMSObservationStations(handles)

xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
zz=handles.Model(md).Input(ad).DepthZ;

jj=strmatch('ObservationsDatabase',{handles.Toolbox(:).Name},'exact');

for k=1:length(handles.Toolbox(jj).Database)

    if handles.Toolbox(tb).UseObservationsDatabase(k)

        s=handles.Toolbox(jj).Database{k};
        src=s.ShortName;

        x=s.x;
        y=s.y;

        % Convert to local coordinate system
        cs.Name=s.CoordinateSystem;
        cs.Type=s.CoordinateSystemType;
        [x,y]=ddb_coordConvert(x,y,cs,handles.ScreenParameters.CoordinateSystem);

        [m,n,iindex]=ddb_findStationsOMS(x,y,xg,yg,zz);

        nobs=handles.Toolbox(tb).NrStations;

        % Get station names that are already used
        Names{1}='';
        for kk=1:nobs
            Names{kk}=handles.Toolbox(tb).Stations(kk).Name;
        end

        omsparameters={'hs','tp','wavdir','wl'};

        for i=1:length(m)
            ii=iindex(i);

            % Check if station already exists
            if isempty(strmatch(s.IDCode{ii},Names,'exact'))

                % If necessary, change name of parameter in database
                for ip=1:length(s.Parameters(ii).Name)
                    switch lower(src)
                        case{'co-ops'}
                            switch lower(s.Parameters(ii).Name{ip})
                                case{'water level'}
                                    s.Parameters(ii).Name{ip}='wl';
                            end
                        case{'matroos'}
                            switch lower(s.Parameters(ii).Name{ip})
                                case{'waterlevel'}
                                    s.Parameters(ii).Name{ip}='wl';
                                case{'wave_height_hm0'}
                                    s.Parameters(ii).Name{ip}='hs';
                                case{'wave_period_tp'}
                                    s.Parameters(ii).Name{ip}='tp';
%                                 case{'wind_speed'}
%                                     s.Parameters(ii).Name{ip}='hs';
%                                 case{'wave_height_hm0'}
%                                     s.Parameters(ii).Name{ip}='hs';
                            end
                    end
                end

                ok=0;

                % Check if hs, tp, wavdir or wl for this station are present in databases
                for j=1:length(omsparameters)
                    for ip=1:length(s.Parameters(ii).Name)
                        if strcmpi(s.Parameters(ii).Name{ip},omsparameters{j}) && s.Parameters(ii).Status(ip)==1
                            ok=1;
                        end
                    end
                end

                % Now actually determine which parameters to add
                if ok

                    nobs=nobs+1;
                    handles.Toolbox(tb).Stations(nobs).LongName=s.Name{ii};
                    handles.Toolbox(tb).Stations(nobs).Name=s.IDCode{ii};
                    handles.Toolbox(tb).Stations(nobs).m=m(i);
                    handles.Toolbox(tb).Stations(nobs).n=n(i);
                    handles.Toolbox(tb).Stations(nobs).x=x(ii);
                    handles.Toolbox(tb).Stations(nobs).y=y(ii);
                    handles.Toolbox(tb).Stations(nobs).StoreSP2=0;
                    handles.Toolbox(tb).Stations(nobs).SP2id='';
                    handles.Toolbox(tb).Stations(nobs).Type='wavebuoy';

                    % Set defaults (no plotting)
                    for j=1:length(omsparameters)
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).Name=omsparameters{j};
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotCmp=0;
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotObs=0;
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotPrd=0;
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).ObsSrc='';
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).ObsID='';
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).PrdSrc='';
                        handles.Toolbox(tb).Stations(nobs).Parameters(j).PrdID='';
                    end

                    % Now find which parameters for this station are in the
                    % data base
                    for j=1:length(omsparameters)
                        for ip=1:length(s.Parameters(ii).Name)
                            if strcmpi(s.Parameters(ii).Name{ip},omsparameters{j})
                                if s.Parameters(ii).Status(ip)==1
                                    if strcmpi(omsparameters{j},'hs')
                                        handles.Toolbox(tb).Stations(nobs).Type='wavebuoy';
                                    end
                                    if strcmpi(omsparameters{j},'wl')
                                        handles.Toolbox(tb).Stations(nobs).Type='tidegauge';
                                    end
                                    handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotCmp=1;
                                    handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotObs=1;
                                    handles.Toolbox(tb).Stations(nobs).Parameters(j).ObsSrc=src;
                                    handles.Toolbox(tb).Stations(nobs).Parameters(j).ObsID=s.IDCode{ii};
                                end
                            end
                        end
                    end
                end
            end
        end
        handles.Toolbox(tb).NrStations=nobs;
    end
end
