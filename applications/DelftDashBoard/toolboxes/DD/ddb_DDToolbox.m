function ddb_DDToolbox(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotDD('activate');
    handles=getHandles;
    
    % Make 
    handles.Toolbox(tb).Input.domains=[];
    for i=1:length(handles.Model(md).Input)
        handles.Toolbox(tb).Input.domains{i}=handles.Model(md).Input(i).runid;
    end

    % If m2 or n2 is nan, set m1 and n1 to NaN
    m2=handles.Toolbox(tb).Input.secondCornerPointM;
    n2=handles.Toolbox(tb).Input.secondCornerPointN;
    if isnan(m2) || isnan(n2)
        handles.Toolbox(tb).Input.firstCornerPointM=NaN;
        handles.Toolbox(tb).Input.firstCornerPointN=NaN;
    end
    setHandles(handles);

    % If m1 or n1 is nan, delete corner points
    m1=handles.Toolbox(tb).Input.firstCornerPointM;
    n1=handles.Toolbox(tb).Input.firstCornerPointN;
    if isnan(m1) || isnan(n1)
        plotCornerPoints('delete');
    end
    
    clearInstructions;
%    setUIElements(handles.Toolbox(tb).GUI.elements);
    setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
    
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'editrefinement'}
            editRefinement;
        case{'editm1'}
            editM1;
        case{'editn1'}
            editN1;
        case{'editm2'}
            editM2;
        case{'editn2'}
            editN2;
        case{'selectcornerpoints'}
            selectCornerPoints;
        case{'generatenewdomain'}
            makeNewDomain;
        case{'makeddboundaries'}
            generateDD;
    end    
end

%%
function editRefinement
plotTemporaryDDGrid('plot');
handles=getHandles;
if ~odd(handles.Toolbox(tb).Input.mRefinement) || ~odd(handles.Toolbox(tb).Input.nRefinement)
    GiveWarning('text','Refinement by an even number is not recommended!');
end

%%
function editM1

handles=getHandles;
ii=handles.Toolbox(tb).Input.firstCornerPointM;
sz=size(handles.Model(md).Input(ad).gridX);
if ii>sz(1)
    handles.Toolbox(tb).Input.firstCornerPointM=sz(1);
end
if ii<1
    handles.Toolbox(tb).Input.firstCornerPointM=1;
end

setHandles(handles);
setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editN1

handles=getHandles;
ii=handles.Toolbox(tb).Input.firstCornerPointN;
sz=size(handles.Model(md).Input(ad).gridX);
if ii>sz(2)
    handles.Toolbox(tb).Input.firstCornerPointN=sz(2);
end
if ii<1
    handles.Toolbox(tb).Input.firstCornerPointN=1;
end

setHandles(handles);
setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editM2

handles=getHandles;
ii=handles.Toolbox(tb).Input.secondCornerPointM;
sz=size(handles.Model(md).Input(ad).gridX);
if ii>sz(1)
    handles.Toolbox(tb).Input.secondCornerPointM=sz(1);
end
if ii<1
    handles.Toolbox(tb).Input.secondCornerPointM=1;
end

setHandles(handles);
setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function editN2

handles=getHandles;
ii=handles.Toolbox(tb).Input.secondCornerPointN;
sz=size(handles.Model(md).Input(ad).gridX);
if ii>sz(2)
    handles.Toolbox(tb).Input.secondCornerPointN=sz(2);
end
if ii<1
    handles.Toolbox(tb).Input.secondCornerPointN=1;
end

setHandles(handles);
setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);

plotCornerPoints('plot');
plotTemporaryDDGrid('plot');

%%
function selectCornerPoints
ddb_zoomOff;
ddb_setWindowButtonUpDownFcn;
setInstructions({'','','Click grid point on active grid for first corner point'});
handles=getHandles;
xg=handles.Model(md).Input(handles.activeDomain).gridX;
yg=handles.Model(md).Input(handles.activeDomain).gridY;
if ~isempty(xg)
    ddb_clickPoint('cornerpoint','grid',xg,yg,'callback',@clickFirstCornerPoint,'single');
    setHandles(handles);
