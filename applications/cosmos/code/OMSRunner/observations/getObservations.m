function getObservations(hm)

%% Determine which observations are needed 

nobs=0;
idbs=[];
iids=[];
ipars=[];
for i=1:hm.NrModels
    for j=1:hm.Models(i).NrStations
        % First observations
        for k=1:hm.Models(i).Stations(j).NrParameters
            par=hm.Models(i).Stations(j).Parameters(k).Name;
            % Check if observations are plotted
            if hm.Models(i).Stations(j).Parameters(k).PlotObs
                % Get source and id for this parameter
                obssrc=hm.Models(i).Stations(j).Parameters(k).ObsSrc;
                obsid=hm.Models(i).Stations(j).Parameters(k).ObsID;
                % Determine which database observation is in
                idb=strmatch(lower(obssrc),hm.ObservationDatabases,'exact');
                if ~isempty(idb)
                    % Determine which station is needed
                    iid=strmatch(obsid,hm.ObservationStations{idb}.IDCode,'exact');
                    if ~isempty(iid)
                        % Determine which parameter is needed
                        par2=getParameterInfo(hm,lower(par),'source',obssrc,'dbname');
                        ipar=strmatch(lower(par2),lower(hm.ObservationStations{idb}.Parameters(iid).Name),'exact');
                        if ~isempty(ipar)
                            % Check if this data is available
                            if hm.ObservationStations{idb}.Parameters(iid).Status(ipar)>0
                                % Check if data will already be downloaded
                                if sum(idbs==idb & iids==iid & ipars==ipar)==0
                                    nobs=nobs+1;
                                    idbs(nobs)=idb;
                                    iids(nobs)=iid;
                                    ipars(nobs)=ipar;
                                    % Parameter name used by OpenDAP
                                    opendappar{nobs}=getParameterInfo(hm,lower(par),'source',obssrc,'name');
                                    plotpar{nobs}=lower(par);
                                end                                                                    
                            end
                        end
                    end
                end
            end
        end
    end
end

%% Now go get the data

for i=1:nobs

    idb=idbs(i);
    iid=iids(i);
    ipar=ipars(i);
    
    db=hm.ObservationDatabases{idb};
    idcode=hm.ObservationStations{idb}.IDCode{iid};
    par=hm.ObservationStations{idb}.Parameters(iid).Name{ipar};
    
    disp(['Downloading observations of ' par ' for ' idcode ' from ' db ' ...']);
    
    url=hm.ObservationStations{idb}.URL;
    
    if strcmpi(hm.Scenario,'forecasts')
        t0=floor(hm.Cycle-8);
    else
        t0=hm.Cycle;
    end

    t1=ceil(hm.Cycle+hm.RunTime/24);

    try
 
        par2=opendappar{i};
        
        switch db
            case{'ndbc'}
                [t,val]=getTimeSeriesFromNDBC(url,t0,t1,idcode,par2);
            case{'co-ops'}
%                [t,val]=getTimeSeriesFromCoops(url,t0,t1,idcode,par2);
                [t,val]=getWLFromCoops(idcode,t0,t1);
            case{'matroos'}
                [t,val]=getTimeSeriesFromMatroos(url,t0,t1,hm.ObservationStations{idb}.Name{iid},par2);
        end

        if ~isempty(t)
            % Make directory
            MakeDir(hm.ScenarioDir,'observations',db,idcode);
            fname=[hm.ScenarioDir 'observations' filesep db filesep idcode filesep plotpar{i} '.' idcode '.mat'];
            data.Name=idcode;
            data.Parameter=par;
            data.Time=t;
            data.Val=val;
            save(fname,'-struct','data','Name','Parameter','Time','Val');
        end

    catch
        disp(['Something went wrong while downloading ' par ' for ' idcode ' from ' db]);
    end

end
