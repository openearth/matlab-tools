function ddb_TropicalCycloneToolbox(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotTropicalCyclone('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'computecyclone'}
            computeCyclone;
        case{'drawtrack'}
            drawTrack;
        case{'edittracktable'}
            editTrackTable;
        case{'loaddata'}
            loadDataFile;
        case{'savedata'}
            saveDataFile;
        case{'importtrack'}
            importTrack;
    end    
end

%%
function drawTrack
handles=getHandles;
h.hol=handles.Toolbox(tb).Input.holland;
h.vmax=handles.Toolbox(tb).Input.vMax;
h.pdrop=handles.Toolbox(tb).Input.pDrop;
h.para=handles.Toolbox(tb).Input.parA;
h.parb=handles.Toolbox(tb).Input.parB;
h.t0=handles.Model(md).Input(ad).startTime;
h.dt=handles.Toolbox(tb).Input.timeStep;
h=ddb_getInitialCycloneTrackParameters(h);
if h.ok
    handles.Toolbox(tb).Input.vMax=h.vmax;
    handles.Toolbox(tb).Input.pDrop=h.pdrop;
    handles.Toolbox(tb).Input.parA=h.para;
    handles.Toolbox(tb).Input.parB=h.parb;
    handles.Toolbox(tb).Input.startTime=h.t0;
    handles.Toolbox(tb).Input.timeStep=h.dt;

    h=findobj(gcf,'Tag','cycloneTrack');
    if ~isempty(h)
        delete(h);
    end
    
    ddb_zoomOff;
    UIPolyline(gca,'draw','Tag','cycloneTrack','Marker','o','Callback',@changeTrack,'closed',0);
    handles.Toolbox(tb).Input.newTrack=1;

    setHandles(handles);

end

%%
function changeTrack(x,y,varargin)
handles=getHandles;
handles.Toolbox(tb).Input.nrTrackPoints=length(x);
handles.Toolbox(tb).Input.trackX=x;
handles.Toolbox(tb).Input.trackY=y;
if handles.Toolbox(tb).Input.newTrack
    handles.Toolbox(tb).Input.trackT=handles.Toolbox(tb).Input.startTime:handles.Toolbox(tb).Input.timeStep/24:handles.Toolbox(tb).Input.startTime+(length(x)-1)*handles.Toolbox(tb).Input.timeStep/24;
    handles.Toolbox(tb).Input.trackVMax=[];
    handles.Toolbox(tb).Input.trackPDrop=[];
    for i=1:length(x)
        handles.Toolbox(tb).Input.trackVMax(i)=handles.Toolbox(tb).Input.vMax;
        handles.Toolbox(tb).Input.trackPDrop(i)=handles.Toolbox(tb).Input.pDrop;
    end
end
handles.Toolbox(tb).Input.newTrack=0;
setHandles(handles);
setUIElement('cyclonetable');
plotCycloneTrack;

%%
function editTrackTable
plotCycloneTrack;

%%
function plotCycloneTrack
handles=getHandles;
h=findobj(gcf,'Tag','cycloneTrack');
if ~isempty(h)
    delete(h);
end
for i=1:handles.Toolbox(tb).Input.nrTrackPoints
    txt{i}=datestr(handles.Toolbox(tb).Input.trackT(i),'dd-mmm-yyyy HH:MM');
end
UIPolyline(gca,'plot','Tag','cycloneTrack','Marker','o','Callback',@changeTrack,'closed',0,'x',handles.Toolbox(tb).Input.trackX,'y',handles.Toolbox(tb).Input.trackY,'text',txt);

%%
function loadDataFile

handles=getHandles;

[filename, pathname, filterindex] = uigetfile('*.cyc', 'Select Cyclone File','');

if ~isempty(pathname)

    filename=[pathname filename];
    handles.Toolbox(tb).Input.cycloneFile=[pathname filename];
    handles=ddb_readCycloneFile(handles,filename);
   
    if ~handles.Toolbox(tb).Input.holland
        handles.Toolbox(tb).Input.trackVMax=handles.Toolbox(tb).Input.par1;
        handles.Toolbox(tb).Input.trackPDrop=handles.Toolbox(tb).Input.par2;
    end

    setHandles(handles);
    
    setUIElement('cyclonetable');
    setUIElement('editname');
    setUIElement('editradius');
    plotCycloneTrack;
end

%%
function saveDataFile

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.cyc', 'Select Cyclone File','');
if filename==0
    return
end
filename=[pathname filename];
handles.Toolbox(tb).Input.cycloneFile=filename;
if ~handles.Toolbox(tb).Input.holland
    for i=1:handles.Toolbox(tb).Input.nrTrackPoints
        handles.Toolbox(tb).Input.par1(i)=handles.Toolbox(tb).Input.trackVMax(i);
        handles.Toolbox(tb).Input.par2(i)=handles.Toolbox(tb).Input.trackPDrop(i);
    end
end
setHandles(handles);
ddb_saveCycloneFile(handles,filename);

%%
function importTrack

%%
function computeCyclone

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.spw', 'Select Spiderweb File','');

if ~isempty(pathname)
    
    inp=handles.Toolbox(tb).Input;
    
    [path,name,ext]=fileparts(filename);
    
    % Input file
    
    fid=fopen([name '.inp'],'wt');
    
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n','COMMENT             = Grid: none');
    fprintf(fid,'%s\n','CYCLONE_PAR._FILE   = trackfile.trk');
    fprintf(fid,'%s\n',['SPIDERS_WEB_DIMENS. = ' num2str(inp.nrRadialBins) '  ' num2str(inp.nrDirectionalBins)]);
    fprintf(fid,'%s\n',['RADIUS_OF_CYCLONE   = ' num2str(1000*inp.radius,'%3.1f')]);
    fprintf(fid,'%s\n','WIND CONV. FAC (TRK)= 1.00');
    fprintf(fid,'%s\n','NO._OF_HIS._DATA    = 0');
    fprintf(fid,'%s\n','HIS._DATA_FILE_NAME = wes_his.inp');
    fprintf(fid,'%s\n','OBS._DATA_FILE_NAME =');
    fprintf(fid,'%s\n','EXTENDED_REPORT     = yes');
    
    fclose(fid);
    
    % Track file
    
    fid=fopen('trackfile.trk','wt');
    
    fprintf(fid,'%s\n','* File for hurricane KATRINA; starting at 20050823 UTC !!');
    fprintf(fid,'%s\n','* File contains Cyclone information ; TIMES in UTC');
    fprintf(fid,'%s\n','* Created by DEEPAK VATVANI from http://flhurricane.com/cyclone/stormhistory.php?storm=12&year=2005');
    fprintf(fid,'%s\n','* UNIT = Kts, Nmi ,Pa');
    fprintf(fid,'%s\n','* METHOD= 1:A&B;           4:Vm,Pd; Rw default');
    fprintf(fid,'%s\n','*         2:R100_etc;      5:Vm & Rw(RW may be default - US data; Pd = 2 Vm*Vm);');
    fprintf(fid,'%s\n','*         3:Vm,Pd,RmW,     6:Vm (Indian data); 7: OLD METHOD - Not adviced');
    fprintf(fid,'%s\n','*yyyy mm  dd  hh  lat  long   Dm     Vm   Method MaxW RmaxW   R100   R65    R50    R35    B     A    Pdrop');
    fprintf(fid,'%s\n','* Dm    Vm');
    fprintf(fid,'%3.1f %3.1f\n',inp.initDir,inp.initSpeed);
    fprintf(fid,'%s\n','*            (UTC)            Method (kts) (nm)   (nm)   (nm)   (nm)   (nm)               (Pa)');
    e=1e30;
    for j=1:inp.nrTrackPoints
        dstr=datestr(inp.trackT(j),'yyyy  mm  dd  HH');
        fprintf(fid,'%s  %6.2f %6.2f   %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.trackY(j),inp.trackX(j),5,inp.trackVMax(j),e,e,e,e,e,e,e,e);
    end
    
    fclose(fid);
    
    system([handles.toolBoxDir 'tropicalcyclone' filesep 'wes.exe ' name '.inp']);
    
    handles.Model(md).Input(ad).spwFile=[name '.spw'];
    handles.Model(md).Input(ad).wind=1;
    handles.Model(md).Input(ad).windType='spiderweb';
    
    setHandles(handles);
    
end
