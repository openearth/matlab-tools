function ITHK_mapUBtoGE2(sens)

global S

%% initial coast line
x0 = S.PP.settings.MDAdata_ORIG.Xcoast; x0_ref = S.PP.settings.MDAdata_ORIG.X;
y0 = S.PP.settings.MDAdata_ORIG.Ycoast; y0_ref = S.PP.settings.MDAdata_ORIG.Y;
s0 = distXY(S.PP.settings.MDAdata_ORIG.Xcoast,S.PP.settings.MDAdata_ORIG.Ycoast);
s0_ref = distXY(S.PP.settings.MDAdata_ORIG.X,S.PP.settings.MDAdata_ORIG.Y);

reference       = S.settings.postprocessing.reference;
%EPSG            = load('EPSG.mat');

%% Map UB coastline to GE grid
S.PP.coast.x0gridRough = interp1(s0,x0,S.PP.settings.sgridRough); S.PP.coast.x0_refgridRough = interp1(s0_ref,x0_ref,S.PP.settings.sgridRough);
S.PP.coast.y0gridRough = interp1(s0,y0,S.PP.settings.sgridRough); S.PP.coast.y0_refgridRough = interp1(s0_ref,y0_ref,S.PP.settings.sgridRough);
for jj = 1:length(S.PP.settings.tvec)
    %% grid data
    % coast line at t=tvec(j)
    if S.userinput.indicators.slr == 1
        xcoast(:,jj) = S.UB(sens).results.PRNdata.xSLR(:,jj);   % x-position of coast line
        ycoast(:,jj) = S.UB(sens).results.PRNdata.ySLR(:,jj);   % y-position of coast line
        zcoast(:,jj) = S.UB(sens).results.PRNdata.zSLR(:,jj);   % z-position of coast line
    else
        xcoast(:,jj) = S.UB(sens).results.PRNdata.x(:,jj);      % x-position of coast line
        ycoast(:,jj) = S.UB(sens).results.PRNdata.y(:,jj);      % y-position of coast line
        zcoast(:,jj) = S.UB(sens).results.PRNdata.z(:,jj);      % z-position of coast line
    end
    
    %% coast line change relative to reference coast line at t=tvec(j)
    %% omit double x-entries in interpolation
    [AA,ids1]=unique(xcoast(:,jj));
    
    if strcmp(reference,'natural')
        [BB,ids2]=unique(S.UB(sens).data_ref.PRNdata.x(:,jj));
    
        % interpolate data to shortest dataset
        if  length(zcoast(ids1,1))==length(S.UB(sens).data_ref.PRNdata.z(ids2,1))  
            zPRN = zcoast(sort(ids1),jj);
            zref = S.UB(sens).data_ref.PRNdata.z(sort(ids2),jj);
        else
            zPRN = interp1(xcoast(sort(ids1),jj),zcoast(sort(ids1),jj),S.UB(sens).data_ref.PRNdata.x(sort(ids2),jj));
            zref = S.UB(sens).data_ref.PRNdata.z(sort(ids2),jj);  
        end
        z(:,jj) = zPRN-zref;
        % if x is longer than x0, interpolate to x0 (now interpolation in 2 steps, because direct interpolation gave unstable results) 
        if  length(z)~=length(s0)
            z(:,jj)=interp1(S.UB(sens).data_ref.PRNdata.x(sort(ids2),jj),z(:,jj),x0);
        end
    else
        zPRN = zcoast(sort(ids1),jj);
        zPRN1 = zcoast(sort(ids1),1);
        z = zPRN-zPRN1;
    
        % if x is longer than x0, interpolate to x0 (now interpolation in 2 steps, because direct interpolation gave unstable results) 
        if  length(z)~=length(s0)
            z=interp1(xcoast(sort(ids1),jj),z,x0); 
        end
        z(:,jj) = z;
    end

    %% Save rough grid to structure
    S.PP.coast.zminz0Rough(:,jj) = interp1(s0,z(:,jj)-z(:,1),S.PP.settings.sgridRough);
    S.PP.coast.zgridRough(:,jj) = interp1(s0,z(:,jj),S.PP.settings.sgridRough);
    S.PP.coast.xcoast(:,jj) = xcoast(:,jj);
    S.PP.coast.ycoast(:,jj) = ycoast(:,jj);
    S.PP.coast.zcoast(:,jj) = z(:,jj);
    S.PP.coast.zminz0(:,jj) = z(:,jj)-z(:,1);
end

