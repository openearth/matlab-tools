function handles=ddb_addOMSTideStations(handles)

xg=handles.Model(md).Input(ad).GridX;
yg=handles.Model(md).Input(ad).GridY;
zz=handles.Model(md).Input(ad).DepthZ;

jj=strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact');

for k=1:length(handles.Toolbox(jj).Database)

    if handles.Toolbox(tb).UseTideDatabase(k)

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

            if isempty(strmatch(s.IDCode{ii},Names,'exact'))

                nobs=nobs+1;
                handles.Toolbox(tb).Stations(nobs).LongName=s.Name{ii};
                handles.Toolbox(tb).Stations(nobs).Name=s.IDCode{ii};
                handles.Toolbox(tb).Stations(nobs).m=m(i);
                handles.Toolbox(tb).Stations(nobs).n=n(i);
                handles.Toolbox(tb).Stations(nobs).x=x(ii);
                handles.Toolbox(tb).Stations(nobs).y=y(ii);
                handles.Toolbox(tb).Stations(nobs).StoreSP2=0;
                handles.Toolbox(tb).Stations(nobs).SP2id='';
                handles.Toolbox(tb).Stations(nobs).Type='tidegauge';
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
                j=4;
                handles.Toolbox(tb).Stations(nobs).Parameters(j).Name=omsparameters{j};
                handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotCmp=1;
                handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotObs=0;
                handles.Toolbox(tb).Stations(nobs).Parameters(j).PlotPrd=1;
                handles.Toolbox(tb).Stations(nobs).Parameters(j).PrdSrc=src;
                handles.Toolbox(tb).Stations(nobs).Parameters(j).PrdID=s.IDCode{ii};
                
            end
        end

        handles.Toolbox(tb).NrStations=nobs;
    end
end
