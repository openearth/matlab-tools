function ModelManager

% Compile with: mcc -m -B sgl ModelManager.m

handles.ModelManagerVersion='1.01';

%hm.ModelDirectory='D:\work\OperationalModelSystem\OMSMain\';
hm=ReadOMSMainConfigFile;

hm.d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];

% hm=GetCoordinateSystems(hm);

hm.MainWindow=MakeNewWindow('ModelManager',[750 500]);
set(hm.MainWindow,'Tag','MainWindow');

hm=ReadModelsAndContinents(hm);
hm=ReadPredictionsAndObservations(hm);


guidata(hm.MainWindow,hm);

InitializeScreen;
