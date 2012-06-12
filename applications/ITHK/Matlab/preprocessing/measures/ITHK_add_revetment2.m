function ITHK_add_revetment2(ii,phase,NREV,sens)

global S

%% get relevant info from struct
lat = S.userinput.revetment(ii).lat;
lon = S.userinput.revetment(ii).lon;

%% convert coordinates
%EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
if phase==1 || NREV>1
    [REVdata]=ITHK_readREV([S.settings.outputdir S.userinput.revetment(ii).filename]);
else
    [REVdata]=ITHK_readREV([S.settings.outputdir S.userinput.phase(phase-1).REVfile]);
end

%% process input and add to file
S.UB.input(sens).revetment(ii).length = S.userinput.revetment(ii).length;
[idNEAREST,idRANGE]=findGRIDinrange(MDAdata.Xcoast,MDAdata.Ycoast,x,y,0.5*S.userinput.revetment(ii).length);

Nrev = length(REVdata);
REVdata(Nrev+1).filename = [S.settings.outputdir S.userinput.revetment(ii).filename];
REVdata(Nrev+1).Xw = MDAdata.Xcoast(idRANGE)';
REVdata(Nrev+1).Yw = MDAdata.Ycoast(idRANGE)';
REVdata(Nrev+1).Top = [];
if  S.userinput.revetment(ii).fill==0
    REVdata(Nrev+1).Option = 0;
else
    REVdata(Nrev+1).Option = 2;
end
ITHK_writeREV_new(REVdata,MDAdata,0.1)
S.UB.input(sens).revetment(ii).REVdata = REVdata;
S.userinput.revetment(ii).idRANGE = idRANGE;

%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end