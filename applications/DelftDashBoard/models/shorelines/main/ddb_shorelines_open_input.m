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
%            inp=shorelines_load_input('shorelines.inp');
%            handles.model.shorelines.domain=inp;
            
            setHandles(handles);
            ddb_plotshorelines('plot','active',0,'visible',1);
            gui_updateActiveTab;

        end        
    otherwise
end
