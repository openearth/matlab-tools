function ITHK_add_groyne2(ss,phase,NGRO,sens)

global S

%% get info from struct
lat = S.userinput.groyne(ss).lat;
lon = S.userinput.groyne(ss).lon;

% GRO settings
cstupdate = str2double(S.settings.measures.groyne.coastlineupdate);
updatewidth = str2double(S.settings.measures.groyne.updatewidth);
angleA = str2double(S.settings.measures.groyne.angleshiftclimateA);
angleB = str2double(S.settings.measures.groyne.angleshiftclimateB);

%% convert coordinates
%EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
[MDAdata_ORIG]=ITHK_readMDA('BASIS_ORIG.MDA');
if phase==1 || NGRO>1
    [GROdata]=ITHK_readGRO([S.settings.outputdir S.userinput.groyne(ss).filename]);
else
    [GROdata]=ITHK_readGRO([S.settings.outputdir S.userinput.phase(phase-1).GROfile]);
end

%% Find groyne location on initial coastline
[idNEAREST,idRANGE]=findGRIDinrange(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast,x,y,updatewidth*S.userinput.groyne(ss).length);
S.userinput.groyne(ss).idNEAREST = idNEAREST;

% Groyne points
S.UB.input(sens).groyne(ss).length = S.userinput.groyne(ss).length;
Xw = MDAdata_ORIG.Xcoast(idNEAREST);
Yw = MDAdata_ORIG.Ycoast(idNEAREST);
s0 = distXY(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast);
s1 = s0(idNEAREST);

%% Update initial coastline around groyne (in MDA)
if cstupdate == 1   
    % Beach extension south of groyne (0.5 GRO length)
    if length(idRANGE(1):idNEAREST)>1
        Y1south = interp1([MDAdata_ORIG.Xcoast(idRANGE(1)) MDAdata_ORIG.Xcoast(idNEAREST)],[0 0.5*S.userinput.groyne(ss).length],MDAdata_ORIG.Xcoast(idRANGE(1):idNEAREST));
    end
    Y1_new = MDAdata.Y1i;
    Y1_new(idRANGE(1):idNEAREST) = MDAdata.Y1i(idRANGE(1):idNEAREST)+Y1south;
    
    % Beach extension nord of groyne  (0.5 GRO length)
    if length(idNEAREST+1:idRANGE(end))>1
        Y1north = interp1([MDAdata_ORIG.Xcoast(idNEAREST) MDAdata_ORIG.Xcoast(idRANGE(end))],[0.5*S.userinput.groyne(ss).length 0],x0(idNEAREST+1:idRANGE(end)));
    end
    Y1_new(idNEAREST+1:idRANGE(end)) = MDAdata.Y1i(idNEAREST+1:idRANGE(end))+Y1north;
    
    % Refine grid cells around groyne
    MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
    MDAdata.nrgridcells(idNEAREST:idNEAREST+1)=8;
    ITHK_writeMDA2('BASIS.MDA',[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);

    % For post-processing (same number of points)
    MDAdata_ORIG.nrgridcells=MDAdata_ORIG.Xi.*0+1;MDAdata_ORIG.nrgridcells(1)=0;
    MDAdata_ORIG.nrgridcells(idNEAREST:idNEAREST+1)=8;
    ITHK_writeMDA2('BASIS_ORIG.MDA',[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata_ORIG.nrgridcells);    
end

%% Add local climates & adjust GROfile
% Updated coastline
MDAdatanew=ITHK_readMDA('BASIS.MDA');

% Find closest ray in GKL
[xGKL,yGKL,rayfiles]=ITHK_readGKL('locations5magrof2.GKL');
idRAY=findGRIDinrange(xGKL,yGKL,x,y,0);

% Info local climates
% Ray at GRO
RAYfilename = rayfiles(idRAY);
RAY = ITHK_readRAY([RAYfilename{1}(2:end-1) '.ray']);
equiA = mod(RAY.equi-angleA,360);
XA = MDAdatanew.Xcoast(idNEAREST+8);
YA = MDAdatanew.Ycoast(idNEAREST+8);
% Ray 2 GRO lengths from GRO
distC = abs(s1+2*S.userinput.groyne(ss).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
idC = find(distC==min(distC));
XC = MDAdatanew.Xcoast(idC);
YC = MDAdatanew.Ycoast(idC);
% Ray 1 GRO length from GRO
equiB = mod(RAY.equi-angleB,360);
distB = abs(s1+S.userinput.groyne(ss).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
idB = find(distB==min(distB));
XB = MDAdatanew.Xcoast(idB);
YB = MDAdatanew.Ycoast(idB);
% Summarize
XY = [XA YA; XB YB; XC YC];
nameA = [RAYfilename{1}(2:end-1) 'A.RAY'];
nameB = [RAYfilename{1}(2:end-1) 'B.RAY'];
nameC = [RAYfilename{1}(2:end-1) 'C.RAY'];
names = {nameA(1:end-4),nameB(1:end-4),nameC(1:end-4)};

% Write RAY files
RAY.path = {S.settings.outputdir};
RAY.name = {nameC};
ITHK_writeRAY(RAY);
RAY.name = {nameA};
RAY.equi = equiA;
ITHK_writeRAY(RAY);
RAY.name = {nameB};
RAY.equi = equiB;
ITHK_writeRAY(RAY);

% GROdata
Ngroynes = length(GROdata);
GROdata(Ngroynes+1).Xw = Xw;
GROdata(Ngroynes+1).Yw = Yw;
GROdata(Ngroynes+1).Length = S.userinput.groyne(ss).length;%0.2*Length; %Because length is not accurately represented in UNIBEST
GROdata(Ngroynes+1).BlockPerc = 100;
GROdata(Ngroynes+1).Yreference = 0;
GROdata(Ngroynes+1).option = 'right';
GROdata(Ngroynes+1).xyl = [];
GROdata(Ngroynes+1).ray_file1 = [];
GROdata(Ngroynes+1).xyr = XY;
GROdata(Ngroynes+1).ray_file2 = names;
ITHK_writeGRO([S.settings.outputdir S.userinput.groyne(ss).filename],GROdata);
S.UB.input(sens).groyne(ss).GROdata = GROdata;
S.UB.input(sens).groyne(ss).Ngroynes = length(GROdata)-4;
S.UB.input(sens).groyne(ss).rayfiles = {nameA,nameB,nameC};

%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end