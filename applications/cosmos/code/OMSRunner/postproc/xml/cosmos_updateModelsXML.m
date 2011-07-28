function cosmos_updateModelsXML(hm,m)

% Updates model xml file for all websites

Model=hm.Models(m);

for iw=1:length(Model.WebSite)

    wbdir=Model.WebSite(iw).Name;

    dr=[hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep];
%    dr=[hm.WebDir wbdir filesep 'scenarios' filesep hm.Scenario filesep Model.Continent filesep Model.Name filesep];
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

    model.name.value=Model.Name;
    model.name.type='char';

    model.longname.value=Model.LongName;
    model.longname.type='char';

    model.continent.value=Model.Continent;
    model.continent.type='char';

    
    %% Location
    
    if ~cluster
        % Get value from xml
        xloc=Model.WebSite(iw).Location(1);
        yloc=Model.WebSite(iw).Location(2);
    else
        % Take average of start and end profile
        xloc=0.5*(Model.Profile(1).OriginX+Model.Profile(end).OriginX);
        yloc=0.5*(Model.Profile(1).OriginY+Model.Profile(end).OriginY);  
    end

    if ~strcmpi(Model.CoordinateSystem,'wgs 84')
        [lon,lat]=convertCoordinates(xloc,yloc,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    else
        lon=xloc;
        lat=yloc;
    end

    model.longitude.value=lon;
    model.longitude.type='real';
    
    model.latitude.value=lat;
    model.latitude.type='real';
    
    %% Elevation

    % First try to determine distance between corner points of model limits
    if ~cluster
        % Get value from xml
        xlim=Model.XLim;
        ylim=Model.YLim;
    else
        % Take average of start and end profile
        for i=1:length(Model.Profile)
            xloc(i)=Model.Profile(i).OriginX;
            yloc(i)=Model.Profile(i).OriginY;
        end
        xlim(1)=min(xloc);
        xlim(2)=max(xloc);
        ylim(1)=min(yloc);
        ylim(2)=max(yloc);
    end    
    if ~strcmpi(Model.CoordinateSystem,'wgs 84')
        [xlim,ylim]=convertCoordinates(xlim,ylim,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    end
    dstx=111111*(xlim(2)-xlim(1))*cos(mean(ylim)*pi/180);
    dsty=111111*(ylim(2)-ylim(1));    
    dst=sqrt(dstx^2+dsty^2);

    % Elevation is distance times 2
    dst=dst*2;
    dst=min(dst,10000000);

    model.elevation.value=dst;
    model.elevation.type='real';

    %% Types and size

    model.type.value=Model.Type;
    model.type.type='char';
    
    model.size.value=Model.Size;
    model.size.type='int';
    
    model.starttime.value=Model.TOutputStart;
    model.starttime.type='date';
    
    model.stoptime.value=Model.TStop;
    model.stoptime.type='date';

    model.timestep.value=3;
    model.timestep.type='real';

    %% Duration

    model.simstart.value=[datestr(Model.SimStart,0) ' (CET)'];
    model.simstart.type='char';

    model.simstop.value=[datestr(Model.SimStop,0) ' (CET)'];
    model.simstop.type='char';

    mins=floor(Model.RunDuration/60);
    secs=floor(Model.RunDuration-mins*60);
    model.runduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.runduration.type='char';

    mins=floor(Model.MoveDuration/60);
    secs=floor(Model.MoveDuration-mins*60);
    model.moveduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.moveduration.type='char';

    mins=floor(Model.ExtractDuration/60);
    secs=floor(Model.ExtractDuration-mins*60);
    model.extractduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.extractduration.type='char';

    mins=floor(Model.PlotDuration/60);
    secs=floor(Model.PlotDuration-mins*60);
    model.plotduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.plotduration.type='char';

    mins=floor(Model.UploadDuration/60);
    secs=floor(Model.UploadDuration-mins*60);
    model.uploadduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.uploadduration.type='char';

    mins=floor(Model.ProcessDuration/60);
    secs=floor(Model.ProcessDuration-mins*60);
    model.processduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    model.processduration.type='char';

    model.cycle.value=hm.CycStr;
    model.cycle.type='char';

    model.lastupdate.value=[datestr(now,0) ' (CET)'];
    model.lastupdate.type='char';

    %% Profiles

    if cluster
        for j=1:Model.NrProfiles
            locx=Model.Profile(j).OriginX;
            locy=Model.Profile(j).OriginY;

            cosa=cos(pi*Model.Profile(j).Alpha/180);
            sina=sin(pi*Model.Profile(j).Alpha/180);

            locx2=locx+Model.Profile(j).Length*cosa;
            locy2=locy+Model.Profile(j).Length*sina;

            [locx,locy]=convertCoordinates(locx,locy,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            [locx2,locy2]=convertCoordinates(locx2,locy2,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');

            model.stations(j).station.name.value          = Model.Profile(j).Name;
            model.stations(j).station.name.type           = 'char';

            model.stations(j).station.longname.value      = ['MOP ' Model.Profile(j).Name];
            model.stations(j).station.longname.type           = 'char';

            model.stations(j).station.longitude.value     = locx;
            model.stations(j).station.longitude.type      = 'real';

            model.stations(j).station.latitude.value      = locy;
            model.stations(j).station.latitude.type       = 'real';

            model.stations(j).station.longitude_end.value = locx2;
            model.stations(j).station.longitude_end.type  = 'real';

            model.stations(j).station.latitude_end.value  = locy2;
            model.stations(j).station.latitude_end.type   = 'real';

            model.stations(j).station.type.value          = 'profile';
            model.stations(j).station.type.type           = 'char';

%            fnamexml=[Model.ArchiveDir hm.CycStr filesep 'hazards' filesep Model.Profile(j).Name filesep Model.Profile(j).Name '.xml'];
%            if exist(fnamexml,'file')
%                h=xml_load(fnamexml);
%                model.stations(j).station.hazards=h.profile.proc;
%            end

        end
    end

    %% Stations
    j=0;
    for ist=1:Model.NrStations
        
        iok=0;

        station=Model.Stations(ist);

        % First check if any plots are made for this station. If not, skip
        % it.
        for ip=1:station.NrParameters
            Parameter=station.Parameters(ip);
            if Parameter.PlotCmp || Parameter.PlotPrd || Parameter.PlotObs
                iok=1;
            end
        end
        
        if iok
            
            j=j+1;
            
            model.stations(j).station.name.value = station.Name;
            model.stations(j).station.name.type  = 'char';

            model.stations(j).station.longname.value = station.LongName;
            model.stations(j).station.longname.type  = 'char';

            if ~strcmpi(Model.CoordinateSystem,'wgs 84')
                [lon,lat]=convertCoordinates(station.Location(1),station.Location(2),'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            else
                lon=station.Location(1);
                lat=station.Location(2);
            end

            model.stations(j).station.longitude.value = lon;
            model.stations(j).station.longitude.type  = 'real';

            model.stations(j).station.latitude.value  = lat;
            model.stations(j).station.latitude.type   = 'real';

            model.stations(j).station.type.value      = station.Type;
            model.stations(j).station.type.type       = 'char';
            
            np=0;
            for ip=1:station.NrParameters
                Parameter=station.Parameters(ip);
                typ=Parameter.Name;
                if Parameter.PlotCmp || Parameter.PlotPrd || Parameter.PlotObs

                    np=np+1;

                    model.stations(j).station.plots(np).plot.parameter.value = typ;
                    model.stations(j).station.plots(np).plot.parameter.type  = 'char';

                    model.stations(j).station.plots(np).plot.type.value      = 'timeseries';
                    model.stations(j).station.plots(np).plot.type.type       = 'char';

                    model.stations(j).station.plots(np).plot.imgname.value   = [typ '.' station.Name '.png'];
                    model.stations(j).station.plots(np).plot.imgname.type    = 'char';

                end
            end
        end
        
    end

    %% Maps

    k=0;
    for j=1:Model.nrMapPlots
        if Model.mapPlots(j).plot
            k=k+1;
            model.maps(k).map.filename.value     = [Model.mapPlots(j).name '.' Model.Name '.kmz'];
            model.maps(k).map.filename.type      = 'char';

            model.maps(k).map.parameter.value    = Model.mapPlots(j).name;
            model.maps(k).map.parameter.type     = 'char';

            model.maps(k).map.longname.value      = Model.mapPlots(j).longName;
            model.maps(k).map.longname.type     = 'char';

%            model.maps(k).map.shortname.value     = Model.mapPlots(j).shortName;
%            model.maps(k).map.shortname.type     = 'char';

%            model.maps(k).map.unit.value          = Model.mapPlots(j).Unit;
%            model.maps(k).map.unit.type     = 'char';

            model.maps(k).map.type.value      = 'kmz';
            model.maps(k).map.type.type       = 'char';

            model.maps(k).map.starttime.value = hm.Cycle;
            model.maps(k).map.starttime.type  = 'date';

            model.maps(k).map.stoptime.value  = hm.Cycle+Model.RunTime/1440;
            model.maps(k).map.stoptime.type   = 'date';

            model.maps(k).map.nrsteps.value   = (Model.RunTime)/(Model.mapPlots(j).timeStep/60)+1;
            model.maps(k).map.nrsteps.type    = 'int';

            model.maps(k).map.timestep.value  = Model.mapPlots(j).timeStep/3600;
            model.maps(k).map.timestep.type   = 'real';

        end
    end

    if cluster
        kmlpar={'hmax','max_runup','beachprofile_change','flood_duration','shoreline'};
        lname={'Maximum wave height','Maximum run up','Beach profile change','Flood duration','Shoreline'};
        for i=1:length(kmlpar)

            k=k+1;

            model.maps(k).map.filename.value  = [kmlpar{i} '.' Model.Name '.kmz'];
            model.maps(k).map.filename.type   = 'char';

            model.maps(k).map.parameter.value = kmlpar{i};
            model.maps(k).map.parameter.type   = 'char';

            model.maps(k).map.longname.value  = lname{i};
            model.maps(k).map.longname.type   = 'char';

            model.maps(k).map.shortname.value = kmlpar{i};
            model.maps(k).map.shortname.type   = 'char';

            model.maps(k).map.type.value      = 'kmz';
            model.maps(k).map.type.type   = 'char';
        end
    end

    struct2xml(fname,model);
%    xml_save(fname,model,'off');

end
