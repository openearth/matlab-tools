function handles=muppet_addDatasetToSubplot(handles)

% Data
id=handles.activedataset;
data=handles.datasets(id).dataset;
idtype=strmatch(data.type,handles.datatypenames,'exact');
if isempty(idtype)
    disp('Unknown data type!');
    return
end

updateaxes=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.adjustaxes;
plottype=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type;

%% Determine plot type
switch plottype
    case{'unknown'}
        % New type
        handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=muppet_setDefaultAxisProperties(handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot);
        handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot.type=handles.datatype(idtype).datatype.plot(1).plot.type;        
        updateaxes=1;
        iplttype=1;
    otherwise
        % Subplot already has a type, check if dataset can be added to this
        % subplot
        iplttype=[];
        for ii=1:length(handles.datatype(idtype).datatype.plot)
            if strcmpi(plottype,handles.datatype(idtype).datatype.plot(ii).plot.type)
                iplttype=ii;
                break
            end
        end
        if isempty(iplttype)
            disp(['Dataset of type ' data.type ' cannot be added plots of type ' plottype ' !']);
            return
        end
end

plt=handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot;

nrd=plt.nrdatasets+1;
plt.nrdatasets=nrd;
plt.activedataset=nrd;
handles.activedatasetinsubplot=nrd;
nrd=plt.nrdatasets;

% First set default plot options
plotdata=muppet_setDefaultPlotOptions;
plotdata.name=data.name;
plotdata.type=data.type;

%% Add plot options
plotroutine=handles.datatype(idtype).datatype.plot(iplttype).plot.plotroutine(1).plotroutine;
plotdata.plotroutine=plotroutine.name;
for ii=1:length(plotroutine.plotoption)
    name=plotroutine.plotoption(ii).plotoption.name;
    iplt=muppet_findIndex(handles.plotoption,'plotoption','name',name);
    if ~isempty(iplt)
        plotoption=handles.plotoption(iplt).plotoption;
        if isfield(plotoption,'default')
            if isstruct(plotoption.default)
                % Count number of datasets in this subplot that use the same
                % plot routine
                n=1;
                for jj=1:nrd-1
                    if strcmpi(plt.datasets(jj).dataset.plotroutine,plotdata.plotroutine)
                        n=n+1;
                    end
                end
                n=min(n,length(plotoption.default));
                value=plotoption.default(n).default;
            else
                value=plotoption.default;
            end
            if isfield(plotoption,'type')
                switch lower(plotoption.type)
                    case{'real','int','boolean','integer'}
                        value=str2num(value);
                end
            end
            eval(['plotdata.' name '=value;']);
        end
        if isfield(plotoption,'element')
            for ielm=1:length(plotoption.element)

                name=plotroutine.plotoption(ii).plotoption.name;

                if isfield(plotoption.element(ielm).element,'default')
                    
                    if isfield(plotoption.element(ielm).element,'variable')
                        varname=plotoption.element(ielm).element.variable;
                    end

                    if isstruct(plotoption.element(ielm).element.default)
                        % Count number of datasets in this subplot that use the same
                        % plot routine
                        n=1;
                        for jj=1:nrd-1
                            if strcmpi(plt.datasets(jj).dataset.plotroutine,plotdata.plotroutine)
                                n=n+1;
                            end
                        end
                        n=min(n,length(plotoption.element(ielm).element.default));
                        value=plotoption.element(ielm).element.default(n).default;
                    else
                        value=plotoption.element(ielm).element.default;
                    end
                    if isfield(plotoption.element(ielm).element,'type')
                        switch lower(plotoption.element(ielm).element.type)
                            case{'real','int','boolean','integer'}
                                value=str2num(value);
                        end
                    end
                    eval(['plotdata.' varname '=value;']);
                end
            end
        end
        if strcmpi(name,'legendtext')
            plotdata.legendtext=plotdata.name;
        end
    end
end

plt.datasets(nrd).dataset=plotdata;

handles.figures(handles.activefigure).figure.subplots(handles.activesubplot).subplot=plt;

%% Update axes
if updateaxes
     handles=muppet_adjustAxes(handles);
end

handles=muppet_updateDatasetInSubplotNames(handles);
