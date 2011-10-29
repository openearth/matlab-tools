function ddb_changeCycloneTrack(x,y,varargin)

setInstructions({'','Left-click and drag track vertices to change track position','Right-click track vertices to change cyclone parameters'}); 

handles=getHandles;

handles.Toolbox(tb).Input.nrTrackPoints=length(x);
handles.Toolbox(tb).Input.trackX=x;
handles.Toolbox(tb).Input.trackY=y;

if handles.Toolbox(tb).Input.newTrack
    
    handles.Toolbox(tb).Input.trackT=handles.Toolbox(tb).Input.startTime:handles.Toolbox(tb).Input.timeStep/24:handles.Toolbox(tb).Input.startTime+(length(x)-1)*handles.Toolbox(tb).Input.timeStep/24;
    zers=zeros(length(x),4);
    handles.Toolbox(tb).Input.trackVMax=zers+handles.Toolbox(tb).Input.vMax;
    handles.Toolbox(tb).Input.trackPDrop=zers+handles.Toolbox(tb).Input.pDrop;
    handles.Toolbox(tb).Input.trackRMax=zers+handles.Toolbox(tb).Input.rMax;
    handles.Toolbox(tb).Input.trackR100=zers+handles.Toolbox(tb).Input.r100;
    handles.Toolbox(tb).Input.trackR65=zers+handles.Toolbox(tb).Input.r65;
    handles.Toolbox(tb).Input.trackR50=zers+handles.Toolbox(tb).Input.r50;
    handles.Toolbox(tb).Input.trackR35=zers+handles.Toolbox(tb).Input.r35;
    handles.Toolbox(tb).Input.trackA=zers+handles.Toolbox(tb).Input.parA;
    handles.Toolbox(tb).Input.trackB=zers+handles.Toolbox(tb).Input.parB;
        
    handles=ddb_setTrackTableValues(handles);

end

handles.Toolbox(tb).Input.newTrack=0;

setHandles(handles);

ddb_plotCycloneTrack;
ddb_updateTrackTables;
