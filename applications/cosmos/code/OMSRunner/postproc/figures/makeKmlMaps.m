function makeKmlMaps(hm,m)

try
    
    model=hm.models(m);
    dr=model.dir;
    figdr=[dr 'lastrun' filesep 'figures' filesep];
    nmaps=length(model.mapPlots);

    for im=1:nmaps

        if model.mapPlots(im).plot

            ndat=length(model.mapPlots(im).Dataset);

            clmap=model.mapPlots(im).colorMap;
            name=model.mapPlots(im).name;
            barlabel=model.mapPlots(im).BarLabel;
            tit=model.mapPlots(im).longName;

            s=[];

            for id=1:ndat

                par{id}=model.mapPlots(im).Dataset(id).parameter;

                switch lower(par{id})
                    case{'landboundary'}
                        if exist([dr 'data' filesep model.name '.ldb'],'file')
                            [xldb,yldb]=landboundary('read',[dr 'data' filesep model.name '.ldb']);
                        else
                            xldb=[0;0.01;0.01];
                            yldb=[0;0;0.01];
                        end
                        s(id).data.X=xldb;
                        s(id).data.Y=yldb;
                    otherwise
                        fname=[model.archiveDir hm.cycStr filesep 'maps' filesep par{id} '.mat'];
                        if exist(fname,'file')
                            s(id).data=load(fname);
                        else
                            break;
                        end
                        mag=[];
                        switch lower(model.mapPlots(im).Dataset(id).type)
                            case{'2dscalar','2dvector'}
                                if strcmpi(model.mapPlots(im).Dataset(id).type,'2dscalar')
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
                                %             minc=max(minc,hm.parameters(n).cLim(1));
                                %             maxc=min(maxc,hm.parameters(n).cLim(3));
%                                 clim(1)=minc;
%                                 clim(3)=maxc;
%                                 clim(2)=(maxc-minc)/10;
                                
                                [clim(1),clim(2),clim(3)]=getColorLims(minc,maxc);
                                
                        end
                        nt=length(s(id).data.time);
                end

                if ~strcmpi(model.coordinateSystemType,'geographic')
                    [s(id).data.X,s(id).data.Y]=ConvertCoordinates(s(id).data.X,s(id).data.Y,'persistent','CS1.name',model.coordinateSystem,'CS1.type',model.coordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
                end

            end

            if ~isempty(s)

                handles=hm.muppethandles;
                barlabel=model.mapPlots(im).BarLabel;
                makeColorBar(handles,dr,par{id},clim,'jet',barlabel);
                colbarfil=[figdr par{id} '.colorbar.png'];
                
                availableTimes=s(1).data.time;
                dt=86400*(availableTimes(2)-availableTimes(1));
                n2=round(model.mapPlots(im).dtAnim/dt);

                it1=1;
                it2=length(s(id).data.time);

                x=s(id).data.X;
                y=s(id).data.Y;
                % z=s(id).data.Val(it1:n2:it2,:,:);
                z=mag(it1:n2:it2,:,:);
                t=s(id).data.time(it1:n2:it2);
                fname=[par{id} '.' model.name];
                contourfKML(fname,x,y,z,'time',t,'levels',clim(1):clim(2):clim(3),'colormap',jet(64),'screenoverlay',colbarfil,'kmz',1,'directory',figdr);
                if exist(colbarfil,'file')
                    delete(colbarfil);
                end
            end
            
        end

    end

catch

    WriteErrorLogFile(hm,['Something went wrong with generating KML maps - ' model.name]);

end
