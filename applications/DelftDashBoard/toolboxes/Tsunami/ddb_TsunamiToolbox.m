function ddb_TsunamiToolbox(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    handles=getHandles;
    h=findobj(gca,'Tag','Plates');
    if isempty(h)
        dr=handles.Toolbox(tb).miscDir;
        load([dr 'plates.mat']);
        platesz=zeros(size(platesx))+50;
        h=plot3(platesx,platesy,platesz);
        set(h,'Color',[1.0 0.5 0.00]);
        set(h,'Tag','Plates');
        set(h,'LineWidth',1.5);
        set(h,'HitTest','off');
    end
    ddb_plotTsunami('activate');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'editdepth'}
            editQuakeParameters;
        case{'selecttidedatabase'}
            selectTideDatabase;
        case{'selecttidestation'}
            selectTideStation;
        case{'viewtidesignal'}
            viewTideSignal;
        case{'exporttidesignal'}
            exportTideSignal;
        case{'exportalltidesignals'}
            exportAllTideSignals;
        case{'drawfaultline'}
            drawFaultLine;
        case{'computewaterlevel'}
            computeWaterLevel;
    end    
end

%%
function editQuakeParameters

handles=getHandles;
%updateQuakeParameters;
if handles.Toolbox(tb).Input.updateTable
    updateTable;
end

%%
function drawFaultLine
handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','tsunamiFault');
if ~isempty(h)
    delete(h);
end
UIPolyline(gca,'draw','Tag','tsunamiFault','Marker','o','Callback',@changeFaultLine,'closed',0);
setHandles(handles);
%setUIElement('bathymetrypanel.export.savepolygon');

%%
function changeFaultLine(x,y,varargin)
handles=getHandles;

handles.Toolbox(tb).Input.segmentLon=x;
handles.Toolbox(tb).Input.segmentLat=y;

% Compute total length
utmz = fix( ( x(1) / 6 ) + 31);
[x,y] = ddb_deg2utm(x,y,utmz); 

handles.Toolbox(tb).Input.segmentX=x;
handles.Toolbox(tb).Input.segmentY=y;

pd=pathdistance(x,y);
handles.Toolbox(tb).Input.length=pd(end)/1000;

% Compute magnitude
if (handles.Toolbox(tb).Input.length > 0)
   Mw = (log10(handles.Toolbox(tb).Input.length) + 2.44) / 0.59;
   handles.Toolbox(tb).Input.Mw = Mw ;
end  

% Compute slip

%totflength=handles.Toolbox(tb).Input.faultLength;
mu=30.0e9;
Areaeq=4;

%
%       Options to detrmine the fault area, names below refers to the authors
%         1 = Ward 2004; 
%         2 = Coopersmith / Wells 1994 [Dreger 1999]; 
%         3 = average (Jef);
%         4 = Max. Length and Max width from options 1 & 2
%
if (Mw > 5)
    Mo = 10.0^(1.5*Mw+9.05);
    disloc = 0.02*10.0^(0.5*Mw-1.8); % dslip in meters
    if (Areaeq == 1)
        totflength  = 10.0^(0.5*Mw-1.8);
        mu1         = mu * 1.66666;
        area        = Mo/(mu1*disloc)/1000000.;
        fwidth      = area/totflength;
    elseif (Areaeq == 2 )
        totflength = 10^(-2.44+0.59*Mw);
        area       = 10^(-3.49+0.91*Mw);
        fwidth     = area/totflength;
    elseif (Areaeq == 3)
        L1  = 10.0^(0.5*Mw-1.8);
        mu1 = mu * 1.66666;
        area= Mo/(mu1*disloc)/1000000.0;
        fw1 = area/L1;
        L2    = 10^(-2.44+0.59*Mw);
        area2 = 10^(-3.49+0.91*Mw);
        fw2   = area2/L2;
        totflength = 0.5*(L1+L2);
        fwidth = 0.5*(fw1 + fw2);
    elseif (Areaeq == 4)
        totflength = 10^(-2.44+0.59*Mw);
        area       = Mo/(mu*disloc)/1000000.0;
        fwidth     = area/totflength;
    end
    
