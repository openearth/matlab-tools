function cosmos_adjustInputDelft3DFLOW(hm,m)

hm.models(m).exedirflow=hm.exedirflow;

model=hm.models(m);

tmpdir=hm.tempDir;

%% MDF File
mdffile=[tmpdir model.runid '.mdf'];
cosmos_writeMDF(hm,m,mdffile);

%% Check if ini file needs to be made (used in 3d simulations)
if isempty(model.flowRstFile) && model.makeIniFile
    datafolder=[hm.scenarioDir 'oceanmodels' filesep model.oceanModel filesep];
    dataname=model.oceanModel;
    wlbndfile=[model.name '.wl.bnd'];
    wlbcafile=[model.name '.wl.bca'];
    curbndfile=[model.name '.current.bnd'];
    curbcafile=[model.name '.current.bca'];
    wlconst=model.zLevel;
    cs.name=model.coordinateSystem;
    cs.type=model.coordinateSystemType;
    writeNestXML([tmpdir 'nest.xml'],tmpdir,model.runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst,cs);
    disp('Making ini file ...');
    makeBctBccIni('ini','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',model.runid,'workdir',tmpdir,'cs',cs);
    delete([tmpdir 'nest.xml']);
end

%% Dummy.wnd
writeDummyWnd(tmpdir);

if model.includeTemperature
    %% Dummy.tmp
    writeDummyTem(tmpdir);
end