end

%%
function makeNewDomain

handles=getHandles;

% Check indices
m1=handles.Toolbox(tb).Input.firstCornerPointM;
n1=handles.Toolbox(tb).Input.firstCornerPointN;
m2=handles.Toolbox(tb).Input.secondCornerPointM;
n2=handles.Toolbox(tb).Input.secondCornerPointN;
mdd(1)=min(m1,m2);mdd(2)=max(m1,m2);
ndd(1)=min(n1,n2);ndd(2)=max(n1,n2);

% Check if domain with new runid already exists
ii=strmatch(lower(handles.Toolbox(tb).Input.newRunid),handles.Toolbox(tb).Input.domains,'exact');

if ~isempty(ii)
    
    GiveWarning('Warning',['A domain with runid "' handles.Toolbox(tb).Input.newRunid '" already exists!']);
    
elseif mdd(2)>mdd(1) && ndd(2)>ndd(1)
        
    [filename, pathname, filterindex] = uiputfile('*.grd', 'New Overall Grid File',handles.Model(md).Input(ad).grdFile);

    if pathname~=0
        
        % Delete existing domains
        ddb_plotDelft3DFLOW('delete');

        % Set filenames new grid file
        curdir=[lower(cd) '\'];
        if ~strcmpi(curdir,pathname)
            filename=[pathname filename];
        end
        handles.Model(md).Input(ad).grdFile=filename;
        ii=findstr(filename,'.grd');
        str=filename(1:ii-1);
        handles.Model(md).Input(ad).encFile=[str '.enc'];
        
        % Generate new domain
        runid1=handles.Model(md).Input(ad).runid;
        runid2=handles.Toolbox(tb).Input.newRunid;
        handles.Model(md).nrDomains=handles.Model(md).nrDomains+1;
        id2=handles.Model(md).nrDomains;
        handles.Toolbox(tb).Input.domains{handles.Model(md).nrDomains}=handles.Toolbox(tb).Input.newRunid;
        % Copy active domain to new domain
        handles.Model(md).Input(id2)=handles.Model(md).Input(ad);
        handles.Model(md).Input(id2).runid=runid2;
        handles.Model(md).Input(id2).attName=handles.Toolbox(tb).Input.attributeName;
        % Create backup of original model with id0
        handles.Toolbox(tb).Input.originalDomain=handles.Model(md).Input(ad);
        
        % Initialize grid dependent input new domain
        handles=ddb_initializeFlowDomain(handles,'griddependentinput',id2,runid2);
        
        % New Domain
        % Grid
        [handles,mdd,ndd]=ddb_makeDDModelNewGrid(handles,ad,id2,mdd,ndd,runid2);
        
        % Original Domain
        % Grid
        [handles,mcut,ncut]=ddb_makeDDModelOriginalGrid(handles,ad,mdd,ndd);
        
        % New Domain
        % Attributes
        handles=ddb_makeDDModelNewAttributes(handles,ad,id2,runid1,runid2);       
        
        % Delete corner points and temporary grid
        plotCornerPoints('delete');
        plotTemporaryDDGrid('delete');
        
        handles.Toolbox(tb).Input.firstCornerPointM=NaN;
        handles.Toolbox(tb).Input.secondCornerPointM=NaN;
        handles.Toolbox(tb).Input.firstCornerPointN=NaN;
        handles.Toolbox(tb).Input.secondCornerPointN=NaN;
        
        setHandles(handles);
        
        
        % Now replot all domains
        for i=1:handles.Model(md).nrDomains
            if i==ad
                ddb_plotDelft3DFLOW('plot','active',1,'visible',1,'domain',i);
            else
                ddb_plotDelft3DFLOW('plot','active',0,'visible',1,'domain',i);
            end
        end
        
        ddb_refreshDomainMenu;
        
        % Generate dd boundaries
        generateDD;
        
    else
        GiveWarning('Warning','First select corner points!');
    end
    
end

% Clear original domain
handles.Toolbox(tb).Input.originalDomain=[];

%%
function clickFirstCornerPoint(m,n)

% First corner point was clicked
setInstructions({'','','Click grid point on active grid for second corner point'});

% Set values of corner points
handles=getHandles;
handles.Toolbox(tb).Input.firstCornerPointM=m;
handles.Toolbox(tb).Input.firstCornerPointN=n;
handles.Toolbox(tb).Input.secondCornerPointM=NaN;
handles.Toolbox(tb).Input.secondCornerPointN=NaN;
setHandles(handles);

% Plot markers on corner points
plotCornerPoints('plot');
plotTemporaryDDGrid('delete');

xg=handles.Model(md).Input(ad).gridX;
yg=handles.Model(md).Input(ad).gridY;
if ~isnan(m)
    ddb_clickPoint('cornerpoint','grid',xg,yg,'callback',@clickSecondCornerPoint,'single');
end

setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);

