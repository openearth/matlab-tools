function handles=ddb_initializeDD(handles,varargin)

ii=strmatch('DD',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Domain Decomposition';
            return
    end
end

handles.Toolbox(ii).Input.MRefinement=5;
handles.Toolbox(ii).Input.NRefinement=5;
handles.Toolbox(ii).Input.FirstCornerPointM=NaN;
handles.Toolbox(ii).Input.FirstCornerPointN=NaN;
handles.Toolbox(ii).Input.SecondCornerPointM=NaN;
handles.Toolbox(ii).Input.SecondCornerPointN=NaN;
handles.Toolbox(ii).Input.NewRunid='new';
handles.Toolbox(ii).Input.DDBoundaries=[];
