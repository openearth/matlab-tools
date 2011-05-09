function getPredictions(hm)

%% Determine which predictions are needed 

nobs=0;
idbs=[];
iids=[];

for i=1:hm.NrModels
    for j=1:hm.Models(i).NrStations
        for k=1:hm.Models(i).Stations(j).NrParameters
            % Check if predictions are plotted
            if hm.Models(i).Stations(j).Parameters(k).PlotPrd
                % Get source and id for this parameter
                prdsrc=hm.Models(i).Stations(j).Parameters(k).PrdSrc;
                prdid=hm.Models(i).Stations(j).Parameters(k).PrdID;
                % Determine which database observation is in
                idb=strmatch(lower(prdsrc),hm.TideDatabases,'exact');
                if ~isempty(idb)
                    % Determine which station is needed
                    iid=strmatch(prdid,hm.TideStations{idb}.IDCode,'exact');
                    if ~isempty(iid)                
                        % Check if data will already be generated
                        try
                        if sum(idbs==idb & iids==iid)==0
                            nobs=nobs+1;
                            idbs(nobs)=idb;
                            iids(nobs)=iid;
                        end
                        catch
                            disp('something went wrong');
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
    
    db=hm.TideDatabases{idb};
    idcode=hm.TideStations{idb}.IDCode{iid};
    
    % Make directory
    MakeDir(hm.ScenarioDir,'observations',db,idcode);
    
    disp(['Generating water level prediction for ' idcode ' from ' db ' ...']);
    
    if strcmpi(hm.Scenario,'forecasts')
        t0=floor(hm.Cycle-6);
    else
        t0=hm.Cycle;
    end
    t1=ceil(hm.Cycle+hm.RunTime/24);

    try
        
        cmp=hm.TideStations{idb}.ComponentSet(iid);
        comp=[];
        A=[];
        G=[];

        for ii=1:length(cmp.Component)
            comp{ii}=cmp.Component{ii};
            A(ii,1)=cmp.Amplitude(ii);
            G(ii,1)=cmp.Phase(ii);
        end

        dt=1/6;
        [val,t]=delftPredict2007(comp,A,G,t0,t1,dt);
        val=val(1:end-1);
        t=t(1:end-1);

        fname=[hm.ScenarioDir 'observations' filesep db filesep idcode filesep 'wl.' idcode '.mat'];
        data.Name=idcode;
        data.Parameter='water level';
        data.Time=t;
        data.Val=val;
        save(fname,'-struct','data','Name','Parameter','Time','Val');

    catch
        disp(['Something went wrong while predicting water level for ' idcode ' from ' db]);
    end

end