%%
function clickSecondCornerPoint(m,n)

clearInstructions;

handles=getHandles;
if ~isnan(m)
    handles.Toolbox(tb).Input.secondCornerPointM=m;
    handles.Toolbox(tb).Input.secondCornerPointN=n;
    setHandles(handles);
    plotCornerPoints('plot');
    plotTemporaryDDGrid('plot');
    ddb_setWindowButtonMotionFcn;
    setUIElements(handles.Model(md).GUI.elements.tabs(1).elements);
end

%%
function plotTemporaryDDGrid(opt)

switch lower(opt)
    case{'plot'}

        % Delete existing grid
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
        
        %Plot new grid
        handles=getHandles;
        xg=handles.Model(md).Input(ad).gridX;
        yg=handles.Model(md).Input(ad).gridY;
        m1=handles.Toolbox(tb).Input.firstCornerPointM;
        n1=handles.Toolbox(tb).Input.firstCornerPointN;
        m2=handles.Toolbox(tb).Input.secondCornerPointM;
        n2=handles.Toolbox(tb).Input.secondCornerPointN;
        mm1=min(m1,m2);mm2=max(m1,m2);
        nn1=min(n1,n2);nn2=max(n1,n2);
        xg=xg(mm1:mm2,nn1:nn2);
        yg=yg(mm1:mm2,nn1:nn2);
        mref=handles.Toolbox(tb).Input.mRefinement;
        nref=handles.Toolbox(tb).Input.nRefinement;
        [x2,y2]=ddb_refineD3DGrid(xg,yg,mref,nref);
        z2=zeros(size(x2))+9000;
        grd=mesh(x2,y2,z2);
        set(grd,'FaceColor','none','EdgeColor','r','Tag','TemporaryDDGrid');

    case{'delete'}
        % Delete existing grid
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
end

%%
function plotCornerPoints(opt)

switch lower(opt)
    case{'plot'}
        
        handles=getHandles;
        
        % Delete old points
        if isfield(handles.Toolbox(tb).Input,'cornerPointHandles')
            hh=handles.Toolbox(tb).Input.cornerPointHandles;
            if ~isempty(hh)
                try
                    delete(hh);
                end
            end
        end
        
        % Now plot the corner points
        m1=handles.Toolbox(tb).Input.firstCornerPointM;
        m2=handles.Toolbox(tb).Input.secondCornerPointM;
        n1=handles.Toolbox(tb).Input.firstCornerPointN;
        n2=handles.Toolbox(tb).Input.secondCornerPointN;
        
        plt1=plot(handles.Model(md).Input(ad).gridX(m1,n1),handles.Model(md).Input(ad).gridY(m1,n1),'go');
        set(plt1,'MarkerEdgeColor','k','MarkerFaceColor','y','HitTest','off');
        set(plt1,'Tag','DDCornerPoint');
        
        plt2=[];
        if ~isnan(m2) && ~isnan(n2)
            plt2=plot(handles.Model(md).Input(ad).gridX(m2,n2),handles.Model(md).Input(ad).gridY(m2,n2),'go');
            set(plt2,'MarkerEdgeColor','k','MarkerFaceColor','y','HitTest','off');
            set(plt2,'Tag','DDCornerPoint');
        end
        
        handles.Toolbox(tb).Input.cornerPointHandles=[plt1 plt2];
        
        setHandles(handles);
        
    case{'delete'}
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
end

