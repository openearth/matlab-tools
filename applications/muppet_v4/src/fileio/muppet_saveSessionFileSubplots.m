function muppet_saveSessionFileSubplots(handles,fid,ifig,isub,ilayout)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

if ilayout

    % Name
    txt=['   Subplot "Subplot ' num2str(isub) '"'];
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');

    txt=['      Position ' num2str(plt.position)];
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');

    
else
    
    ip=muppet_findIndex(handles.plottype,'plottype','name',plt.type);
    
    % First fix time axes
    switch plt.type
        case{'timeseries','timestack'}
            plt.tmin=datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
            plt.tmax=datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);
    end
    
    % Name
    txt=['   Subplot "' plt.name '"'];
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');
    
    for ii=1:length(handles.plottype(ip).plottype.option)
        handles.plottype(ip).plottype.option(ii).option.name
        iplt=muppet_findIndex(handles.subplotoption,'subplotoption','name',handles.plottype(ip).plottype.option(ii).option.name);
        switch lower(handles.plottype(ip).plottype.option(ii).option.name)
            case{'scalebarfontcolor'}
                shite=1
        end
        
        if ~isempty(iplt)
            option=handles.subplotoption(iplt).subplotoption;
            muppet_writeOption(option,plt,fid,6,21);
        end
        
    end
    
    fprintf(fid,'%s \n','');
    
    % Only write dataset for actual session files, not for layout files
    for id=1:plt.nrdatasets
        
        % Find data type
        idt=muppet_findIndex(handles.datatype,'datatype','name',plt.datasets(id).dataset.type);
        % Find plot type
        iplt=muppet_findIndex(handles.datatype(idt).datatype.plot,'plot','type',plt.type);
        % Find plot routine
        ipr=muppet_findIndex(handles.datatype(idt).datatype.plot(iplt).plot.plotroutine,'plotroutine','name',plt.datasets(id).dataset.plotroutine);
        
        plotoption=handles.datatype(idt).datatype.plot(iplt).plot.plotroutine(ipr).plotroutine.plotoption;
        
        txt=['      Dataset "' plt.datasets(id).dataset.name '"'];
        fprintf(fid,'%s \n',txt);

        for ii=1:length(plotoption)
            ipltopt=muppet_findIndex(handles.plotoption,'plotoption','name',plotoption(ii).plotoption.name);
            muppet_writeOption(handles.plotoption(ipltopt).plotoption,plt.datasets(id).dataset,fid,9,21);
            
            if isfield(handles.plotoption(ipltopt).plotoption,'element')
                for jj=1:length(handles.plotoption(ipltopt).plotoption.element)
                    muppet_writeOption(handles.plotoption(ipltopt).plotoption.element(jj).element,plt.datasets(id).dataset,fid,9,21);
                end
            end
        end
        
        txt='      EndDataset';
        fprintf(fid,'%s \n',txt);
        fprintf(fid,'%s \n','');
        
    end
end

txt='   EndSubplot';
fprintf(fid,'%s \n',txt);
fprintf(fid,'%s \n','');
