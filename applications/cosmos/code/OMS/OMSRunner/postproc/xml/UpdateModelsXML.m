function UpdateModelsXML(hm,m)

% Updates model xml file for all websites

Model=hm.Models(m);

for iw=1:length(Model.WebSite)

    wbdir=Model.WebSite(iw).Name;
    xloc=Model.WebSite(iw).Location(1);
    yloc=Model.WebSite(iw).Location(2);

    dr=[hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep Model.Continent filesep Model.Name filesep];
    if ~exist(dr,'dir')
        mkdir(dr);
    end

    fname=[dr Model.Name '.xml'];

    switch lower(hm.Models(m).Type)
        case{'xbeachcluster'}
            cluster=1;
        otherwise
            cluster=0;
    end

    model=[];

    model.name=Model.Name;
    model.longname=Model.LongName;
    model.continent=Model.Continent;

    if ~cluster
        if ~strcmpi(Model.CoordinateSystem,'wgs 84')
            [lon,lat]=ConvertCoordinates(xloc,yloc,'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
        else
            lon=xloc;
            lat=yloc;
        end
        model.longitude=lon;
        model.latitude=lat;
    end

    model.type=Model.Type;
    model.size=Model.Size;
    model.starttime=datestr(Model.TOutputStart,'yyyymmdd HHMMSS');
    model.stoptime =datestr(Model.TStop,'yyyymmdd HHMMSS');
    model.timestep ='3';
    model.simstart=[datestr(Model.SimStart,0) ' (CET)'];
    model.simstop=[datestr(Model.SimStop,0) ' (CET)'];

    mins=floor(Model.RunDuration/60);
    secs=floor(Model.RunDuration-mins*60);
    model.runduration=[num2str(mins) 'm ' num2str(secs) 's'];

    mins=floor(Model.MoveDuration/60);
    secs=floor(Model.MoveDuration-mins*60);
    model.moveduration=[num2str(mins) 'm ' num2str(secs) 's'];

    mins=floor(Model.ExtractDuration/60);
    secs=floor(Model.ExtractDuration-mins*60);
    model.extractduration=[num2str(mins) 'm ' num2str(secs) 's'];

    mins=floor(Model.PlotDuration/60);
    secs=floor(Model.PlotDuration-mins*60);
    model.plotduration=[num2str(mins) 'm ' num2str(secs) 's'];

    mins=floor(Model.UploadDuration/60);
    secs=floor(Model.UploadDuration-mins*60);
    model.uploadduration=[num2str(mins) 'm ' num2str(secs) 's'];

    mins=floor(Model.ProcessDuration/60);
    secs=floor(Model.ProcessDuration-mins*60);
    model.processduration=[num2str(mins) 'm ' num2str(secs) 's'];

    model.cycle=hm.CycStr;
    model.lastupdate=[datestr(now,0) ' (CET)'];

    if cluster
        for j=1:Model.NrProfiles
            locx=Model.Profile(j).OriginX;
            locy=Model.Profile(j).OriginY;

            cosa=cos(pi*Model.Profile(j).Alpha/180);
            sina=sin(pi*Model.Profile(j).Alpha/180);

            locx2=locx+Model.Profile(j).Length*cosa;
            locy2=locy+Model.Profile(j).Length*sina;

            [locx,locy]=ConvertCoordinates(locx,locy,'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            [locx2,locy2]=ConvertCoordinates(locx2,locy2,'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');

            model.stations(j).station.name      = Model.Profile(j).Name;
            model.stations(j).station.longname  = ['MOP ' Model.Profile(j).Name];
            model.stations(j).station.longitude = locx;
            model.stations(j).station.latitude  = locy;
            model.stations(j).station.longitude_end = locx2;
            model.stations(j).station.latitude_end  = locy2;
            model.stations(j).station.type      = 'profile';

            fnamexml=[Model.ArchiveDir hm.CycStr filesep 'hazards' filesep Model.Profile(j).Name filesep Model.Profile(j).Name '.xml'];
            if exist(fnamexml,'file')
                h=xml_load(fnamexml);
                model.stations(j).station.hazards=h.profile.proc;
            end

        end
    end

    for j=1:Model.NrStations
        model.stations(j).station.name      = Model.Stations(j).Name;
        model.stations(j).station.longname  = Model.Stations(j).LongName;
        if ~strcmpi(Model.CoordinateSystem,'wgs 84')
            [lon,lat]=ConvertCoordinates(Model.Stations(j).Location(1),Model.Stations(j).Location(2),'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
        else
            lon=Model.Stations(j).Location(1);
            lat=Model.Stations(j).Location(2);
        end
        model.stations(j).station.longitude = lon;
        model.stations(j).station.latitude  = lat;
        model.stations(j).station.type      = Model.Stations(j).Type;

        np=0;
        for ip=1:Model.Stations(j).NrParameters
            Parameter=Model.Stations(j).Parameters(ip);
            typ=Parameter.Name;
            if Parameter.PlotCmp || Parameter.PlotPrd || Parameter.PlotObs
                np=np+1;
                model.stations(j).station.plots(np).plot.parameter=typ;
                model.stations(j).station.plots(np).plot.type='timeseries';
                model.stations(j).station.plots(np).plot.imgname=[typ '.' Model.Stations(j).Name '.png'];
            end
        end

    end

    k=0;
    for j=1:Model.nrMaps
        if Model.mapPlots(j).Plot
            k=k+1;
            model.maps(k).map.filename      = [Model.mapPlots(j).Dataset.Parameter '.' Model.Name '.kmz'];
            model.maps(k).map.parameter     = Model.mapPlots(j).Dataset.Parameter;
            model.maps(k).map.longname      = Model.mapPlots(j).longName;
            model.maps(k).map.shortname     = Model.mapPlots(j).shortName;
            model.maps(k).map.unit          = Model.mapPlots(j).Unit;
            model.maps(k).map.type          = 'kmz';

            %         xlim=Model.XLimPlot;
            %         ylim=Model.YLimPlot;
            %         if ~strcmpi(Model.CoordinateSystemType,'geographic')
            %             [xlim(1),ylim(1)]=ConvertCoordinates(xlim(1),ylim(1),Model.CoordinateSystem,Model.CoordinateSystemType,'WGS 84','geographic',hm.CoordinateSystems,hm.Operations);
            %             [xlim(2),ylim(2)]=ConvertCoordinates(xlim(2),ylim(2),Model.CoordinateSystem,Model.CoordinateSystemType,'WGS 84','geographic',hm.CoordinateSystems,hm.Operations);
            %         end
            %
            %         model.maps(k).map.xmin          = xlim(1);
            %         model.maps(k).map.xmax          = xlim(2);
            %         model.maps(k).map.ymin          = ylim(1);
            %         model.maps(k).map.ymax          = ylim(2);
            %         model.maps(k).map.animate       = 'true';
            model.maps(k).map.starttime     = datestr(hm.Cycle,'yyyymmdd HHMMSS');
            model.maps(k).map.stoptime      = datestr(hm.Cycle+Model.RunTime/1440,'yyyymmdd HHMMSS');
            model.maps(k).map.nrsteps       = (Model.RunTime)/(Model.mapPlots(j).dtAnim/60)+1;
            model.maps(k).map.timestep      = Model.mapPlots(j).dtAnim/3600;
        end
    end

    if cluster
        kmlpar={'hmax','max_runup','beachprofile_change','flood_duration','shoreline'};
        lname={'Maximum wave height','Maximum run up','Beach profile change','Flood duration','Shoreline'};
        for i=1:length(kmlpar)
            k=k+1;
            model.maps(k).map.filename  = [kmlpar{i} '.' Model.Name '.kmz'];
            model.maps(k).map.parameter = kmlpar{i};
            model.maps(k).map.longname  = lname{i};
            model.maps(k).map.shortname = kmlpar{i};
            model.maps(k).map.type      = 'kmz';
        end
    end

    xml_save(fname,model,'off');

end
