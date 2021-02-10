function ddb_shorelines_open_input(opt)

handles=getHandles;

switch lower(opt)
    case{'open'}

        [filename, pathname, filterindex] = uigetfile('shorelines.inp','Select ShorelineS file');

        if pathname~=0

            pathname=pathname(1:end-1); % Get rid of last file seperator
            if ~strcmpi(pathname,handles.workingDirectory)
                cd(pathname);
                handles.workingDirectory=pathname;
            end

            % Delete all domains
            ddb_plotshorelines('delete','domain',1);
            
            handles = ddb_initializeshorelines(handles);
            
            % Read in shorelines data here ...
            
            [S0]=readkeys(filename);
            fieldnms=fields(S0);
            for ii=1:length(fieldnms)
                handles.model.shorelines.domain.(fieldnms{ii}) = S0.(fieldnms{ii});
            end
%% Some options not specified in input file
            if ~isempty(handles.model.shorelines.domain.Waveclimfile)
                handles.model.shorelines.domain.wave_opt='wave_climate';
            elseif ~isempty(handles.model.shorelines.domain.WVCfile)
                handles.model.shorelines.domain.wave_opt='wave_timeseries';
            else
                handles.model.shorelines.domain.wave_opt='mean_and_spreading';
            end
            handles.model.shorelines.domain.transport_opt=lower(handles.model.shorelines.domain.trform)
   
            if ~isempty(handles.model.shorelines.domain.LDBcoastline)
                handles.model.shorelines.domain.shoreline.filename=handles.model.shorelines.domain.LDBcoastline;
                [x,y]=read_xy_columns(handles.model.shorelines.domain.shoreline.filename);
                handles.model.shorelines.domain.shoreline.length=length(x);
                handles.model.shorelines.domain.shoreline.x=x;
                handles.model.shorelines.domain.shoreline.y=y;
            end
                          
            setHandles(handles);
            ddb_plotshorelines('plot','active',0,'visible',1);
            gui_updateActiveTab;

        end        
    otherwise
end
