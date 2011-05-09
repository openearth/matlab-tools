function GetOceanModelData(hm)


for i=1:length(hm.oceanModels)

    t0=1e9;
    t1=-1e9;

    oceanname=hm.oceanModel(i).name;

    xlim = hm.oceanModel(i).xLim;
    ylim = hm.oceanModel(i).yLim;

    % Check whether this ocean model dataset needs to be downloaded
    useThisOceanModel=0;
    for j=1:hm.NrModels
        if strcmpi(hm.Models(j).FlowNestType,'oceanmodel')
            if strcmpi(oceanname,hm.Models(j).oceanModel)
                useThisOceanModel=1;
                % Find start and stop time for meteo data
                t0=min(hm.Models(j).TFlowStart,t0);
                t0=min(hm.Models(j).TWaveStart,t0);
                t1=max(t1,hm.Models(j).TStop);
            end
        end
    end

    if useThisOceanModel

        display(oceanname);

        outdir=[hm.ScenarioDir 'oceanmodels' filesep oceanname filesep];
        
        switch lower(hm.oceanModel(i).type)
            case{'hycom'}
                url=hm.oceanModel(i).URL;
                outname=hm.oceanModel(i).name;
                s=load([hm.MainDir 'oceanmodels' filesep 'hycom.mat']);
                s=s.s;
                MakeDir(hm.ScenarioDir,'oceanmodels',oceanname);
                t0=floor(t0);
                t1=ceil(t1);
                getHYCOM(url,outname,outdir,'waterlevel',xlim,ylim,0.1,0.1,[t0 t1],s);
                getHYCOM(url,outname,outdir,'current_u',xlim,ylim,0.1,0.1,[t0 t1],s);
                getHYCOM(url,outname,outdir,'current_v',xlim,ylim,0.1,0.1,[t0 t1],s);
                getHYCOM(url,outname,outdir,'salinity',xlim,ylim,0.1,0.1,[t0 t1],s);
                getHYCOM(url,outname,outdir,'temperature',xlim,ylim,0.1,0.1,[t0 t1],s);
        end

    end
end
