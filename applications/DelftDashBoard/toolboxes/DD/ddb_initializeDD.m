function handles=ddb_initializeDD(handles,varargin)

ii=strmatch('DD',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Domain Decomposition';
            return
    end
end

handles.Toolbox(ii).Input.mRefinement=5;
handles.Toolbox(ii).Input.nRefinement=5;
handles.Toolbox(ii).Input.firstCornerPointM=NaN;
handles.Toolbox(ii).Input.firstCornerPointN=NaN;
handles.Toolbox(ii).Input.secondCornerPointM=NaN;
handles.Toolbox(ii).Input.secondCornerPointN=NaN;
handles.Toolbox(ii).Input.newRunid='new';
handles.Toolbox(ii).Input.DDBoundaries=[];
