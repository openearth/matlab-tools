function AdjustInputDelft3DFLOW(hm,m)

Model=hm.Models(m);

tmpdir=hm.TempDir;

%% MDF File
mdffile=[tmpdir Model.Runid '.mdf'];
writeMDF(hm,m,mdffile);

%% Check if ini file needs to be made (used in 3d simulations)
if isempty(Model.FlowRstFile) && Model.makeIniFile
    datafolder=[hm.ScenarioDir 'oceanmodels' filesep Model.oceanModel filesep];
    dataname=Model.oceanModel;
    wlbndfile=[Model.Name '.wl.bnd'];
    wlbcafile=[Model.Name '.wl.bca'];
    curbndfile=[Model.Name '.current.bnd'];
    curbcafile=[Model.Name '.current.bca'];
    wlconst=Model.ZLevel;
    writeNestXML([tmpdir 'nest.xml'],tmpdir,Model.Runid,datafolder,dataname,wlbndfile,wlbcafile,curbndfile,curbcafile,wlconst);
    cs.name=Model.CoordinateSystem;
    cs.type=Model.CoordinateSystemType;
    makeBctBccIni('ini','nestxml',[tmpdir 'nest.xml'],'inpdir',tmpdir,'runid',Model.Runid,'workdir',tmpdir,'cs',cs);
    delete([tmpdir 'nest.xml']);
end

%% Dummy.wnd
writeDummyWnd(tmpdir);

if Model.includeTemperature
    %% Dummy.tmp
    writeDummyTem(tmpdir);
end

%% Meteo
if ~strcmpi(Model.UseMeteo,'none')

    ii=strmatch(Model.UseMeteo,hm.MeteoNames,'exact');
    dt=hm.Meteo(ii).TimeStep;

    coordsys=hm.Models(m).CoordinateSystem;
    coordsystype=hm.Models(m).CoordinateSystemType;

    if ~strcmpi(coordsystype,'geographic')
        dx=Model.dXMeteo;
        dy=Model.dYMeteo;
    else
        dx=0;
        dy=0;
    end
    
    meteodir=[hm.ScenarioDir 'meteo' filesep Model.UseMeteo filesep];

    if Model.includeTemperature
        hstr='includeheat';
    else
        hstr='noheat';
    end
    WriteD3DMeteoFile3(meteodir,Model.UseMeteo,tmpdir,'meteo',Model.XLim,Model.YLim,dx,dy,coordsys,coordsystype,Model.RefTime,Model.TFlowStart-0.5,Model.TStop,dt,hstr);
end

%% Discharges
if ~isempty(Model.discharge)
    % src file
    discharges=Model.discharge;
    saveSrcFile([hm.TempDir Model.Name '.src'],discharges);
    % dis file
    for j=1:length(discharges)
        discharges(j).timeSeriesT=[Model.TFlowStart Model.TStop];
        discharges(j).timeSeriesQ=[Model.discharge(j).q Model.discharge(j).q];
        discharges(j).salinity.timeSeries=[Model.discharge(j).salinity.constant Model.discharge(j).salinity.constant];
        discharges(j).temperature.timeSeries=[Model.discharge(j).temperature.constant Model.discharge(j).temperature.constant];
        for itr=1:length(Model.tracer)
            discharges(j).tracer(itr).name=Model.tracer(itr).name;
            discharges(j).tracer(itr).timeSeries=[Model.discharge(j).tracer(itr).constant Model.discharge(j).tracer(itr).constant];
        end
    end
    saveDisFile([hm.TempDir Model.Name '.dis'],Model.RefTime,discharges) 
end

%% Observation Points
fname=[tmpdir Model.Name '.obs'];

fid=fopen(fname,'wt');

for i=1:Model.NrStations
    len=length(deblank(Model.Stations(i).Name));
    namestr=[Model.Stations(i).Name repmat(' ',1,22-len)];
    len=length(num2str(Model.Stations(i).M));
    mstr=[repmat(' ',1,5-len) num2str(Model.Stations(i).M)];
    len=length(num2str(Model.Stations(i).N));
    nstr=[repmat(' ',1,7-len) num2str(Model.Stations(i).N)];
    str=[namestr mstr nstr];
    fprintf(fid,'%s\n',str);
end

