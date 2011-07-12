function cosmos_extractDataDelft3DMaps(hm,m)

Model=hm.Models(m);
dr=Model.Dir;
outdir=[dr 'lastrun' filesep 'output' filesep];
archdir = Model.ArchiveDir;

% Model.mapParameters={''};
% np=0;
% for i=1:length(Model.mapPlots)
%     par=Model.mapPlots(i).Dataset(1).Parameter;
%     ii=strmatch(par,Model.mapParameters,'exact');
%     % Skip duplicate map parameters (which occur in more than one plot)
%     if isempty(ii)
%         np=np+1;
%         Model.mapParameters{np}=Model.mapPlots(i).Dataset(1).Parameter;
%     end
% end

np=Model.nrMapDatasets;

for ip=1:np

    try

        par=Model.mapDatasets(ip).name;
        fout=[archdir hm.CycStr filesep 'maps' filesep par '.mat'];
        
        data=[];
        
        fil=getParameterInfo(hm,par,'model',Model.Type,'datatype','map','file');
        filpar=getParameterInfo(hm,par,'model',Model.Type,'datatype','map','name');
        typ=getParameterInfo(hm,par,'type');
        
        switch lower(typ)
            case{'magnitude','angle'}
                typ='2dscalar';
            case{'vector'}
                typ='2dvector';
        end

        layer=Model.mapPlots(ip).Dataset(1).layer;
        
        switch fil
            case{'wavm','trim'}
                if ~exist([outdir fil '-' Model.Runid '.dat'],'file')
                    disp(['trim file ' Model.Name ' does not exist!']);
%                    killAll;
                else
                    fid = qpfopen([outdir fil '-' Model.Runid '.dat']);
                    times = qpread(fid,1,filpar,'times');
                    data.Val=zeros();
                    % Read first time step to get dimensions and grid
                    if ~isempty(layer)
                        data0 = qpread(fid,1,filpar,'griddata',1,0,0,layer);
                    else
                        data0 = qpread(fid,1,filpar,'griddata',1,0,0);
                    end                    
                    data.X=squeeze(data0.X);
                    data.Y=squeeze(data0.Y);
                    data.Val=zeros(length(times),size(data.X,1),size(data.X,2));
                    % Loop through all time steps
                    for it=1:length(times)
                        if ~isempty(layer)
                            d = qpread(fid,1,filpar,'data',it,0,0,layer);
                        else
                            if length(times)>1
                                d = qpread(fid,1,filpar,'data',it,0,0);    
                            else
                                d = qpread(fid,1,filpar,'data',0,0);    
                            end
                        end
                        if isfield(d,'Val')
                            data.Val(it,:,:)=d.Val;
                        else
                            data.XComp(it,:,:)=d.XComp;
                            data.YComp(it,:,:)=d.YComp;
                        end
                    end
                    switch lower(par)
                        case{'hs','tp'}
                            data.Val(data.Val==0)=NaN;
                    end
                end
            case{'meteo'}
                ii=strmatch(Model.UseMeteo,hm.MeteoNames,'exact');
                dt=hm.Meteo(ii).TimeStep;
                data = extractMeteoData([hm.ScenarioDir 'meteo' filesep Model.UseMeteo filesep],Model,dt,par);
                times = data.Time;
            case{'oil-map'}
                %                data=getSurfaceOil(outdir,Model.Runid,'Ekofisk (floating)');
                data=getSurfaceOil(outdir,Model.Runid,'light_crude');
                times=data.Time;
        end

        s=[];
        s.Parameter=par;
        s.X=data.X;
        s.Y=data.Y;

        ifirst=find(abs(times-hm.Cycle)<0.001);

        if ~isempty(ifirst)
            s.Time=times(ifirst:end);
        else
            s.Time=times;
        end

        switch typ
            case{'2dscalar'}
                if ndims(data.Val)==3
                    s.Val=data.Val(ifirst:end,:,:);
                else
                    s.Val=data.Val;
                end
                save(fout,'-struct','s','Parameter','Time','X','Y','Val');
            case{'2dvector'}
                if ndims(data.XComp)==3
                    s.U=data.XComp(ifirst:end,:,:);
                    s.V=data.YComp(ifirst:end,:,:);
                else
                    s.U=data.XComp;
                    s.V=data.YComp;
                end
                %                s.Mag=sqrt(s.U.^2+s.V.^2);
                %                save(fout,'-struct','s','Parameter','Time','X','Y','U','V','Mag');
                save(fout,'-struct','s','Parameter','Time','X','Y','U','V');
        end
        %     for t=t0:(dt/1440):t1;
        %    it=find(times==t);
        %         s.Val=hs.Val();
        %     fout=[archdir 'appended\maps\hs.' datestr(t,'yyyymmdd.HHMMSS') '.mat'];
        %     save(fout,'-struct','s','Parameter','Time','x','y','Val');
        %     end
    catch
        WriteErrorLogFile(hm,['Something went wrong extracting map data - ' par ' from ' fil ' in ' hm.Models(m).Name]);
    end


end