%% Meteo
if ~strcmpi(model.useMeteo,'none')

    try

        ii=strmatch(model.useMeteo,hm.meteoNames,'exact');

        coordsys=hm.models(m).coordinateSystem;
        coordsystype=hm.models(m).coordinateSystemType;

        if ~strcmpi(coordsystype,'geographic')
            dx=model.dXMeteo;
            dy=model.dYMeteo;
        else
            dx=[];
            dy=[];
        end
    
        meteodir=[hm.scenarioDir 'meteo' filesep model.useMeteo filesep];

        if model.includeTemperature
            par={'u','v','p','airtemp','relhum','cloudcover'};
        else
            par={'u','v','p'};
        end
        writeD3DMeteoFile4(meteodir,model.useMeteo,tmpdir,'meteo',model.xLim,model.yLim, ...
            coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
            'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);

    catch

        % Regular meteo failed
        disp(['Meteo from ' model.useMeteo ' failed. Trying ' model.backupMeteo]);

        if ~strcmpi(model.backupMeteo,'none')

            coordsys=hm.models(m).coordinateSystem;
            coordsystype=hm.models(m).coordinateSystemType;

            if ~strcmpi(coordsystype,'geographic')
                dx=model.dXMeteo;
                dy=model.dYMeteo;
            else
                dx=[];
                dy=[];
            end
    
            meteodir=[hm.scenarioDir 'meteo' filesep model.backupMeteo filesep];

            if model.includeTemperature
                par={'u','v','p','airtemp','relhum','cloudcover'};
            else
                par={'u','v','p'};
            end
            
            writeD3DMeteoFile4(meteodir,model.backupMeteo,tmpdir,'meteo',model.xLim,model.yLim, ...
                coordsys,coordsystype,model.refTime,model.tFlowStart,model.tStop, ...
                'parameter',par,'dx',dx,'dy',dy,'exedirflow',model.exedirflow);
            
        else
            error('No backup meteo specified!');            
        end
    end
    
end

%% Discharges
if ~isempty(model.discharge)
    % src file
    discharges=model.discharge;
    saveSrcFile([hm.tempDir model.name '.src'],discharges);
    % dis file
    for j=1:length(discharges)
        discharges(j).timeSeriesT=[model.tFlowStart model.tStop];
        discharges(j).timeSeriesQ=[model.discharge(j).q model.discharge(j).q];
        discharges(j).salinity.timeSeries=[model.discharge(j).salinity.constant model.discharge(j).salinity.constant];
        discharges(j).temperature.timeSeries=[model.discharge(j).temperature.constant model.discharge(j).temperature.constant];
        for itr=1:length(model.tracer)
            discharges(j).tracer(itr).name=model.tracer(itr).name;
            discharges(j).tracer(itr).timeSeries=[model.discharge(j).tracer(itr).constant model.discharge(j).tracer(itr).constant];
        end
    end
    saveDisFile([hm.tempDir model.name '.dis'],model.refTime,discharges) 
end

%% Observation Points
fname=[tmpdir model.name '.obs'];

fid=fopen(fname,'wt');

for istat=1:model.nrStations
    st=model.stations(istat).name;
    len=length(deblank(st));
    namestr=[st repmat(' ',1,22-len)];
    len=length(num2str(model.stations(istat).m));
    mstr=[repmat(' ',1,5-len) num2str(model.stations(istat).m)];
    len=length(num2str(model.stations(istat).n));
    nstr=[repmat(' ',1,7-len) num2str(model.stations(istat).n)];
    str=[namestr mstr nstr];
    fprintf(fid,'%s\n',str);
end

% Nesting Points
n=0;
obspm=[];
obspn=[];
for i=1:hm.nrModels
    if hm.models(i).flowNested
        if strcmpi(hm.models(i).flowNestModel,model.name)

            switch lower(hm.models(i).type)
                case{'xbeachcluster'}
                    np=hm.models(i).nrProfiles;
                otherwise
                    np=1;
            end
            
            for ip=1:np
                switch lower(hm.models(i).type)
                    case{'xbeachcluster'}
                        id=hm.models(i).profile(ip).name;
                        nstdir=[hm.models(i).dir 'nesting' filesep id filesep];
                        
                        if ~exist(nstdir,'dir')
                            MakeDir([hm.models(i).dir 'nesting'],id);
                        end
                        
                    otherwise
                        nstdir=[hm.models(i).dir 'nesting' filesep];
                end
                
                nstobs=[nstdir model.name '.obs'];
                
                if ~exist(nstobs,'file')

                    % Nest pre-processing (NESTHD1)
                    switch lower(hm.models(i).type)
                        case{'xbeachcluster'}
                            
                            mdl=hm.models(i).profile(ip);
                            mdl.alpha=pi*mdl.alpha/180;

                            fi2=fopen([hm.tempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
                            fclose(fi2);

                            % grd file
                            xg(1,1)=mdl.originX;
                            xg(1,2)=mdl.originX-sin(mdl.alpha)*0.5*mdl.dY;
                            xg(1,3)=mdl.originX-sin(mdl.alpha)*mdl.dY;

                            xg(2,1)=xg(1,1)+cos(mdl.alpha)*mdl.dY;
                            xg(2,2)=xg(1,2)+cos(mdl.alpha)*mdl.dY;
                            xg(2,3)=xg(1,3)+cos(mdl.alpha)*mdl.dY;

                            yg(1,1)=mdl.originY;
                            yg(1,2)=mdl.originY+cos(mdl.alpha)*0.5*mdl.dY;
                            yg(1,3)=mdl.originY+cos(mdl.alpha)*mdl.dY;

                            yg(2,1)=yg(1,1)+sin(mdl.alpha)*mdl.dY;
                            yg(2,2)=yg(1,2)+sin(mdl.alpha)*mdl.dY;
                            yg(2,3)=yg(1,3)+sin(mdl.alpha)*mdl.dY;
                            
                            enc=enclosure('extract',xg,yg);

                        case{'xbeach'}
                            
                            mdl=hm.models(i);
                            
                            % read grid
                            xgrdname=[mdl.dir 'input' filesep 'x.grd'];
                            ygrdname=[mdl.dir 'input' filesep 'y.grd'];
                            xgrd = load(xgrdname, '-ascii');
                            ygrd = load(ygrdname, '-ascii');
                            
                            % crop grid
                            xgrd = xgrd(:,1:2)';
                            ygrd = ygrd(:,1:2)';
                            
                            % rotate grid
                            alpha = mdl.alpha/pi*180;
                            R = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];
                            xg = mdl.xOri+R(1,1)*xgrd+R(1,2)*ygrd;
                            yg = mdl.yOri+R(2,1)*xgrd+R(2,2)*ygrd;
                            
                            % write bnd file
                            fi2=fopen([hm.tempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n',['sea                  Z T     1     2     1     ' num2str(size(xgrd,2)) ' 0.0000000e+000']);
                            fclose(fi2);
                            
                            enc=enclosure('extract',xg,yg);
                            
                        case{'delft3dflow','delft3dflowwave'}
                            grdname=[hm.models(i).dir 'input' filesep hm.models(i).name '.grd'];
                            [xg,yg,enc]=wlgrid('read',grdname);
                            [status,message,messageid]=copyfile([hm.models(i).dir 'input' filesep hm.models(i).name '.bnd'],[hm.tempDir 'temp.bnd'],'f');
                    end
                            
                    if ~strcmpi(hm.models(i).coordinateSystem,model.coordinateSystem) || ~strcmpi(hm.models(i).coordinateSystemType,model.coordinateSystemType)
                        % Convert coordinates
                        [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',hm.models(i).coordinateSystem,'CS1.type',hm.models(i).coordinateSystemType,'CS2.name',hm.models(m).coordinateSystem,'CS2.type',hm.models(m).coordinateSystemType);
                    end

                    wlgrid('write',[hm.tempDir 'temp.grd'],xg,yg,enc);

                    fi2=fopen([hm.tempDir 'nesthd1.inp'],'wt');
                    fprintf(fi2,'%s\n',[hm.tempDir model.name '.grd']);
                    fprintf(fi2,'%s\n',[hm.tempDir model.name '.enc']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.grd']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.enc']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.bnd']);
                    fprintf(fi2,'%s\n',[hm.tempDir hm.models(i).name '.nst']);
                    fprintf(fi2,'%s\n',[hm.tempDir 'temp.obs']);
                    fclose(fi2);

                    system([hm.exeDir 'nesthd1.exe < ' hm.tempDir 'nesthd1.inp']);

                    [status,message,messageid]=movefile([hm.tempDir hm.models(i).name '.nst'],nstdir,'f');
                    [status,message,messageid]=movefile([hm.tempDir 'temp.obs'],[nstdir model.name '.obs'],'f');
                    [status,message,messageid]=movefile([hm.tempDir 'temp.bnd'],[nstdir hm.models(i).name '.bnd'],'f');

                    delete([hm.tempDir 'nesthd1.inp']);
                    delete([hm.tempDir 'temp.grd']);
                    delete([hm.tempDir 'temp.enc']);
                    if exist([hm.tempDir 'temp.bnd'],'file')
                        delete([hm.tempDir 'temp.bnd'])
                    end

                end
                
                ObsPoints=ReadObsFile(nstobs);
                nrobs=length(ObsPoints);
                for j=1:nrobs
                    % Check for duplicates
                    mobs=ObsPoints(j).m;
                    nobs=ObsPoints(j).N;

                    ii=find(obspm==mobs & obspn==nobs, 1);

                    if isempty(ii)
                        n=n+1;
                        obspm(n)=mobs;
                        obspn(n)=nobs;
                        name=deblank(ObsPoints(j).name);
                        len=length(deblank(name));
                        namestr=[name repmat(' ',1,22-len)];
                        len=length(num2str(mobs));
                        mstr=[repmat(' ',1,5-len) num2str(mobs)];
                        len=length(num2str(nobs));
                        nstr=[repmat(' ',1,7-len) num2str(nobs)];
                        str=[namestr mstr nstr];
                        fprintf(fid,'%s\n',str);
                    end
                end
            end
        end
    end
end

fclose(fid);

