function [handles,ok]=muppet_readSessionFile(handles,sessionfile,ilayout)

%try
    
%% Find version

fid=fopen(sessionfile);
tx0=fgets(fid);
if and(ischar(tx0), size(tx0>0))
    pos1=strfind(tx0,'Muppet v');
    pos2=strfind(tx0,'Muppet-GUI v');
    if pos1>0
        handles.sessionversion=str2num(tx0(pos1+8:pos1+11));
    elseif pos2>0
        handles.sessionversion=str2num(tx0(pos2+12:pos2+15));
    else
        handles.sessionversion=1.0;
    end
else
    handles.sessionversion=1.0;
end
fclose(fid);

%% Read entire file

fid=fopen(sessionfile);
ii=0;
while 1
    tx0=fgets(fid);
    if ~ischar(tx0)
        break
    end
        ii=ii+1;
        str{ii}=deblank2(tx0);
end
fclose(fid);

%% Determine location of datasets, figures etc.

nd=0;
ncd=0;

if ilayout==0
    
    for ii=1:length(str)

        keyword='dataset';
        if length(str{ii})>=length(keyword)
            if strcmpi(str{ii}(1:length(keyword)),keyword)
                nd=nd+1;
                data(nd).i1=ii;
            end
        end
        keyword='enddataset';
        if length(str{ii})>=length(keyword)
            if strcmpi(str{ii}(1:length(keyword)),keyword)
                data(nd).i2=ii;
            end
        end
        keyword='combineddataset';
        if length(str{ii})>=length(keyword)
            if strcmpi(str{ii}(1:length(keyword)),keyword)
                ncd=ncd+1;
                combineddata(ncd).i1=ii;
            end
        end
        keyword='endcombineddataset';
        if length(str{ii})>=length(keyword)
            if strcmpi(str{ii}(1:length(keyword)),keyword)
                combineddata(ncd).i2=ii;
            end
        end
        if length(str{ii})>=6
            if strcmpi(str{ii}(1:6),'figure')
                break
            end
        end
    end

    handles.nrdatasets=nd;
    handles.nrcombineddatasets=ncd;

end

nf=0;
if nd==0
    i1=1;
else
    i1=data(nd).i2+1;
end
for ii=i1:length(str)
    keyword='figure';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            nf=nf+1;
            fig(nf).ns=0;
            fig(nf).i1=ii;
            fig(nf).sub=[];
            fig(nf).i3=ii;
        end
    end
    keyword='subplot';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            if fig(nf).ns==0
                % First subplot found
                fig(nf).i2=ii;
            end
            fig(nf).ns=fig(nf).ns+1;
            fig(nf).sub(fig(nf).ns).i1=ii;
            fig(nf).sub(fig(nf).ns).d=[];
            fig(nf).sub(fig(nf).ns).nd=0;
        end
    end
    keyword='dataset';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            if fig(nf).sub(fig(nf).ns).nd==0
               % First dataset found
               fig(nf).sub(fig(nf).ns).i2=ii;
            end
            fig(nf).sub(fig(nf).ns).nd=fig(nf).sub(fig(nf).ns).nd+1;            
            fig(nf).sub(fig(nf).ns).d(fig(nf).sub(fig(nf).ns).nd).i1=ii;
        end
    end
    keyword='enddataset';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            fig(nf).sub(fig(nf).ns).d(fig(nf).sub(fig(nf).ns).nd).i2=ii;
        end
    end
    keyword='endsubplot';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            if fig(nf).sub(fig(nf).ns).nd==0                
              fig(nf).sub(fig(nf).ns).i2=ii;
              fig(nf).i3=ii;
            end
        end
    end
    keyword='endfigure';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)            
            if fig(nf).ns==0                
              fig(nf).i2=ii;
              fig(nf).i4=ii;
            end
        end
    end
    keyword='outputfile';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            if fig(nf).ns==0                
              fig(nf).i2=ii;
            end
            fig(nf).i3=ii;
        end
    end
    keyword='renderer';
    if length(str{ii})>=length(keyword)
        if strcmpi(str{ii}(1:length(keyword)),keyword)
            fig(nf).i4=ii;
        end
    end

end

%% Set sizes in handles structure
handles.nrfigures=nf;

%% And now read the data in the file

if ilayout==0
    % Datasets
    for id=1:handles.nrdatasets
        [keywords,values]=readkeywordvaluepairs(str,data(id).i1,data(id).i2-1);
        % Set defaults
        handles.datasets(id).dataset=muppet_setDefaultDatasetProperties;
        % Name
        ii=strmatch('dataset',lower(keywords),'exact');
        handles.datasets(id).dataset.name=values{ii};
        % File type
        ii=strmatch('filetype',lower(keywords),'exact');
        filetypename=values{ii};
        % Find info for this file type
        j=muppet_findIndex(handles.filetype,'filetype','name',filetypename);
        filetype=handles.filetype(j).filetype;
        % Now fill all the options
        for ii=1:length(filetype.option)
            j=muppet_findIndex(handles.dataproperty,'dataproperty','name',filetype.option(ii).option.name);
            dataproperty=handles.dataproperty(j).dataproperty;
            handles.datasets(id).dataset=muppet_readOption(handles,handles.datasets(id).dataset,dataproperty,keywords,values);
        end
    end
