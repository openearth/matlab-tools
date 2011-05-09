function runMuppetMaps(hm,m)

t=0;

posfile=['.' filesep 'pos1.dat'];

if exist(posfile,'file')
    delete(posfile);
end

try
    
    Model=hm.Models(m);
    dr=Model.Dir;

    nmaps=length(Model.mapPlots);

    for im=1:nmaps

        if Model.mapPlots(im).Plot

            if exist(posfile,'file')
                delete(posfile);
            end

            handles=hm.muppethandles;

            % Dataset

            ndat=length(Model.mapPlots(im).Dataset);

            clmap=Model.mapPlots(im).ColorMap;
            name=Model.mapPlots(im).Name;
            barlabel=Model.mapPlots(im).BarLabel;
            tit=Model.mapPlots(im).longName;

            s=[];

            for id=1:ndat

                par{id}=Model.mapPlots(im).Dataset(id).Parameter;
                
                    

                switch lower(par{id})
                    case{'landboundary'}
                        if exist([dr 'data' filesep Model.Name '.ldb'],'file')
                            [xldb,yldb]=landboundary('read',[dr 'data' filesep Model.Name '.ldb']);
                        else
                            xldb=[0;0.01;0.01];
                            yldb=[0;0;0.01];
                        end
                        s(id).data.X=xldb;
                        s(id).data.Y=yldb;
                    otherwise
                        fname=[Model.ArchiveDir hm.CycStr filesep 'maps' filesep par{id} '.mat'];
                        if exist(fname,'file')
                            s(id).data=load(fname);
                        else
                            break;
                        end
                        switch lower(Model.mapPlots(im).Dataset(id).Type)
                            case{'2dscalar','2dvector'}
                                if strcmpi(Model.mapPlots(im).Dataset(id).Type,'2dscalar')
                                    mag=s(id).data.Val;
                                else
                                    for jj=1:size(s(id).data.U,1)
                                        mag(jj,:,:)=sqrt((squeeze(s(id).data.U(jj,:,:))).^2+(squeeze(s(id).data.V(jj,:,:))).^2);
                                    end
                                end
                                minc=min(min(min(mag)));
                                maxc=max(max(max(mag)));
                                clear mag;
                                minc=min(minc,floor(minc));
                                maxc=max(maxc,ceil(maxc));
                                %             minc=max(minc,hm.Parameters(n).CLim(1));
                                %             maxc=min(maxc,hm.Parameters(n).CLim(3));
                                clim(1)=minc;
                                clim(3)=maxc;
                                clim(2)=(maxc-minc)/10;
                        end
                        nt=length(s(id).data.Time);
                end

                if ~strcmpi(Model.CoordinateSystemType,'geographic')
                    [s(id).data.X,s(id).data.Y]=ConvertCoordinates(s(id).data.X,s(id).data.Y,'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                end

                %            if strcmpi(Model.CoordinateSystemType,'geographic')
                %s(id).data.Y=merc(s(id).data.Y);
                %            end

            end

            if strcmpi(par{1},'windvel')
                % Polyline KML
                makeColorBar(handles,dr,name,clim,clmap,barlabel);
%                s(id).data.Y=invmerc(s(id).data.Y);
                [xx,yy]=meshgrid(s(1).data.X,s(1).data.Y);
                AvailableTimes=s(1).data.Time;
                dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                n3=round(Model.mapPlots(im).dtAnim/dt);
                tim=s(id).data.Time(1:n3:end);
                uu=s(1).data.U(1:n3:end,:,:);
                vv=s(1).data.V(1:n3:end,:,:);
                fdr=[dr 'lastrun' filesep 'figures' filesep];
%                 curvecKML([name '.' Model.Name],xx,yy,s(1).data.U,s(1).data.V,'time',s(id).data.Time,'kmz',1,'colormap',jet(64),'levels',clim(1):clim(2):clim(3), ...
%                     'directory',fdr,'screenoverlay',[name '.colorbar.png'],'ddtcurvec',Model.mapPlots(im).Dataset(1).DdtCurVec, ...
%                     'dxcurvec',Model.mapPlots(im).Dataset(1).DxCurVec,'dtcurvec',Model.mapPlots(im).Dataset(1).DtCurVec);
                curvecKML([name '.' Model.Name],xx,yy,uu,vv,'time',tim,'kmz',1,'colormap',jet(64),'levels',clim(1):0.5:clim(3), ...
                    'directory',fdr,'screenoverlay',[name '.colorbar.png'],'ddtcurvec',Model.mapPlots(im).Dataset(1).DdtCurVec, ...
                    'dxcurvec',Model.mapPlots(im).Dataset(1).DxCurVec,'dtcurvec',Model.mapPlots(im).Dataset(1).DtCurVec);
                if exist([fdr name '.colorbar.png'],'file')
                    delete([fdr name '.colorbar.png']);
                end

            else
                % Muppet

                if ~isempty(s)
                    AvailableTimes=s(1).data.Time;
                    dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                    n2=round(dt/(Model.mapPlots(im).dtAnim));

                    n3=round(Model.mapPlots(im).dtAnim/dt);

                    it2=0;
                    t2=[];

                    for it=1:n3:nt

                        if it==1
                            makeColorBar(handles,dr,name,clim,clmap,barlabel);
                        end

                        handles.NrAvailableDatasets=0;

                        if it<nt
                            ninterm=max(1,n2);
                        else
                            ninterm=1;
                        end

                        for ii=1:ninterm

                            nd=0;

                            for id=1:ndat

                                handles.NrAvailableDatasets=handles.NrAvailableDatasets+1;
                                nd=nd+1;

                                handles=InitializeDataProperties(handles,nd);
                                handles.DataProperties(nd).Name=par{id};

                                switch lower(Model.mapPlots(im).Dataset(id).Type)
                                    case{'landboundary'}
                                        handles.DataProperties(id).x=xldb;
                                        handles.DataProperties(id).y=yldb;
                                        handles.DataProperties(id).z=0;
                                        handles.DataProperties(id).Type = 'Polyline';
                                        handles.DataProperties(id).TC='c';
                                    case{'2dvector'}
                                        t=s(id).data.Time(it);
                                        data.x=s(id).data.X;
                                        data.y=s(id).data.Y;
                                        data.U=s(id).data.U(it,:,:);
                                        data.V=s(id).data.V(it,:,:);
                                        if n2>1
                                            if it<nt
                                                f1=(n2+1-ii)/n2;
                                                f2=1-f1;
                                                data2.U=s(id).data.U(it+1,:,:);
                                                data2.V=s(id).data.V(it+1,:,:);
                                                data.U=f1*data.U+f2*data2.U;
                                                data.V=f1*data.V+f2*data2.V;
                                                t=t+(ii-1)*Model.mapPlots(im).dtAnim/86400;
                                            end
                                        end
                                        x=data.x;
                                        y=data.y;
                                        if size(x,1)==1
                                            [x,y]=meshgrid(x,y);
                                        end
                                        handles.DataProperties(id).x=x;
                                        handles.DataProperties(id).y=y;
                                        handles.DataProperties(id).u=squeeze(data.U);
                                        handles.DataProperties(id).v=squeeze(data.V);
                                        handles.DataProperties(id).Type='2dvector';
                                    case{'2dscalar'}
                                        if ndims(s(id).data.Val)==2
                                            data.Val=s(id).data.Val(:,:);
                                        else
                                            data.Val=s(id).data.Val(it,:,:);
                                            t=s(id).data.Time(it);
                                            if n2>1
                                                if it<nt
                                                    f1=(n2+1-ii)/n2;
                                                    f2=1-f1;
                                                    data2.Val=s(id).data.Val(it+1,:,:);
                                                    data.Val=f1*data.Val+f2*data2.Val;
                                                end
                                                t=t+(ii-1)*Model.mapPlots(im).dtAnim/86400;
                                            end
                                        end
                                        data.x=s(id).data.X;
                                        data.y=s(id).data.Y;
                                        x=data.x;
                                        y=data.y;
                                        if size(x,1)==1
                                            [x,y]=meshgrid(x,y);
                                        end
                                        handles.DataProperties(id).x=x;
                                        handles.DataProperties(id).y=y;
                                        handles.DataProperties(id).z=squeeze(data.Val);
                                        handles.DataProperties(id).zz=squeeze(data.Val);
                                        handles.DataProperties(id).Type='2dscalar';
                                end
                            end

                            it2=it2+1;
                            t2(it2)=t;

                            % Figure Properties
                            figname=[dr 'lastrun' filesep 'figures' filesep name '.' datestr(t,'yyyymmdd.HHMMSS') '.png'];

                            xlimori=Model.XLimPlot;
                            ylimori=Model.YLimPlot;

                            xlim=Model.XLimPlot;
                            ylim=Model.YLimPlot;

                            if ~strcmpi(Model.CoordinateSystemType,'geographic')
                                [xlim(1),ylim(1)]=ConvertCoordinates(xlim(1),ylim(1),'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                                [xlim(2),ylim(2)]=ConvertCoordinates(xlim(2),ylim(2),'CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                            end

                            Model.XLimPlot=xlim;
                            Model.YLimPlot=ylim;

                            wdt=10;
%                            hgt=wdt*(merc(ylim(2))-merc(ylim(1)))/(xlim(2)-xlim(1));
                            hgt=wdt*(ylim(2)-ylim(1))/(xlim(2)-xlim(1));

                            handles=setFigureProperties(handles,wdt,hgt,figname,'gmap');

                            % Subplot Properties
                            handles=setMapAxisProperties(handles,Model,t,wdt,hgt,tit,barlabel,clim,clmap,nd,'gmap');

                            % Plot Options
                            handles=setPlotOptions(handles,Model,nd,clim,im);

                            Model.XLimPlot=xlimori;
                            Model.YLimPlot=ylimori;

                            % Make figure
                            makeMuppetFigure(handles);

                        end

                    end

                    figdr=[dr 'lastrun' filesep 'figures' filesep];

                    url = Model.mapPlots(im).Url;

                    flist=[];

                    for it=1:length(t2)
                        flist{it}=[name '.' datestr(t2(it),'yyyymmdd.HHMMSS') '.png'];
                    end

                    if ~isempty(flist)
                        writeMapKMZ('filename',[name '.' Model.Name],'dir',figdr,'filelist',flist,'colorbar',[name '.colorbar.png'],'xlim',xlim,'ylim',ylim,'deletefiles',1);
                    end

                    %                writeAnimKML(figdr,url,name,xlim,ylim,t2);
                end

            end
            
            if exist(posfile,'file')
                delete(posfile);
            end
        end

    end

catch

    WriteErrorLogFile(hm,['Something went wrong with generating Muppet maps - ' Model.Name]);

end

if exist(posfile,'file')
    delete(posfile);
end
