function ITHK_add_suppletion2(index,phase,sens)

global S

%% Get info from struct
ss = S.userinput.phase(phase).supids(index);
lat = S.userinput.suppletion(ss).lat;
lon = S.userinput.suppletion(ss).lon;

%% convert coordinates
%EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
[SOSdata0]=ITHK_readSOS([S.settings.outputdir S.userinput.phase(phase).SOSfile]);
if strcmp(S.userinput.phase(phase).supcat{index},'cont') || strcmp(S.userinput.phase(phase).supcat{index},'distr')
    if exist([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],'file')
        SOSdata_cont=ITHK_readSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
    else
        SOSdata_cont=ITHK_readSOS([S.settings.outputdir 'BASIS.sos']);
        ITHK_writeSOS([S.settings.outputdir '1HOTSPOTSIT_cont.sos'],SOSdata_cont);
    end
end

%% calculate suppletion information
suppletion          = struct;
suppletion.name     = 'hotspots1locIT';
suppletion.x        = x;
suppletion.y        = y;
suppletion.volume   = S.userinput.suppletion(ss).volume;
suppletion.width    = 0.5*S.userinput.suppletion(ss).width;

%% write a SOS file (sources and sinks)
SOSfilename = [S.settings.outputdir S.userinput.phase(phase).SOSfile];
ITHK_writeSOS(SOSfilename,SOSdata0);
%suppletion.volume = volumes;
%suppletion.width  = 0.5*width;%must be radius
if strcmp(S.userinput.suppletion(ss).category,'distr')
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,suppletion,SOSfilename);
else
    [SOSdata2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,suppletion,SOSfilename);
end

S.UB.input(sens).suppletion(ss).SOSdata = suppletion;
S.userinput.suppletion(ss).idRANGE = idRANGE;
S.userinput.suppletion(ss).idNEAREST = idNEAREST;

% Update cont suppletion file
if strcmp(S.userinput.phase(phase).supcat{index},'cont') 
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addTRIANGULARnourishment(MDAdata,suppletion,[S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
elseif strcmp(S.userinput.phase(phase).supcat{index},'distr')
    [SOSdata_cont2,idNEAREST,idRANGE] = ITHK_addUNIFORMLYDISTRIBUTEDnourishment(MDAdata,suppletion,[S.settings.outputdir '1HOTSPOTSIT_cont.sos']);
end