end

% Figures
for ifig=1:handles.nrfigures

    % Set figure defaults
    figr=muppet_setDefaultFigureProperties(handles);
    figr.nrsubplots=fig(ifig).ns;

    % Figure info
    i1=fig(ifig).i1;
    i2=fig(ifig).i2-1;
    [keywords,values]=readkeywordvaluepairs(str,i1,i2);
    for j=1:length(keywords)
        figr=readoption(figr,handles.figureoption,keywords{j},values{j});
    end

    % Set frame text (if not already set)
    if isfield(figr,'frame')
        ifr=strmatch(lower(figr.frame),lower(handles.frames.names),'exact');
        if ~isempty(ifr)
            if isfield(handles.frames.frame(ifr).frame,'text')
                for itxt=1:length(handles.frames.frame(ifr).frame.text)
                    if isempty(figr.frametext(itxt).frametext.text)
                        figr.frametext(itxt).frametext.text='';
                    end
                end
            end
        end
    end

    % Output settings
    i1=fig(ifig).i3;
    i2=fig(ifig).i4;
    [keywords,values]=readkeywordvaluepairs(str,i1,i2);
    for j=1:length(keywords)
        figr=readoption(figr,handles.figureoption,keywords{j},values{j});
    end
    
    for isub=1:figr.nrsubplots
        
        % Set dataset defaults
        subplt=muppet_setDefaultAxisProperties;        
        subplt.nrdatasets=fig(ifig).sub(isub).nd;

        i1=fig(ifig).sub(isub).i1;
        i2=fig(ifig).sub(isub).i2-1;
        [keywords,values]=readkeywordvaluepairs(str,i1,i2);
        for j=1:length(keywords)
            subplt=readoption(subplt,handles.subplotoption,keywords{j},values{j});
        end
        
        % And the dataset in the subplot
        for id=1:subplt.nrdatasets

            % Set dataset defaults
            dataset=muppet_setDefaultPlotOptions;
            
            i1=fig(ifig).sub(isub).d(id).i1;
            i2=fig(ifig).sub(isub).d(id).i2-1;
            [keywords,values]=readkeywordvaluepairs(str,i1,i2);
            for j=1:length(keywords)
                dataset=readoption(dataset,handles.plotoption,keywords{j},values{j});                
            end
            
            subplt.datasets(id).dataset=dataset;
                
        end
        
        figr.subplots(isub).subplot=subplt;
        
    end
    
    handles.figures(ifig).figure=figr;
    
end

% Now fix some axes stuff and deal with backward compatibility issues
for ifig=1:handles.nrfigures
    switch lower(handles.figures(ifig).figure.orientation(1))
        case{'p'}
            handles.figures(ifig).figure.orientation='portrait';
        case{'l'}
            handles.figures(ifig).figure.orientation='landscape';
    end
    
    for isub=1:handles.figures(ifig).figure.nrsubplots        
        switch handles.figures(ifig).figure.subplots(isub).subplot.type
            case{'timeseries','timestack'}
                plt=handles.figures(ifig).figure.subplots(isub).subplot;
                vec=datevec(plt.tmin);
                plt.yearmin=vec(1);
                plt.monthmin=vec(2);
                plt.daymin=vec(3);
                plt.hourmin=vec(4);
                plt.minutemin=vec(5);
                plt.secondmin=vec(6);
                vec=datevec(plt.tmax);
                plt.yearmax=vec(1);
                plt.monthmax=vec(2);
                plt.daymax=vec(3);
                plt.hourmax=vec(4);
                plt.minutemax=vec(5);
                plt.secondmax=vec(6);
                if plt.xgrid
                    plt.timegrid=1;
                    plt.xgrid=0;
                end
                handles.figures(ifig).figure.subplots(isub).subplot=plt;
            case{'map'}
                plt=handles.figures(ifig).figure.subplots(isub).subplot;
                if ~isempty(plt.scale)
                    plt.axesequal=1;
                end
                handles.figures(ifig).figure.subplots(isub).subplot=plt;
            case{'annotation'}
                handles.figures(ifig).figure.nrannotations=handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets;
                for id=1:handles.figures(ifig).figure.nrannotations
                    handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.type='annotation';
                end
        end
    end
end

