function handles=muppet_editPlotOptions(handles)

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;
dataset=plt.datasets(handles.activedatasetinsubplot).dataset;

axestype=plt.type;
datatype=dataset.type;

%% Find datatype
idtype=muppet_findIndex(handles.datatype,'datatype','name',datatype);
if isempty(idtype)    
    return
end

%% Find plot options for data type
ip=muppet_findIndex(handles.datatype(idtype).datatype.plot,'plot','type',axestype);
datatype=handles.datatype(idtype).datatype.plot(ip).plot;

nplotroutines=length(datatype.plotroutine);

% First determine width and height of options
for ipr=1:nplotroutines
    plotoptions=datatype.plotroutine(ipr).plotroutine.plotoption;
    for ii=1:length(plotoptions)
        name=plotoptions(ii).plotoption.name;
        iopt=muppet_findIndex(handles.plotoption,'plotoption','name',name);
        widthopt(ipr,ii)=0;
        heightopt(ipr,ii)=0;        
        if ~isempty(iopt)
            if isfield(handles.plotoption(iopt).plotoption,'element')
                % Determine width and height of each plot option
                wdt=0;
                hgt=0;
                for ielm=1:length(handles.plotoption(iopt).plotoption.element)
                    if isfield(handles.plotoption(iopt).plotoption.element(ielm).element,'position')
                        pos=str2num(handles.plotoption(iopt).plotoption.element(ielm).element.position);
                        wdt=max(wdt,pos(1)+pos(3));
                        hgt=max(hgt,pos(2)+pos(4));
%                     else
%                         wdt=100;
%                         hgt=20;
                    end
                end
                widthopt(ipr,ii)=wdt;
                heightopt(ipr,ii)=hgt;
            end
        end
    end
end

% Now determine height and width of figure
width=0;
height=0;
for ipr=1:nplotroutines
    plotoptions=datatype.plotroutine(ipr).plotroutine.plotoption;
    wdt=0;
    hgt=0;
    for ii=1:length(plotoptions)
        wdt=max(wdt,widthopt(ipr,ii));
        hgt=hgt+heightopt(ipr,ii)+10;
    end
    width=max(width,wdt);
    height=max(height,hgt);    
end

if nplotroutines>1
    height=height+20;
end
height=height+100;
width=max(400,width);

% Popupmenu for plot routines
nelm=0;
if nplotroutines>1
     nelm=nelm+1;
     element(nelm).element.style='popupmenu';
     element(nelm).element.text='Plot Routine';
     element(nelm).element.textposition='above-left';
     element(nelm).element.variable='plotroutine';
     element(nelm).element.type='string';
     element(nelm).element.position=[25 height-50 200 20];
     for ipr=1:nplotroutines
         if isfield(datatype.plotroutine(ipr).plotroutine,'longname')
             name=datatype.plotroutine(ipr).plotroutine.longname;
         else
             name=datatype.plotroutine(ipr).plotroutine.name;
         end
         element(nelm).element.listtext(ipr).listtext=name;
         element(nelm).element.listvalue(ipr).listvalue=datatype.plotroutine(ipr).plotroutine.name;
     end
end

for ipr=1:nplotroutines
    
    if nplotroutines>1
        % Multiple plot routines, put element in different panels
        nelm=nelm+1;
        element(nelm).element.style='panel';
        element(nelm).element.tag=['panel' num2str(ipr)];
        element(nelm).element.bordertype='none';
        element(nelm).element.dependency.dependency.action='visible';
        element(nelm).element.dependency.dependency.checkfor='all';
        element(nelm).element.dependency.dependency.check.check.variable='plotroutine';
        element(nelm).element.dependency.dependency.check.check.value=datatype.plotroutine(ipr).plotroutine.name;
        element(nelm).element.dependency.dependency.check.check.operator='eq';
        element(nelm).element.position=[0 0 width height];
        posy=height-60;
    else
        posy=height-10;
    end
    
    for ii=1:length(datatype.plotroutine(ipr).plotroutine.plotoption)
        
        name=datatype.plotroutine(ipr).plotroutine.plotoption(ii).plotoption.name;
        
        % Find element in plot options element file
        iopt=muppet_findIndex(handles.plotoption,'plotoption','name',name);
        
        if ~isempty(iopt)
            
            plotoption=handles.plotoption(iopt).plotoption;
            
            
            if isfield(plotoption,'element')
                
                posy=posy-heightopt(ipr,ii)-10;
                
                %                posori(1)=width/2;
                posori(1)=25;
                posori(2)=posy;
                
                for ielm=1:length(plotoption.element)
                    
                    el=plotoption.element(ielm).element;
                    
                    if isfield(el,'style')
                        
                        nelm=nelm+1;
                        
                        if isfield(el,'position')
                            % Position relative to lower left corner
                            pos=str2num(el.position);
                            position=[posori(1)+pos(1) posori(2)+pos(2) pos(3) pos(4)];
                        else
                            position=[posori(1) posori(2) 100 20];
                        end
                        
                        if isfield(plotoption,'positionx')
                            position(1)=position(1)+str2double(plotoption.positionx);
                        end
                        
                        el.position=position;
                        
                        if nplotroutines>1
                            el.parent=['panel' num2str(ipr)];
                        end
                        
                        if ~isfield(el,'variable')
                            if isfield(plotoption,'variable')
                                el.variable=plotoption.variable;
                            else
                                el.variable=plotoption.name;
                            end
                        end
                        
                        element(nelm).element=el;
                    end
                    
                end
            end
        end
    end
end

nelm=nelm+1;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-175 25 70 25];
element(nelm).element.tag='cancel';

nelm=nelm+1;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-95 25 70 25];
element(nelm).element.tag='ok';

xml.element=element;

xml=gui_fillXMLvalues(xml);

[dataset,ok]=gui_newWindow(dataset,'element',xml.element,'tag','uifigure','width',width,'height',height,'title',[handles.datatype(idtype).datatype.longname]);

if ok
    plt.datasets(handles.activedatasetinsubplot).dataset=dataset;
    handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;
end