% Nesting Points
n=0;
obspm=[];
obspn=[];
for i=1:hm.NrModels
    if hm.Models(i).FlowNested
        if strcmpi(hm.Models(i).FlowNestModel,Model.Name)

            switch lower(hm.Models(i).Type)
                case{'xbeachcluster'}
                    np=hm.Models(i).NrProfiles;
                otherwise
                    np=1;
            end
            
            for ip=1:np
                switch lower(hm.Models(i).Type)
                    case{'xbeachcluster'}
                        id=hm.Models(i).Profile(ip).Name;
                        nstdir=[hm.Models(i).Dir 'nesting' filesep id filesep];
                        
                        if ~exist(nstdir,'dir')
                            MakeDir([hm.Models(i).Dir 'nesting'],id);
                        end
                        
                    otherwise
                        nstdir=[hm.Models(i).Dir 'nesting' filesep];
                end
                
                nstobs=[nstdir Model.Name '.obs'];
                
                if ~exist(nstobs,'file')

                    % Nest pre-processing (NESTHD1)
                    switch lower(hm.Models(i).Type)
                        case{'xbeachcluster'}
                            
                            mdl=hm.Models(i).Profile(ip);
                            mdl.Alpha=pi*mdl.Alpha/180;

                            fi2=fopen([hm.TempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n','sea                  Z T     1     2     1     3  0.0000000e+000');
                            fclose(fi2);

                            % grd file
                            xg(1,1)=mdl.OriginX;
                            xg(1,2)=mdl.OriginX-sin(mdl.Alpha)*0.5*mdl.dY;
                            xg(1,3)=mdl.OriginX-sin(mdl.Alpha)*mdl.dY;

                            xg(2,1)=xg(1,1)+cos(mdl.Alpha)*mdl.dY;
                            xg(2,2)=xg(1,2)+cos(mdl.Alpha)*mdl.dY;
                            xg(2,3)=xg(1,3)+cos(mdl.Alpha)*mdl.dY;

                            yg(1,1)=mdl.OriginY;
                            yg(1,2)=mdl.OriginY+cos(mdl.Alpha)*0.5*mdl.dY;
                            yg(1,3)=mdl.OriginY+cos(mdl.Alpha)*mdl.dY;

                            yg(2,1)=yg(1,1)+sin(mdl.Alpha)*mdl.dY;
                            yg(2,2)=yg(1,2)+sin(mdl.Alpha)*mdl.dY;
                            yg(2,3)=yg(1,3)+sin(mdl.Alpha)*mdl.dY;
                            
                            enc=enclosure('extract',xg,yg);

                        case{'xbeach'}
                            
                            mdl=hm.Models(i);
                            
                            % read grid
                            xgrdname=[mdl.Dir 'input' filesep 'x.grd'];
                            ygrdname=[mdl.Dir 'input' filesep 'y.grd'];
                            xgrd = load(xgrdname, '-ascii');
                            ygrd = load(ygrdname, '-ascii');
                            
                            % crop grid
                            xgrd = xgrd(:,1:2)';
                            ygrd = ygrd(:,1:2)';
                            
                            % rotate grid
                            alpha = mdl.alpha/pi*180;
                            R = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];
                            xg = mdl.XOri+R(1,1)*xgrd+R(1,2)*ygrd;
                            yg = mdl.YOri+R(2,1)*xgrd+R(2,2)*ygrd;
                            
                            % write bnd file
                            fi2=fopen([hm.TempDir 'temp.bnd'],'wt');
                            fprintf(fi2,'%s\n',['sea                  Z T     1     2     1     ' num2str(size(xgrd,2)) ' 0.0000000e+000']);
                            fclose(fi2);
                            
                            enc=enclosure('extract',xg,yg);
                            
                        case{'delft3dflow','delft3dflowwave'}
                            grdname=[hm.Models(i).Dir 'input' filesep hm.Models(i).Name '.grd'];
                            [xg,yg,enc]=wlgrid('read',grdname);
                            [status,message,messageid]=copyfile([hm.Models(i).Dir 'input' filesep hm.Models(i).Name '.bnd'],[hm.TempDir 'temp.bnd'],'f');
                    end
                            
                    if ~strcmpi(hm.Models(i).CoordinateSystem,Model.CoordinateSystem) || ~strcmpi(hm.Models(i).CoordinateSystemType,Model.CoordinateSystemType)
                        % Convert coordinates
                        [xg,yg]=convertCoordinates(xg,yg,'persistent','CS1.name',hm.Models(i).CoordinateSystem,'CS1.type',hm.Models(i).CoordinateSystemType,'CS2.name',hm.Models(m).CoordinateSystem,'CS2.type',hm.Models(m).CoordinateSystemType);
                    end

                    wlgrid('write',[hm.TempDir 'temp.grd'],xg,yg,enc);

                    fi2=fopen([hm.TempDir 'nesthd1.inp'],'wt');
                    fprintf(fi2,'%s\n',[hm.TempDir Model.Name '.grd']);
                    fprintf(fi2,'%s\n',[hm.TempDir Model.Name '.enc']);
                    fprintf(fi2,'%s\n',[hm.TempDir 'temp.grd']);
                    fprintf(fi2,'%s\n',[hm.TempDir 'temp.enc']);
                    fprintf(fi2,'%s\n',[hm.TempDir 'temp.bnd']);
                    fprintf(fi2,'%s\n',[hm.TempDir hm.Models(i).Name '.nst']);
                    fprintf(fi2,'%s\n',[hm.TempDir 'temp.obs']);
                    fclose(fi2);

                    system([hm.MainDir 'exe' filesep 'nesthd1.exe < ' hm.TempDir 'nesthd1.inp']);

                    [status,message,messageid]=movefile([hm.TempDir hm.Models(i).Name '.nst'],nstdir,'f');
                    [status,message,messageid]=movefile([hm.TempDir 'temp.obs'],[nstdir Model.Name '.obs'],'f');
                    [status,message,messageid]=movefile([hm.TempDir 'temp.bnd'],[nstdir hm.Models(i).Name '.bnd'],'f');

                    delete([hm.TempDir 'nesthd1.inp']);
                    delete([hm.TempDir 'temp.grd']);
                    delete([hm.TempDir 'temp.enc']);
                    if exist([hm.TempDir 'temp.bnd'],'file')
                        delete([hm.TempDir 'temp.bnd'])
                    end

                end
                
                ObsPoints=ReadObsFile(nstobs);
                nrobs=length(ObsPoints);
                for j=1:nrobs
                    % Check for duplicates
                    mobs=ObsPoints(j).M;
                    nobs=ObsPoints(j).N;

                    ii=find(obspm==mobs & obspn==nobs, 1);

                    if isempty(ii)
                        n=n+1;
                        obspm(n)=mobs;
                        obspn(n)=nobs;
                        name=deblank(ObsPoints(j).Name);
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