%% Add to kml
if S.userinput.indicators.coast == 1
    % bars to KML
    ITHK_kmlbarplot(S.PP.coast.x0gridRough,S.PP.coast.y0gridRough,S.PP.coast.zgridRough,str2double(S.settings.indicators.coast.offset))
    % coast line to KML
    for jj = 1:length(S.PP.settings.tvec)
        time    = datenum((S.PP.settings.tvec(jj)+S.PP.settings.t0),1,1);
        [lon2,lat2] = convertCoordinates(S.PP.coast.xcoast(:,jj),S.PP.coast.ycoast(:,jj),S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        S.PP.output.kml = [S.PP.output.kml KMLline(lat2,lon2,'timeIn',time,'timeOut',time+364,'lineColor',[1 1 0],'lineWidth',5,'lineAlpha',.7,'fileName',S.PP.output.kmlFileName)];
    end
end

%% Initialize measures for UB mapping
% Total coastline
S.PP.UBmapping.supp_beach = zeros(length(S.PP.settings.tvec),length(xcoast(:,1)));
S.PP.UBmapping.supp_foreshore = zeros(length(S.PP.settings.tvec),length(xcoast(:,1)));
S.PP.UBmapping.supp_mega = zeros(length(S.PP.settings.tvec),length(xcoast(:,1)));
S.PP.UBmapping.rev = zeros(length(S.PP.settings.tvec),length(xcoast(:,1)));
S.PP.UBmapping.gro = zeros(length(S.PP.settings.tvec),length(xcoast(:,1)));

for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).supids)
            ss = S.userinput.phase(jj).supids(ii); 
            if S.userinput.suppletion(ss).volperm < 400
                S.PP.UBmapping.supp_beach(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            elseif  S.userinput.suppletion(ss).volperm > 4000
                S.PP.UBmapping.supp_mega(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            else
                S.PP.UBmapping.supp_foreshore(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,S.userinput.suppletion(ss).idRANGE) = 1;
            end
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ss = S.userinput.phase(jj).revids(ii); 
            S.PP.UBmapping.rev(S.userinput.revetment(ss).start+1:S.userinput.revetment(ss).stop,S.userinput.revetment(ss).idRANGE) = 1;
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).groids)
            ss = S.userinput.phase(jj).groids(ii); 
            S.PP.UBmapping.gro(S.userinput.groyne(ss).start+1:S.userinput.groyne(ss).stop,S.userinput.groyne(ss).idNEAREST) = 1;
        end
    end
end

%% Initialize measures for GE mapping
% Mapping on rough grid (for plotting in GE)
S.PP.GEmapping.supp_beach = zeros(length(S.PP.settings.tvec),length(S.PP.coast.x0gridRough));
S.PP.GEmapping.supp_foreshore = zeros(length(S.PP.settings.tvec),length(S.PP.coast.x0gridRough));
S.PP.GEmapping.supp_mega = zeros(length(S.PP.settings.tvec),length(S.PP.coast.x0gridRough));
S.PP.GEmapping.rev = zeros(length(S.PP.settings.tvec),length(S.PP.coast.x0gridRough));
S.PP.GEmapping.gro= zeros(length(S.PP.settings.tvec),length(S.PP.coast.x0gridRough));

for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).supids)
            ss = S.userinput.phase(jj).supids(ii); 
            [x,y] = convertCoordinates(S.userinput.suppletion(ss).lon,S.userinput.suppletion(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP.coast.x0gridRough(1,:),S.PP.coast.y0gridRough(1,:),x,y,0.5*S.userinput.suppletion(ss).width);
            if S.userinput.suppletion(ss).volperm < 400
                S.PP.GEmapping.supp_beach(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,idRANGE) = 1;
            elseif  S.userinput.suppletion(ss).volperm > 4000
                S.PP.GEmapping.supp_mega(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,idRANGE) = 1;
            else
                S.PP.GEmapping.supp_foreshore(S.userinput.suppletion(ss).start+1:S.userinput.suppletion(ss).stop,idRANGE) = 1;
            end
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).revids)
            ss = S.userinput.phase(jj).revids(ii); 
            [x,y] = convertCoordinates(S.userinput.revetment(ss).lon,S.userinput.revetment(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP.coast.x0gridRough(1,:),S.PP.coast.y0gridRough(1,:),x,y,0.5*S.userinput.revetment(ss).length);
            S.PP.GEmapping.rev(S.userinput.revetment(ss).start+1:S.userinput.revetment(ss).stop,idRANGE) = 1;
        end
    end
    if ~strcmp(lower(strtok(S.userinput.phase(jj).GROfile,'.')),'basis')
        for ii = 1:length(S.userinput.phase(jj).groids)
            ss = S.userinput.phase(jj).groids(ii);
            [x,y] = convertCoordinates(S.userinput.groyne(ss).lon,S.userinput.groyne(ss).lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);
            [idNEAREST,idRANGE]=findGRIDinrange(S.PP.coast.x0gridRough(1,:),S.PP.coast.y0gridRough(1,:),x,y,str2double(S.settings.measures.groyne.updatewidth)*S.userinput.groyne(ss).length); 
            S.PP.GEmapping.gro(S.userinput.groyne(ss).start+1:S.userinput.groyne(ss).stop,idNEAREST) = 1;
        end
    end
end

%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end