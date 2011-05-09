function extractDataDelft3DMaps(hm,m)

Model=hm.Models(m);
dr=Model.Dir;
outdir=[dr 'lastrun' filesep 'output' filesep];
archdir = Model.ArchiveDir;

if strcmpi(Model.Type,'delft3dflow')
    Model.mapParameters{1}='wl';
    Model.mapParameters{2}='vel';
    Model.mapParameters{3}='dep';
    Model.mapParameters{4}='windvel';
    Model.mapParameters{5}='airp';
    Model.mapParameters{6}='surftemp';
    %    Model.mapParameters{5}='oil';
else
    Model.mapParameters{1}='hs';
    Model.mapParameters{2}='tp';
    Model.mapParameters{3}='vel';
    Model.mapParameters{4}='wl';
    Model.mapParameters{5}='dep';
    Model.mapParameters{6}='windvel';
    Model.mapParameters{7}='airp';
end
% Model.mapParameters{8}='hsvec';

np=length(Model.mapParameters);

for ip=1:np

    try

        par=Model.mapParameters{ip};
        fout=[archdir hm.CycStr filesep 'maps' filesep par '.mat'];

        layer=[];
        
        switch lower(par)
            case{'hs'}
                fil='wavm';
                filpar='hsig wave height';
                typ='2dscalar';
            case{'hsvec'}
                fil='wavm';
                filpar='hsig wave vector (mean direction)';
                typ='2dvector';
            case{'tp'}
                fil='wavm';
                filpar='smoothed peak period';
                typ='2dscalar';
            case{'tm'}
                fil='wavm';
                filpar='mean wave period T_{m01}';
                typ='2dscalar';
            case{'vel'}
                fil='trim';
                filpar='depth averaged velocity';
                typ='2dvector';
            case{'wl'}
                fil='trim';
                filpar='water level';
                typ='2dscalar';
            case{'dep'}
                fil='trim';
                filpar='bed level in water level points';
                typ='2dscalar';
            case{'windvel'}
                fil='meteo';
                filpar='wind speed';
                typ='2dvector';
            case{'airp'}
                fil='meteo';
                filpar='air pressure';
                typ='2dscalar';
            case{'oil'}
                fil='oil-map';
                filpar='surface oil';
                typ='2dscalar';
            case{'surftemp'}
                fil='trim';
                filpar='temperature';
                typ='2dscalar';
                layer=39;
        end

        switch fil
            case{'wavm','trim'}
                if ~exist([outdir fil '-' Model.Runid '.dat'],'file')
                    killAll;
                else
                    fid = qpfopen([outdir fil '-' Model.Runid '.dat']);
                    times = qpread(fid,1,filpar,'times');
                    if ~isempty(layer)
                        data = qpread(fid,1,filpar,'griddata',0,0,0,layer);
                        data.X=squeeze(data.X);
                        data.Y=squeeze(data.Y);
                    else
                        data = qpread(fid,1,filpar,'griddata',0,0,0);
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

        ifirst=find(times==hm.Cycle);

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
        WriteErrorLogFile(hm,['Something went wrong extracting map data - ' hm.Models(m).Name]);
    end


end