%%
function generateDD

handles=getHandles;

% Find DD boundaries
ddbound=[];
for i=1:handles.Model(md).nrDomains-1
    for j=i+1:handles.Model(md).nrDomains
        xg1=handles.Model(md).Input(i).gridX;
        yg1=handles.Model(md).Input(i).gridY;
        xg2=handles.Model(md).Input(j).gridX;
        yg2=handles.Model(md).Input(j).gridY;
        runid1=handles.Model(md).Input(i).runid;
        runid2=handles.Model(md).Input(j).runid;
        ddbound=ddb_findDDBoundaries(ddbound,xg1,yg1,xg2,yg2,runid1,runid2);
    end
end

if ~isempty(ddbound)
    if handles.Toolbox(tb).Input.adjustBathymetry
        % Adjust bathymetries in all domains
        % This ensures that depths along boundaries in both domains are the same
        for i=1:handles.Model(md).nrDomains-1
            for j=i+1:handles.Model(md).nrDomains
                z1=handles.Model(md).Input(i).depth;
                z2=handles.Model(md).Input(j).depth;
                runid1=handles.Model(md).Input(i).runid;
                runid2=handles.Model(md).Input(j).runid;
                [z1,z2]=ddb_matchDDDepths(ddbound,z1,z2,runid1,runid2,handles.Model(md).Input(i).dpsOpt);
                handles.Model(md).Input(i).depth=z1;
                handles.Model(md).Input(j).depth=z2;
            end
        end
        % And save all dep files
        for i=1:handles.Model(md).nrDomains
            handles.Model(md).Input(i).depthZ=GetDepthZ(handles.Model(md).Input(i).depth,handles.Model(md).Input(i).dpsOpt);
            ddb_wldep('write',handles.Model(md).Input(i).depFile,handles.Model(md).Input(i).depth);
        end
    end
end

handles.Model(md).DDBoundaries=ddbound;

handles=ddb_Delft3DFLOW_plotDD(handles,'plot');

setHandles(handles);

% Save ddbound file
ddb_saveDDBoundFile(ddbound,handles.Model(md).ddFile);

fid = fopen('batch_flw_dd.bat','wt');
fprintf(fid,'%s\n','@ echo off');
fprintf(fid,'%s\n','set argfile=config_flow2d3d_dd.ini');
fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
% fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
% fprintf(fid,'%s\n',['echo -c ' handles.Model(md).ddFile ' >%argfile%']);
% fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\delftflow.exe %argfile% dummy delft3d');
fclose(fid);

% Write config file
fini=fopen('config_flow2d3d_dd.ini','w');
fprintf(fini,'%s\n','[FileInformation]');
fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
fprintf(fini,'%s\n','   FileVersion      = 00.01');
fprintf(fini,'%s\n','[Component]');
fprintf(fini,'%s\n','   Name                = flow2d3d');
fprintf(fini,'%s\n',['   DDBfile             = ' handles.Model(md).ddFile]);
fclose(fini);

%        ddb_writeDDBacthfile;

%         % Write run batch file
%         fid = fopen('rundd.bat','wt');
%         for i=1:handles.Model(md).nrDomains+1;
%             rid=handles.Model(md).Input(i).runid;
%             fprintf(fid,'%s\n',['echo ',rid,' > runid']);
%             fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\tdatom.exe');
%         end
%         fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\trisim.exe ddbound');
%         fclose(fid);
