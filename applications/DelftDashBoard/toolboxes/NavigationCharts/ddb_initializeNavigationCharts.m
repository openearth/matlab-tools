function handles=ddb_initializeNavigationCharts(handles,varargin)

ii=strmatch('NavigationCharts',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Navigation Charts';
            handles.Toolbox(ii).databases=[];
            handles.Toolbox(ii).charts=[];
            if isdir([handles.toolBoxDir 'navigationcharts'])
                lst=dir([handles.toolBoxDir 'NavigationCharts']);
                k=0;
                for i=1:length(lst)
                    if isdir([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name])
                        switch(lst(i).name)
                            case{'.','..'}
                            otherwise
                                k=k+1;
                                disp(['Loading navigation charts ' lst(i).name ' ...']);
                                s=load([handles.toolBoxDir 'NavigationCharts' filesep lst(i).name filesep lst(i).name '.mat']);
                                handles.Toolbox(ii).databases{k}=lst(i).name;
                                handles.Toolbox(ii).charts(k).box=s.Box;
                        end
                    end
                end
            end
            handles.Toolbox(ii).activeDatabase=1;
            handles.Toolbox(ii).activeChart=1;
            handles.Toolbox(ii).showShoreline=1;
            handles.Toolbox(ii).showSoundings=1;
            handles.Toolbox(ii).showContours=1;
            return
    end
end

if isempty(handles.Toolbox(ii).databases)
    set(handles.GUIHandles.Menu.Toolbox.NavigationCharts,'Enable','off');
end
