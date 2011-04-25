function ddb_NestingToolbox_nestHD2(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setUIElements('nestpanel.nesthd2');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'nesthd2'}
            nestHD2;
    end    
end

%%
function nestHD2

handles=getHandles;

hisfile=handles.Toolbox(tb).Input.trihFile;
nestadm=handles.Toolbox(tb).Input.admFile;
z0=handles.Toolbox(tb).Input.zCor;
opt='';
if handles.Toolbox(tb).Input.nestHydro && handles.Toolbox(tb).Input.nestTransport
    opt='both';
elseif handles.Toolbox(tb).Input.nestHydro
    opt='hydro';
elseif handles.Toolbox(tb).Input.nestTransport
    opt='transport';
end
stride=1;

if ~isempty(opt)
    % Make structure info for nesthd2
    bnd=handles.Model(md).Input(ad).openBoundaries;
    % Vertical grid info
    vertGrid.KMax=handles.Model(md).Input(ad).KMax;
    vertGrid.layerType=handles.Model(md).Input(ad).layerType;
    vertGrid.thick=handles.Model(md).Input(ad).thick;
    vertGrid.zTop=handles.Model(md).Input(ad).zTop;
    vertGrid.zBot=handles.Model(md).Input(ad).zBot;
    % Consituent info
    % Run Nesthd2
    bnd=nesthd2('openboundaries',bnd,'vertgrid',vertGrid,'hisfile',hisfile,'admfile',nestadm,'zcor',z0,'stride',stride,'opt',opt);
    
    zersunif=zeros(2,1);
    
    for i=1:length(bnd)

        if strcmpi(bnd(i).forcing,'T')
            
            if handles.Toolbox(tb).Input.nestHydro
                % Copy boundary data
                % Hydrodynamics
                handles.Model(md).Input(ad).openBoundaries(i).nrTimeSeries=length(bnd(i).timeSeriesT);
                handles.Model(md).Input(ad).openBoundaries(i).timeSeriesT=bnd(i).timeSeriesT;
                handles.Model(md).Input(ad).openBoundaries(i).timeSeriesA=bnd(i).timeSeriesA;
                handles.Model(md).Input(ad).openBoundaries(i).timeSeriesB=bnd(i).timeSeriesB;
                handles.Model(md).Input(ad).openBoundaries(i).timeSeriesAV=bnd(i).timeSeriesAV;
                handles.Model(md).Input(ad).openBoundaries(i).timeSeriesBV=bnd(i).timeSeriesBV;
                handles.Model(md).Input(ad).openBoundaries(i).profile=bnd(i).profile;
            end
            
            if handles.Toolbox(tb).Input.nestTransport
                % Transport
                
                % Salinity
                
                handles.Model(md).Input(ad).openBoundaries(i).salinity.nrTimeSeries=2;
                handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
                
                handles.Model(md).Input(ad).openBoundaries(i).salinity.profile='uniform';
                handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesA=zersunif+handles.Model(md).Input(ad).salinity.ICConst;
                handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesB=zersunif+handles.Model(md).Input(ad).salinity.ICConst;
                
                if handles.Model(md).Input(ad).salinity.include
                    if isfield(bnd(i),'salinity')
                        handles.Model(md).Input(ad).openBoundaries(i).salinity.nrTimeSeries=length(bnd(i).salinity.timeSeriesT);
                        handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesT=bnd(i).salinity.timeSeriesT;
                        handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesA=bnd(i).salinity.timeSeriesA;
                        handles.Model(md).Input(ad).openBoundaries(i).salinity.timeSeriesB=bnd(i).salinity.timeSeriesB;
                        handles.Model(md).Input(ad).openBoundaries(i).salinity.profile=bnd(i).salinity.profile;
                    end
                end
                
                % Temperature
                handles.Model(md).Input(ad).openBoundaries(i).temperature.nrTimeSeries=2;
                handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
                
                handles.Model(md).Input(ad).openBoundaries(i).temperature.profile='uniform';
                handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesA=zersunif+handles.Model(md).Input(ad).temperature.ICConst;
                handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesB=zersunif+handles.Model(md).Input(ad).temperature.ICConst;
                
                if handles.Model(md).Input(ad).temperature.include
                    if isfield(bnd(i),'temperature')
                        handles.Model(md).Input(ad).openBoundaries(i).temperature.nrTimeSeries=length(bnd(i).temperature.timeSeriesT);
                        handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesT=bnd(i).temperature.timeSeriesT;
                        handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesA=bnd(i).temperature.timeSeriesA;
                        handles.Model(md).Input(ad).openBoundaries(i).temperature.timeSeriesB=bnd(i).temperature.timeSeriesB;
                        handles.Model(md).Input(ad).openBoundaries(i).temperature.profile=bnd(i).temperature.profile;
                    end
                end
                
                % Tracers
                for j=1:handles.Model(md).Input(ad).nrTracers
                    handles.Model(md).Input(ad).openBoundaries(i).tracer(j).nrTimeSeries=2;
                    handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
                    
                    handles.Model(md).Input(ad).openBoundaries(i).tracer(j).profile='uniform';
                    handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesA=zersunif;
                    handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesB=zersunif;
                    
                    if isfield(bnd(i),'tracer')
                        if length(bnd(i).tracer)<=j
                            handles.Model(md).Input(ad).openBoundaries(i).tracer(j).nrTimeSeries=length(bnd(i).tracer(j).timeSeriesT);
                            handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesT=bnd(i).tracer(j).timeSeriesT;
                            handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesA=bnd(i).tracer(j).timeSeriesA;
                            handles.Model(md).Input(ad).openBoundaries(i).tracer(j).timeSeriesB=bnd(i).tracer(j).timeSeriesB;
                            handles.Model(md).Input(ad).openBoundaries(i).tracer(j).profile=bnd(i).tracer(j).profile;
                        end
                    end
                end
                
                % Sediments
                for j=1:handles.Model(md).Input(ad).nrSediments
                    
                    handles.Model(md).Input(ad).openBoundaries(i).sediment(j).nrTimeSeries=2;
                    handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesT=[handles.Model(md).Input(ad).startTime handles.Model(md).Input(ad).stopTime];
                    
                    handles.Model(md).Input(ad).openBoundaries(i).sediment(j).profile='uniform';
                    handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesA=zersunif;
                    handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesB=zersunif;
                    
                    if isfield(bnd(i),'sediment')
                        if length(bnd(i).sediment)<=j
                            handles.Model(md).Input(ad).openBoundaries(i).sediment(j).nrTimeSeries=length(bnd(i).tracer(j).timeSeriesT);
                            handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesT=bnd(i).tracer(j).timeSeriesT;
                            handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesA=bnd(i).tracer(j).timeSeriesA;
                            handles.Model(md).Input(ad).openBoundaries(i).sediment(j).timeSeriesB=bnd(i).tracer(j).timeSeriesB;
                            handles.Model(md).Input(ad).openBoundaries(i).sediment(j).profile=bnd(i).tracer(j).profile;
                        end
                    end
                end
            end
            
        end
        
    end

    
    if handles.Toolbox(tb).Input.nestHydro
        [filename, pathname, filterindex] = uiputfile('*.bct','Select Timeseries Conditions File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(ad).bctFile=filename;
            ddb_saveBctFile(handles,ad);
        end
    end
    
    
    if handles.Toolbox(tb).Input.nestTransport
        [filename, pathname, filterindex] = uiputfile('*.bcc','Select Transport Conditions File');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            handles.Model(md).Input(ad).bccFile=filename;
            ddb_saveBccFile(handles,ad);
        end
    end


end

setHandles(handles);
