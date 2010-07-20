function handles=ddb_initializeNavigationCharts(handles,varargin)

ii=strmatch('NavigationCharts',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Navigation Charts';            
            lst=dir([handles.ToolBoxDir 'NavigationCharts']);
            k=0;
            for i=1:length(lst)
                if isdir([handles.ToolBoxDir 'NavigationCharts' filesep lst(i).name])
                    switch(lst(i).name)
                        case{'.','..'}
                        otherwise
                            k=k+1;
                            disp(['Loading navigation charts ' lst(i).name ' ...']);
                            s=load([handles.ToolBoxDir 'NavigationCharts' filesep lst(i).name filesep lst(i).name '.mat']);
                            handles.Toolbox(ii).Databases{k}=lst(i).name;
                            handles.Toolbox(ii).Charts(k)=s;
                    end
                end
            end
            handles.Toolbox(ii).ActiveDatabase=1;
            handles.Toolbox(ii).ActiveChart=1;
            handles.Toolbox(ii).ShowLandBoundary=1;
            handles.Toolbox(ii).ShowSoundings=1;
            handles.Toolbox(ii).ShowContours=1;
            return
    end
end
