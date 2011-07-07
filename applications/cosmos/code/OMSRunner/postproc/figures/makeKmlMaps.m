function makeKmlMaps(hm,m)

try
    
    Model=hm.Models(m);
    dr=Model.Dir;
    figdr=[dr 'lastrun' filesep 'figures' filesep];
    nmaps=length(Model.mapPlots);

    for im=1:nmaps

        if Model.mapPlots(im).Plot

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
                        mag=[];
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
%                                 clear mag;
                                minc=min(minc,floor(minc));
                                maxc=max(maxc,ceil(maxc));
%                                 minc=min(minc,0);
                                %             minc=max(minc,hm.Parameters(n).CLim(1));
                                %             maxc=min(maxc,hm.Parameters(n).CLim(3));
%                                 clim(1)=minc;
%                                 clim(3)=maxc;
%                                 clim(2)=(maxc-minc)/10;
                                
                                [clim(1),clim(2),clim(3)]=getColorLims(minc,maxc);
                                
                        end
                        nt=length(s(id).data.Time);
                end

                if ~strcmpi(Model.CoordinateSystemType,'geographic')
                    [s(id).data.X,s(id).data.Y]=ConvertCoordinates(s(id).data.X,s(id).data.Y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                end

            end

            if ~isempty(s)

                handles=hm.muppethandles;
                barlabel=Model.mapPlots(im).BarLabel;
                makeColorBar(handles,dr,par{id},clim,'jet',barlabel);
                colbarfil=[figdr par{id} '.colorbar.png'];
                
                availableTimes=s(1).data.Time;
                dt=86400*(availableTimes(2)-availableTimes(1));
                n2=round(Model.mapPlots(im).dtAnim/dt);

                it1=1;
                it2=length(s(id).data.Time);

                x=s(id).data.X;
                y=s(id).data.Y;
                % z=s(id).data.Val(it1:n2:it2,:,:);
                z=mag(it1:n2:it2,:,:);
                t=s(id).data.Time(it1:n2:it2);
                fname=[par{id} '.' Model.Name];
                contourfKML(fname,x,y,z,'time',t,'levels',clim(1):clim(2):clim(3),'colormap',jet(64),'screenoverlay',colbarfil,'kmz',1,'directory',figdr);
                if exist(colbarfil,'file')
                    delete(colbarfil);
                end
            end
            
        end

    end

catch

    WriteErrorLogFile(hm,['Something went wrong with generating KML maps - ' Model.Name]);

end