% Backward compatibility
for ifig=1:handles.nrfigures
    for isub=1:handles.figures(ifig).figure.nrsubplots
        
        plt=handles.figures(ifig).figure.subplots(isub).subplot;
        
        % Scale bar
        if plt.plotscalebar
             if numel(plt.plotscalebar)==3
                 plt.scalebar.position(1)=plt.plotscalebar(1)-plt.position(1);
                 plt.scalebar.position(2)=plt.plotscalebar(2)-plt.position(2);                 
                 plt.scalebar.position(3)=plt.plotscalebar(3);                 
                 plt.plotscalebar=1;
             end
        end
        
        % North arrow
        if plt.plotnortharrow
             if numel(plt.plotnortharrow)==4
                 plt.northarrow.position(1)=plt.plotnortharrow(1)-plt.position(1);
                 plt.northarrow.position(2)=plt.plotnortharrow(2)-plt.position(2);                 
                 plt.northarrow.position(3)=plt.plotnortharrow(3);                 
                 plt.northarrow.position(4)=plt.plotnortharrow(4);                 
                 plt.plotnortharrow=1;
             end
        end
        
        handles.figures(ifig).figure.subplots(isub).subplot=plt;
    end
end

%end

ok=1;

%%
function data=readoption(data,info,keyword,valuestr)

fldname=fieldnames(info);
fldname=fldname{1};

% Find node with keyword (can also be in elements!!!)

ii=muppet_findIndex(info,fldname,'keyword',keyword);
% Backward compatibility
if isempty(ii)
    ii=muppet_findIndex(info,fldname,'keyword2',keyword);
end
if ~isempty(ii)
    info=info(ii).(fldname);
else
    % Perhaps in one the elements
    for j=1:length(info)
        if isfield(info(j).(fldname),'element')
            ii=muppet_findIndex(info(j).(fldname).element,'element','keyword',keyword);
            if isempty(ii)
                % Try old keyword
                ii=muppet_findIndex(info(j).(fldname).element,'element','keyword2',keyword);
            end
            if ~isempty(ii)
                info=info(j).(fldname).element(ii).element;
                break
            end
        end
    end
end

if ~isempty(ii)
        
    if isfield(info,'variable')
        varname0=info.variable;
    else
%        try
        varname0=info.name;
%        catch
%            shite=1
%        end
    end
    
    % Keyword found
    if ~isfield(info,'type')
        info.type='string';
    end
    
    % Check for multiple values (vector array)
    iblank=find(varname0==' ');
    if ~isempty(iblank)
        nblank=length(iblank)+1;
        iblank(end+1)=length(varname0)+1;
        varname{1}=varname0(1:iblank(1)-1);
        for jj=2:nblank
            varname{jj}=varname0(iblank(jj-1)+1:iblank(jj)-1);
        end
    else
        varname{1}=varname0;
    end
    
    switch info.type
        case{'real','int','integer','realorstring'}
            val=str2num(valuestr);
            if isempty(val)
                % Must be a string
                val=valuestr;
            end
            if length(varname)>1
                for j=1:length(varname)
                    evalstr{j}=['data.' varname{j} '=val(j);'];
                end
            else
                evalstr{1}=['data.' varname{1} '=val;'];
            end
        case{'date'}
            evalstr{1}=['data.' varname{1} '=datenum(valuestr,''yyyymmdd'');'];
        case{'datetime'}
            evalstr{1}=['data.' varname{1} '=datenum(valuestr,''yyyymmdd HHMMSS'');'];
        case{'time'}
            evalstr{1}=['data.' varname{1} '=datenum(valuestr,''HHMMSS'');'];
        case{'boolean'}
            switch lower(valuestr(1))
                case{'y','1'}
                    evalstr{1}=['data.' varname{1} '=1;'];
                otherwise
                    evalstr{1}=['data.' varname{1} '=0;'];
            end
        case{'booleanorreal'}
            % Mostly used for backward compatibility
            val=str2num(valuestr);
            if ~isempty(val)
                % It's a real
                evalstr{1}=['data.' varname{1} '=val;'];
            else
                switch lower(valuestr(1))
                    case{'y','1'}
                        evalstr{1}=['data.' varname{1} '=1;'];
                    otherwise
                        evalstr{1}=['data.' varname{1} '=0;'];
                end                
            end
        case{'indexstring'}
            evalstr{1}=['data.' varname{1} '=indexstring(''read'',valuestr);'];
        case{'filename'}
            evalstr{1}=['data.' varname{1} '=valuestr;'];
        case{'multilinetext'}
            evalstr{1}='v=strread(valuestr,''%s'',''delimiter'','';'')';
            evalstr{2}=['for n=1:length(v);strlen=length(v{n});data.' varname{1} '(n,1:strlen)=v{n};end'];
        otherwise
            evalstr{1}=['data.' varname{1} '=valuestr;'];
    end
    for j=1:length(evalstr)
        eval(evalstr{j});
    end
end

%%
function [keywords,values]=readkeywordvaluepairs(str,i1,i2)
n=0;
for ii=i1:i2
    linestr=str{ii};
    if ~isempty(linestr)
        n=n+1;
        isp=find(linestr==' ',1,'first');
        keywords{n}=linestr(1:isp-1);
        v=strread(linestr(deblank2(isp+1:end)),'%s','delimiter','"');
        if length(v)>1
            values{n}=v{2};
        else
            values{n}=v{1};
        end
    end
end
