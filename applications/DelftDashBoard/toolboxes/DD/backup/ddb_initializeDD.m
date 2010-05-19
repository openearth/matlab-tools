function handles=ddb_initializeDD(handles)

tb=strmatch('DD',{handles.Toolbox(:).Name},'exact');

handles.Toolbox(tb).Input.MRefinement=5;
handles.Toolbox(tb).Input.NRefinement=5;
handles.Toolbox(tb).Input.FirstCornerPointM=NaN;
handles.Toolbox(tb).Input.FirstCornerPointN=NaN;
handles.Toolbox(tb).Input.SecondCornerPointM=NaN;
handles.Toolbox(tb).Input.SecondCornerPointN=NaN;
handles.Toolbox(tb).Input.NewRunid='new';
