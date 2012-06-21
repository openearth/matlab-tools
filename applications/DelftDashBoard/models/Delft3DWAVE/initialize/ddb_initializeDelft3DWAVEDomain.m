function handles=ddb_initializeDelft3DWAVEDomain(handles,ii,id,kk,varargin)

handles.Model(ii).Input(id).Domain(kk).grid.x=[];
handles.Model(ii).Input(id).Domain(kk).grid.y=[];

handles.Model(ii).Input(id).Domain(kk).Active = 0;
handles.Model(ii).Input(id).Domain(kk).PathnameComputationalGrids='';
handles.Model(ii).Input(id).Domain(kk).Coordsyst = '';
handles.Model(ii).Input(id).Domain(kk).GrdFile   = '';
handles.Model(ii).Input(id).Domain(kk).EncFile   = '';
handles.Model(ii).Input(id).Domain(kk).DepFile   = '';
handles.Model(ii).Input(id).Domain(kk).NstFile   = '';
handles.Model(ii).Input(id).Domain(kk).NstGrid   = '';
handles.Model(ii).Input(id).Domain(kk).MMax      = 0;
handles.Model(ii).Input(id).Domain(kk).NMax      = 0;
%% grid
handles.Model(ii).Input(id).Domain(kk).CompGrid  = '';
handles.Model(ii).Input(id).Domain(kk).OtherGrid = '';
handles.Model(ii).Input(id).Domain(kk).CompDep   = '';
handles.Model(ii).Input(id).Domain(kk).Xorig     = 0;
handles.Model(ii).Input(id).Domain(kk).Yorig     = 0;
handles.Model(ii).Input(id).Domain(kk).Xgridsize = 0;
handles.Model(ii).Input(id).Domain(kk).Ygridsize = 0;
%% fre + dir
handles.Model(ii).Input(id).Domain(kk).DirType    = 'circle';
handles.Model(ii).Input(id).Domain(kk).Circle     = 1;
handles.Model(ii).Input(id).Domain(kk).Sector     = 0;    
handles.Model(ii).Input(id).Domain(kk).StartDir   = 0;
handles.Model(ii).Input(id).Domain(kk).EndDir     = 360;
handles.Model(ii).Input(id).Domain(kk).NumberDir  = 36;
handles.Model(ii).Input(id).Domain(kk).LowFreq    = 0.05;
handles.Model(ii).Input(id).Domain(kk).HighFreq   = 1;
handles.Model(ii).Input(id).Domain(kk).NumberFreq = 24;

handles.Model(ii).Input(id).Domain(kk).GridNested = '';
handles.Model(ii).Input(id).Domain(kk).NestedValue= '';
