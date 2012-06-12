function ITHK_add_suppletion(ss,phase,sens)

global S

%% Get info from struct
lat = S.userinput.suppletion(ss).lat;
lon = S.userinput.suppletion(ss).lon;
mag = S.userinput.suppletion(ss).magnitude;

%% convert coordinates
EPSG                = load('EPSG.mat');
[x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_readMDA('BASIS.MDA');
% if phase==1
%     [SOSdata0]=ITHK_readSOS([S.outputdir S.suppletion(ss).filename]);
% else
%     [SOSdata0]=ITHK_readSOS([S.outputdir S.phase(phase-1).SOSfile]);
% end
[SOSdata0]=ITHK_readSOS([S.settings.outputdir S.userinput.suppletion(ss).filename]);
%[SOSdata0]=ITHK_readSOS('1HOTSPOTS1IT.SOS');

%% calculate suppletion information
nSuppletion         = 1; % number of suppletions

suppletion          = struct;
suppletion.name     = 'hotspots1locIT';
suppletion.x        = mean(x);
suppletion.y        = mean(y);
volumes             = mag;

% width
width               = (abs(x(1)-x(end))^2+abs(y(1)-y(end))^2)^0.5;

% project line on coast
dist1=[];
for jj=1:nSuppletion
    dist3           = ((MDAdata.Xcoast-suppletion.x(jj)).^2 + (MDAdata.Ycoast-suppletion.y(jj)).^2).^0.5;  % distance to coast line
    idNEAREST       = find(dist3==min(dist3));
    x1(jj)          = MDAdata.Xcoast(idNEAREST);%MDAdata.QpointsX(idNEAREST);
    y1(jj)          = MDAdata.Ycoast(idNEAREST);%MDAdata.QpointsY(idNEAREST);
    dist            = distXY(MDAdata.Xcoast,MDAdata.Ycoast); % distance from boundary
    dist1(jj)       = dist(idNEAREST); % distance from boundary
end

%% write a SOS file (sources and sinks)
for ii=1:length(suppletion)
    for nn=1:length(volumes)
        if ii==1
            SOSfilename = [S.settings.outputdir S.userinput.suppletion(ss).filename];
            %SOSfilename = ['1HOTSPOTS',num2str(ss+1),'IT.sos'];
        end
        %SOSfilename = ['1HOTSPOTS',num2str(ss+1),'IT.sos'];
        ITHK_writeSOS(SOSfilename,SOSdata0);
        %S.suppletion(ss).filename = SOSfilename;
        suppletion(ii).volume = volumes(nn);
        suppletion(ii).width  = 0.5*width(nn);%must be radius
        ITHK_addTRIANGULARnourishment(MDAdata,suppletion(ii),SOSfilename)
    end
end
S.UB.input(sens).suppletion(ss).SOSdata = suppletion;