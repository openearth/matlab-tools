function cosmos_makeMapKMZs(hm,m)
% Makes map plots and KMZs

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

            % Dataset

            ndat=length(Model.mapPlots(im).Dataset);

            clmap=Model.mapPlots(im).ColorMap;
            name=Model.mapPlots(im).Name;
            barlabel=Model.mapPlots(im).BarLabel;

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
                                if isempty(Model.mapPlots(im).Dataset(id).cLim)
                                    clim(1)=minc;
                                    clim(3)=maxc;
                                    [tck,cdec]=cosmos_getTicksAndDecimals(clim(1),clim(3),10);
                                    clim(2)=tck;
                                else
                                    clim=Model.mapPlots(im).Dataset(id).cLim;
                                    cdec=3;
                                end
                                if ~isempty(Model.mapPlots(im).colorBarDecimals)
                                    cdec=Model.mapPlots(im).colorBarDecimals;
                                end
                        end
                        nt=length(s(id).data.Time);
                end

                if ~strcmpi(Model.CoordinateSystemType,'geographic')
                    [s(id).data.X,s(id).data.Y]=ConvertCoordinates(s(id).data.X,s(id).data.Y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                end

            end

            if strcmpi(par{1},'windvel')
                % Polyline KML
                clrbarname=[dr 'lastrun' filesep 'figures' filesep name '.colorbar.png'];
                cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                [xx,yy]=meshgrid(s(1).data.X,s(1).data.Y);
                AvailableTimes=s(1).data.Time;
                dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                n3=round(Model.mapPlots(im).dtAnim/dt);
                tim=s(id).data.Time(1:n3:end);
                uu=s(1).data.U(1:n3:end,:,:);
                vv=s(1).data.V(1:n3:end,:,:);
                fdr=[dr 'lastrun' filesep 'figures' filesep];
                curvecKML([name '.' Model.Name],xx,yy,uu,vv,'time',tim,'kmz',1,'colormap',jet(64),'levels',clim(1):clim(2):clim(3), ...
                    'directory',fdr,'screenoverlay',[name '.colorbar.png'],'ddtcurvec',Model.mapPlots(im).Dataset(1).DdtCurVec, ...
                    'dxcurvec',Model.mapPlots(im).Dataset(1).DxCurVec,'dtcurvec',Model.mapPlots(im).Dataset(1).DtCurVec);
                if exist([fdr name '.colorbar.png'],'file')
                    delete([fdr name '.colorbar.png']);
                end

            elseif strcmpi(par{1},'surfvel')
                % Polyline KML
                clrbarname=[dr 'lastrun' filesep 'figures' filesep name '.colorbar.png'];
                cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                xx=s(1).data.X;
                yy=s(1).data.Y;
                AvailableTimes=s(1).data.Time;
                dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                n3=round(Model.mapPlots(im).dtAnim/dt);
                tim=s(id).data.Time(1:n3:end);
                uu=s(1).data.U(1:n3:end,:,:);
                vv=s(1).data.V(1:n3:end,:,:);
                fdr=[dr 'lastrun' filesep 'figures' filesep];
                quiverKML([name '.' Model.Name],xx,yy,uu,vv,'time',tim,'kmz',1,'colormap',jet(64),'levels',clim(1):clim(2):clim(3), ...
                    'directory',fdr,'screenoverlay',[name '.colorbar.png']);
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
                            clrbarname=[dr 'lastrun' filesep 'figures' filesep name '.colorbar.png'];
                            cosmos_makeColorBar(clrbarname,'contours',clim(1):clim(2):clim(3),'colormap',clmap,'label',barlabel,'decimals',cdec);
                        end
                        
                        if it<nt
                            ninterm=max(1,n2);
                        else
                            ninterm=1;
                        end

                        for ii=1:ninterm

                            nd=0;

                            for id=1:ndat

                                nd=nd+1;

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
                                
                                dmp.x=x;
                                dmp.y=y;
                                dmp.z=squeeze(data.Val);
                                dmp.zz=squeeze(data.Val);

                            end

                            it2=it2+1;
                            t2(it2)=t;

                            % Figure Properties
                            figname=[dr 'lastrun' filesep 'figures' filesep name '.' datestr(t,'yyyymmdd.HHMMSS') '.png'];

                            xlim=Model.XLimPlot;
                            ylim=Model.YLimPlot;

                            if ~strcmpi(Model.CoordinateSystemType,'geographic')
                                [xlim(1),ylim(1)]=convertCoordinates(xlim(1),ylim(1),'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                                [xlim(2),ylim(2)]=convertCoordinates(xlim(2),ylim(2),'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                            end

                            % Make figure
                            cosmos_mapPlot(figname,dmp,'xlim',xlim,'ylim',ylim,'clim',[clim(1) clim(3)]);

                        end

                    end

                    figdr=[dr 'lastrun' filesep 'figures' filesep];

                    flist=[];

                    for it=1:length(t2)
                        flist{it}=[name '.' datestr(t2(it),'yyyymmdd.HHMMSS') '.png'];
                    end

                    if ~isempty(flist)
                        writeMapKMZ('filename',[name '.' Model.Name],'dir',figdr,'filelist',flist,'colorbar',[name '.colorbar.png'],'xlim',xlim,'ylim',ylim,'deletefiles',1);
                    end

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
