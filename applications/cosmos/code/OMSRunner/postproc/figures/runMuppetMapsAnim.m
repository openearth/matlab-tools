function runMuppetAnim(hm,m)

t=0;

try
    
    Model=hm.Models(m);
    dr=Model.Dir;

    nmaps=length(Model.mapPlots);

    for im=1:nmaps
        
        handles=[];
        handles=hm.muppethandles;

        % Dataset

        ndat=length(Model.mapPlots(im).Dataset);
        
        clmap=Model.mapPlots(im).ColorMap;
        name=Model.mapPlots(im).Name;
        barlabel=Model.mapPlots(im).BarLabel;
        tit=Model.mapPlots(im).Title;
        
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
                    if strcmpi(Model.mapPlots(im).Dataset(id).Type,'2dscalar')
                        minc=min(min(min(s(id).data.Val)));
                        maxc=max(max(max(s(id).data.Val)));
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

            if strcmpi(Model.CoordinateSystemType,'geographic')
                size(s(id).data.Y)
                s(id).data.Y=merc(s(id).data.Y);
            end

        end

        for it=1:nt
            
            if it==1
                makeColorBar(handles,dr,name,clim,clmap,barlabel);
            end

            handles.NrAvailableDatasets=0;
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

            % Figure Properties
            figname=[dr 'lastrun' filesep 'figures' filesep name '.' datestr(t,'yyyymmdd.HHMMSS') '.png'];
            xlim=Model.XLimPlot;
            ylim=Model.YLimPlot;
            wdt=10;
            hgt=wdt*(merc(ylim(2))-merc(ylim(1)))/(xlim(2)-xlim(1));

            handles=setFigureProperties(handles,wdt,hgt,figname,'gmap');

            % Subplot Properties
            handles=setMapAxisProperties(handles,Model,t,wdt,hgt,tit,barlabel,clim,clmap,nd,'gmap');

            % Plot Options
            handles=setPlotOptions(handles,Model,nd);

            % Make figure
            makeMuppetFigure(handles);

        end
    end

catch

    WriteErrorLogFile(hm,['Something went wrong with generating Muppet maps - ' Model.Name]);

end
