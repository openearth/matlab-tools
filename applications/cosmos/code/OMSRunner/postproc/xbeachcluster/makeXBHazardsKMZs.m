function makeXBHazardsKMZs(hm,m)

Model=hm.Models(m);
figdir=[Model.Dir 'lastrun' filesep 'figures' filesep];

n=0;
x0=[];
y0=[];
x1=[];
y1=[];

for i=1:Model.NrProfiles
    
    prf=Model.Profile(i).Name;
    
    xmldir=[Model.ArchiveDir hm.CycStr filesep 'hazards' filesep prf filesep];
    fname=[xmldir prf '.xml'];
       
    if exist(fname,'file')
        
        s=xml_load(fname);
        n=n+1;
        
        x0(n)=str2double(s.profile.originx);
        y0(n)=str2double(s.profile.originy);
        
        cosa=cos(pi*str2double(s.profile.alpha)/180);
        sina=sin(pi*str2double(s.profile.alpha)/180);
        
        x1(n)=x0(n)+str2double(s.profile.length)*cosa;
        y1(n)=y0(n)+str2double(s.profile.length)*sina;
        
        col={'hmax','max_runup','beachprofile_change','flood_duration'};
        barlabel={'Maximum wave height (m)','Maximum run-up (mNAVD)','Beach erosion (m^2/m)','Flood duration (h)'};

        clmap0=[0 0 0 0];
        dclmap=[1 0.5 0.1 5];
        clmap1=[8 5 1 40];
        
        for j=1:length(col)
            columns.(col{j})(n)=str2double(s.profile.proc.(col{j}));
        end
        
        lin={'original_shoreline','shoreline_change','original_backbeach','backbeach_change','max_runup_dist'};
        for j=1:length(lin)
            lines.(lin{j})(n)=str2double(s.profile.proc.(lin{j}));
        end
        
        original_shoreline_x(n)=x0(n)+lines.original_shoreline(n)*cosa;
        original_shoreline_y(n)=y0(n)+lines.original_shoreline(n)*sina;
        
        final_shoreline_x(n)=x0(n)+(lines.original_shoreline(n)-lines.shoreline_change(n))*cosa;
        final_shoreline_y(n)=y0(n)+(lines.original_shoreline(n)-lines.shoreline_change(n))*sina;
        
        original_backbeach_x(n)=x0(n)+lines.original_backbeach(n)*cosa;
        original_backbeach_y(n)=y0(n)+lines.original_backbeach(n)*sina;
        
        final_backbeach_x(n)=x0(n)+(lines.original_backbeach(n)-lines.backbeach_change(n))*cosa;
        final_backbeach_y(n)=y0(n)+(lines.original_backbeach(n)-lines.backbeach_change(n))*sina;
        
        max_runup_x(n)=x0(n)+lines.max_runup_dist(n)*cosa;
        max_runup_y(n)=y0(n)+lines.max_runup_dist(n)*sina;
        
    end
end

if n>0

    %% Columns
    columns.beachprofile_change=-columns.beachprofile_change;
    
    [x0,y0]=ConvertCoordinates(x0,y0,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    [x1,y1]=ConvertCoordinates(x1,y1,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    
%     profileKML(['profiles.' Model.Name],x0,y0,x1,y1,'kmz',1,'directory',figdir);
    
    % Look at profile in middle
    % Coastal Hazards
%     ic=ceil(length(x0)/2);
%     lookat.longitude=x0(ic);
%     lookat.latitude=y0(ic);
%     lookat.altitude=0;
%     lookat.range=10000;
%     lookat.tilt=70;
%     ang=180*atan2(y0(end)-y0(1),x0(end)-x0(1))/pi;
%     ang=180-ang;
%     lookat.heading=ang;

    ic=ceil(length(x0)/2);
    lookat.longitude=x0(ic);
    lookat.latitude=y0(ic);
    lookat.altitude=0;
    lookat.range=75000;
    lookat.tilt=70;
    ang=180*atan2(y0(end)-y0(1),x0(end)-x0(1))/pi;
    ang=180-ang;
    ang=ang-180;
    lookat.heading=ang;

    for j=1:length(col)
        clim=[clmap0(j):dclmap(j):clmap1(j)];

        zmax=max(columns.(col{j}));
        zfac=250/zmax;
        zfac=1000/zmax;
        
        handles=hm.muppethandles;
        clim=[clmap0(j) dclmap(j) clmap1(j)];
        makeColorBar(handles,Model.Dir,col{j},clim,'jet',barlabel{j});
        clim=[clmap0(j):dclmap(j):clmap1(j)];
%        columnKML([col{j} '.' Model.Name],x0,y0,columns.(col{j}),'colormap',jet,'levels',clim,'kmz',1,'radius',15,'zfac',zfac,'directory',figdir,'url',Model.figureURL,'screenoverlay',[figdir col{j} '.colorbar.png'],'lookat',lookat);
        columnKML([col{j} '.' Model.Name],x0,y0,columns.(col{j}),'colormap',jet,'levels',clim,'kmz',1,'radius',100,'zfac',zfac,'directory',figdir,'url',Model.figureURL,'screenoverlay',[figdir col{j} '.colorbar.png'],'lookat',lookat);
        if exist([figdir col{j} '.colorbar.png'],'file')
            delete([figdir col{j} '.colorbar.png']);
        end
    end
    
    [original_shoreline_x,original_shoreline_y]=ConvertCoordinates(original_shoreline_x,original_shoreline_y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    [final_shoreline_x,final_shoreline_y]=ConvertCoordinates(final_shoreline_x,final_shoreline_y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    [original_backbeach_x,original_backbeach_y]=ConvertCoordinates(original_backbeach_x,original_backbeach_y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    [final_backbeach_x,final_backbeach_y]=ConvertCoordinates(final_backbeach_x,final_backbeach_y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    [max_runup_x,max_runup_y]=ConvertCoordinates(max_runup_x,max_runup_y,'persistent','CS1.name',Model.CoordinateSystem,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    
    %% Lines
    lookat.tilt=10;
    
    col={'b','r','g','c',[0.99 0.99 0.99]};
    wdt=[2 2 2 2 2];
    marker={'','','','',''};
    txt={'Original shoreline','New shoreline','Original backbeach','New backbeach','Maximum run-up line'};
    makeLegend([figdir 'legend.png'],col,wdt,marker,txt);
    linesKML(figdir,['shoreline.' Model.Name],original_shoreline_x,original_shoreline_y,final_shoreline_x,final_shoreline_y,original_backbeach_x,original_backbeach_y,final_backbeach_x,final_backbeach_y,max_runup_x,max_runup_y,lookat);
    if exist([figdir 'legend.png'],'file')
        delete([figdir 'legend.png']);
    end
    
end
    

