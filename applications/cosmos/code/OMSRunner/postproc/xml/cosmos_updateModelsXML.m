function cosmos_updateModelsXML(hm,m)

% Updates model xml file for all websites

model=hm.models(m);

for iw=1:length(model.webSite)

    wbdir=model.webSite(iw).name;

    dr=[hm.webDir wbdir filesep 'scenarios' filesep hm.scenario filesep];

    if ~exist(dr,'dir')
        mkdir(dr);
    end

    fname=[dr model.name '.xml'];

    switch lower(hm.models(m).type)
        case{'xbeachcluster'}
            cluster=1;
        otherwise
            cluster=0;
    end

    mdl=[];

    mdl.name.value=model.name;
    mdl.name.type='char';

    mdl.longname.value=model.longName;
    mdl.longname.type='char';

    mdl.continent.value=model.continent;
    mdl.continent.type='char';

    
    %% Location
    
    if ~cluster
        % Get value from xml
        xloc=model.webSite(iw).Location(1);
        yloc=model.webSite(iw).Location(2);
    else
        % Take average of start and end profile
        xloc=0.5*(model.profile(1).originX+model.profile(end).originX);
        yloc=0.5*(model.profile(1).originY+model.profile(end).originY);  
    end

    if ~strcmpi(model.coordinateSystem,'wgs 84')
        [lon,lat]=convertCoordinates(xloc,yloc,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    else
        lon=xloc;
        lat=yloc;
    end

    mdl.longitude.value=lon;
    mdl.longitude.type='real';
    
    mdl.latitude.value=lat;
    mdl.latitude.type='real';
    
    %% Overlay
    if ~isempty(model.webSite(iw).overlayFile)
        mdl.overlay.value=model.webSite(iw).overlayFile;
        mdl.overlay.type='char';
    end
    
    %% Elevation

    % First try to determine distance between corner points of model limits
    
    if ~cluster
        % Get value from xml
        xlim=model.xLim;
        ylim=model.yLim;
    else
        % Take average of start and end profile
        for i=1:length(model.profile)
            xloc(i)=model.profile(i).originX;
            yloc(i)=model.profile(i).originY;
        end
        xlim(1)=min(xloc);
        xlim(2)=max(xloc);
        ylim(1)=min(yloc);
        ylim(2)=max(yloc);
    end
    if ~strcmpi(model.coordinateSystem,'wgs 84')
        [xlim,ylim]=convertCoordinates(xlim,ylim,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    end
    dstx=111111*(xlim(2)-xlim(1))*cos(mean(ylim)*pi/180);
    dsty=111111*(ylim(2)-ylim(1));
    dst=sqrt(dstx^2+dsty^2);
    
    % Elevation is distance times 2
    dst=dst*2;
    dst=min(dst,10000000);
    
    if isempty(model.webSite(iw).elevation)
        mdl.elevation.value=dst;
        mdl.elevation.type='real';
    else isfield(model.webSite(iw),'elevation')
        mdl.elevation.value=min(hm.models(m).webSite(iw).elevation,10000000);
        mdl.elevation.type='real';
    end

    %% Types and size

    mdl.type.value=model.type;
    mdl.type.type='char';
    
    mdl.size.value=model.size;
    mdl.size.type='int';
    
    mdl.starttime.value=model.tOutputStart;
    mdl.starttime.type='date';
    
    mdl.stoptime.value=model.tStop;
    mdl.stoptime.type='date';

    mdl.timestep.value=3;
    mdl.timestep.type='real';

    %% Duration

    mdl.simstart.value=[datestr(model.simStart,0) ' (CET)'];
    mdl.simstart.type='char';

    mdl.simstop.value=[datestr(model.simStop,0) ' (CET)'];
    mdl.simstop.type='char';

    mins=floor(model.runDuration/60);
    secs=floor(model.runDuration-mins*60);
    mdl.runduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.runduration.type='char';

    mins=floor(model.moveDuration/60);
    secs=floor(model.moveDuration-mins*60);
    mdl.moveduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.moveduration.type='char';

    mins=floor(model.extractDuration/60);
    secs=floor(model.extractDuration-mins*60);
    mdl.extractduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.extractduration.type='char';

    mins=floor(model.plotDuration/60);
    secs=floor(model.plotDuration-mins*60);
    mdl.plotduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.plotduration.type='char';

    mins=floor(model.uploadDuration/60);
    secs=floor(model.uploadDuration-mins*60);
    mdl.uploadduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.uploadduration.type='char';

    mins=floor(model.processDuration/60);
    secs=floor(model.processDuration-mins*60);
    mdl.processduration.value=[num2str(mins) 'm ' num2str(secs) 's'];
    mdl.processduration.type='char';

    mdl.cycle.value=hm.cycStr;
    mdl.cycle.type='char';

    mdl.lastupdate.value=[datestr(now,0) ' (CET)'];
    mdl.lastupdate.type='char';

    if ~isempty(model.timeZone)
        mdl.timezone.value=model.timeZone;
        mdl.timezone.type='char';
%     else
%         mdl.timezone.value='UTC';
%         mdl.timezone.type='char';
    end
%     mdl.timezone.type='char';

%    if model.timeShift~=0
        mdl.timeshift.value=model.timeShift;
        mdl.timeshift.type='int';
%     else
%         mdl.timezone.value='UTC';
%         mdl.timezone.type='char';
%    end

    %% Profiles

    if cluster
        for j=1:model.nrProfiles
            locx=model.profile(j).originX;
            locy=model.profile(j).originY;

            cosa=cos(pi*model.profile(j).alpha/180);
            sina=sin(pi*model.profile(j).alpha/180);

            locx2=locx+model.profile(j).length*cosa;
            locy2=locy+model.profile(j).length*sina;

            [locx,locy]=convertCoordinates(locx,locy,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
            [locx2,locy2]=convertCoordinates(locx2,locy2,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');

            mdl.stations(j).station.name.value          = model.profile(j).name;
            mdl.stations(j).station.name.type           = 'char';

            mdl.stations(j).station.longname.value      = ['MOP ' model.profile(j).name];
            mdl.stations(j).station.longname.type           = 'char';

            mdl.stations(j).station.longitude.value     = locx;
            mdl.stations(j).station.longitude.type      = 'real';

            mdl.stations(j).station.latitude.value      = locy;
            mdl.stations(j).station.latitude.type       = 'real';

            mdl.stations(j).station.longitude_end.value = locx2;
            mdl.stations(j).station.longitude_end.type  = 'real';

            mdl.stations(j).station.latitude_end.value  = locy2;
            mdl.stations(j).station.latitude_end.type   = 'real';

            mdl.stations(j).station.type.value          = 'profile';
            mdl.stations(j).station.type.type           = 'char';

            mdl.stations(j).station.html.value          = [model.profile(j).name '.html'];
            mdl.stations(j).station.html.type           = 'char';

%            fnamexml=[model.archiveDir hm.cycStr filesep 'hazards' filesep model.profile(j).name filesep model.profile(j).name '.xml'];
%            if exist(fnamexml,'file')
%                h=xml_load(fnamexml);
%                mdl.stations(j).station.hazards=h.profile.proc;
%            end

            % Plots
            mdl.stations(j).station.plots(1).plot.parameter.value = 'beachprofile';
            mdl.stations(j).station.plots(1).plot.parameter.type  = 'char';
            
            mdl.stations(j).station.plots(1).plot.type.value      = 'beachprofile';
            mdl.stations(j).station.plots(1).plot.type.type       = 'char';
            
            mdl.stations(j).station.plots(1).plot.imgname.value   = [model.profile(j).name '.png'];
            mdl.stations(j).station.plots(1).plot.imgname.type    = 'char';

        end
    end

    %% Stations
    j=0;

    for ist=1:model.nrStations
        
        station=model.stations(ist);
        
        j=j+1;
        
        mdl.stations(j).station.name.value = station.name;
        mdl.stations(j).station.name.type  = 'char';
        
        mdl.stations(j).station.longname.value = station.longName;
        mdl.stations(j).station.longname.type  = 'char';
        
        if ~strcmpi(model.coordinateSystem,'wgs 84')
            [lon,lat]=convertCoordinates(station.location(1),station.location(2),'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
        else
            lon=station.location(1);
            lat=station.location(2);
        end
        
        mdl.stations(j).station.longitude.value = lon;
        mdl.stations(j).station.longitude.type  = 'real';
        
        mdl.stations(j).station.latitude.value  = lat;
        mdl.stations(j).station.latitude.type   = 'real';
        
        mdl.stations(j).station.type.value      = station.type;
        mdl.stations(j).station.type.type       = 'char';
        
        mdl.stations(j).station.html.value      = [station.name '.html'];
        mdl.stations(j).station.html.type       = 'char';
        
    end
    
    %% Maps

    k=0;
    for j=1:model.nrMapPlots
        if model.mapPlots(j).plot
            
            k=k+1;
            
            switch lower(model.mapPlots(j).type)
                case{'kmz'}
                    mapfilename=[model.mapPlots(j).name '.' model.name '.kmz'];
                case{'vectorxml'}
                    mapfilename=[model.mapPlots(j).name '.' model.name '.xml'];
            end
            
            mdl.maps(k).map.filename.value     = mapfilename;
            mdl.maps(k).map.filename.type      = 'char';

            mdl.maps(k).map.parameter.value    = model.mapPlots(j).name;
            mdl.maps(k).map.parameter.type     = 'char';

            mdl.maps(k).map.longname.value      = model.mapPlots(j).longName;
            mdl.maps(k).map.longname.type     = 'char';

%            mdl.maps(k).map.shortname.value     = model.mapPlots(j).shortName;
%            mdl.maps(k).map.shortname.type     = 'char';

%            mdl.maps(k).map.unit.value          = model.mapPlots(j).Unit;
%            mdl.maps(k).map.unit.type     = 'char';

            mdl.maps(k).map.type.value      = model.mapPlots(j).type;
            mdl.maps(k).map.type.type       = 'char';

%            mdl.maps(k).map.starttime.value = hm.cycle+model.timeShift/24;
            mdl.maps(k).map.starttime.value = hm.cycle;
            mdl.maps(k).map.starttime.type  = 'date';

%            mdl.maps(k).map.stoptime.value  = hm.cycle+model.runTime/1440+model.timeShift/24;
            mdl.maps(k).map.stoptime.value  = hm.cycle+model.runTime/1440;
            mdl.maps(k).map.stoptime.type   = 'date';

            if ~isempty(model.mapPlots(j).timeStep)
                mdl.maps(k).map.nrsteps.value   = (model.runTime)/(model.mapPlots(j).timeStep/60)+1;
                mdl.maps(k).map.nrsteps.type    = 'int';                
                mdl.maps(k).map.timestep.value  = model.mapPlots(j).timeStep/3600;
                mdl.maps(k).map.timestep.type   = 'real';
            else
                mdl.maps(k).map.nrsteps.value   = 1;
                mdl.maps(k).map.nrsteps.type    = 'int';
            end

        end
    end

    if cluster
        kmlpar={'hmax','max_runup','beachprofile_change','flood_duration','shoreline'};
        lname={'Maximum wave height','Maximum run up','Beach profile change','Flood duration','Shoreline'};
        for i=1:length(kmlpar)

            k=k+1;

            mdl.maps(k).map.filename.value  = [kmlpar{i} '.' model.name '.kmz'];
            mdl.maps(k).map.filename.type   = 'char';

            mdl.maps(k).map.parameter.value = kmlpar{i};
            mdl.maps(k).map.parameter.type   = 'char';

            mdl.maps(k).map.longname.value  = lname{i};
            mdl.maps(k).map.longname.type   = 'char';

            mdl.maps(k).map.shortname.value = kmlpar{i};
            mdl.maps(k).map.shortname.type   = 'char';

            mdl.maps(k).map.type.value      = 'kmz';
            mdl.maps(k).map.type.type   = 'char';
        end
    end

    %% Hazards
    hazarchdir=model.cycledirhazards;
    flist=dir([hazarchdir '*.xml']);
    for ih=1:length(flist)
        s=xml2struct([hazarchdir flist(ih).name]);
        mdl.warnings(ih).warning=s;
    end
    
    struct2xml(fname,mdl,'includeattributes',1,'structuretype',0);

end