%     handles.Toolbox(tb).Input.TotalFaultLength=totflength;
%     handles.Toolbox(tb).Input.FaultWidth=fwidth;
%     handles.Toolbox(tb).Input.Dislocation=disloc;
else
%     handles.Toolbox(tb).Input.Mw=0.0;
%     handles.Toolbox(tb).Input.TotalFaultLength=0;
%     handles.Toolbox(tb).Input.FaultWidth=0;
%     handles.Toolbox(tb).Input.Dislocation=0;
end

handles.Toolbox(tb).Input.width=fwidth;
handles.Toolbox(tb).Input.slip=disloc;


% Clear variables
%handles.Toolbox(tb).Input.faultLength=[];
handles.Toolbox(tb).Input.segmentStrike=[];
handles.Toolbox(tb).Input.segmentWidth=[];
handles.Toolbox(tb).Input.segmentDepth=[];
handles.Toolbox(tb).Input.segmentDip=[];
handles.Toolbox(tb).Input.segmentSlipRake=[];
handles.Toolbox(tb).Input.segmentSlip=[];

% First the strike
handles.Toolbox(tb).Input.segmentStrike(1)=90-180*atan2(y(2)-y(1),x(2)-x(1))/pi;
for i=2:length(x)
    handles.Toolbox(tb).Input.segmentStrike(i)=90-180*atan2(y(i)-y(i-1),x(i)-x(i-1))/pi;
end


for i=1:length(x)
    handles.Toolbox(tb).Input.segmentWidth(i)=fwidth;
    handles.Toolbox(tb).Input.segmentDepth(i)=20;
    handles.Toolbox(tb).Input.segmentDip(i)=10;
    handles.Toolbox(tb).Input.segmentSlipRake(i)=90;
    handles.Toolbox(tb).Input.segmentSlip(i)=disloc;
end

setHandles(handles);

setUIElement('editmw');
setUIElement('editwidth');
setUIElement('editlength');
setUIElement('editslip');
setUIElement('tsunamitable');

%%
function computeWaterLevel
handles=getHandles;
xs=handles.Toolbox(tb).Input.segmentX;
ys=handles.Toolbox(tb).Input.segmentY;
wdts=handles.Toolbox(tb).Input.segmentWidth;
depths=handles.Toolbox(tb).Input.segmentDepth;
dips=handles.Toolbox(tb).Input.segmentDip;
sliprakes=handles.Toolbox(tb).Input.segmentSlipRake;
slips=handles.Toolbox(tb).Input.segmentSlip;
[xx,yy,zz]=ddb_computeTsunamiWave(xs,ys,depths,dips,wdts,sliprakes,slips);
% figure(2)
% pcolor(xx,yy,zz);view(2);axis equal;shading flat;colorbar;
% setHandles(handles);

OldSys.name='WGS 84 / UTM zone 55N';
OldSys.type='projected';
NewSys.name='WGS 84';
NewSys.type='geographic';

[xx1,yy1]=ddb_coordConvert(xx,yy,OldSys,NewSys);

ddb_plotInitialTsunami(handles,xx1,yy1,zz);

% Make
for i=1:handles.Model(md).nrDomains

    xz=handles.Model(md).Input(i).gridXZ;
    yz=handles.Model(md).Input(i).gridYZ;
    mmax=size(xz,1);
    nmax=size(xz,2);

    [xz,yz]=ddb_coordConvert(xz,yz,NewSys,OldSys);
    zz(isnan(zz))=0;
    xz(isnan(xz))=0;
    yz(isnan(yz))=0;
    iniwl0=interp2(xx,yy,zz,xz,yz);
    
    iniwl0=reshape(iniwl0,mmax,nmax);
    
    u=zeros(mmax+1,nmax+1);
    iniwl=u;
%    iniwl0=reshape(iniwl0,mmax,nmax);
    iniwl(1:end-1,1:end-1)=iniwl0;
    iniwl(isnan(iniwl))=0;

    fname=[handles.Model(md).Input(i).runid '.ini'];
    if exist(fname,'file')
        delete(fname);
    end
    ddb_wldep('append',fname,iniwl,'negate','n','bndopt','n');
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');
    ddb_wldep('append',fname,u,'negate','n','bndopt','n');

end


