function ITHK_eco_to_kml

%% input
global S

EPSG = load('EPSG.mat');

% General info
t0 = S.PP.settings.t0;
tvec = S.PP.settings.tvec;
% MDA info
x0 = S.PP.settings.MDAdata_ORIG_OLD.Xcoast;
y0 = S.PP.settings.MDAdata_ORIG_OLD.Ycoast;
s0 = distXY(S.PP.settings.MDAdata_ORIG_OLD.Xi,S.PP.settings.MDAdata_ORIG_OLD.Yi);
% Grid info
sgridRough = S.PP.settings.sgridRough; 
dsRough = S.PP.settings.dsRough;
sgridFine = S.PP.settings.sgridFine;
dsFine = S.PP.settings.dsFine;
dxFine = S.PP.settings.dxFine;
sVectorLength = S.PP.settings.sVectorLength;
idplotrough = S.PP.settings.idplotrough;
idFR = S.PP.settings.idFR;
widthRough = S.PP.settings.widthRough;

% EPSG = load('EPSG');
% output = S.output;
% sgridRough = S.kml.sgridRough; 
% sgridFine = S.kml.sgridFine;
% dsRough = S.kml.dsRough;
% dsFine = S.kml.dsFine;
% dxFine = S.kml.dxFine;
% sVectorLength = S.kml.sVectorLength;
% idplotrough = S.kml.idplotrough;
% tvec = S.kml.tvec;
% widthRough = S.kml.widthRough;
% widthFine = S.kml.widthFine;
% idFR = S.kml.idFR;
%MDAdata_old = S.MDAdata_ref;
% MDAdata_NEW = S.MDAdata_NEW;
% MDAdata_ORIG_OLD = S.MDAdata_ORIG_OLD;
%MDAdata_ref = S.MDAdata_ref;%!!!
% x0 = MDAdata_ORIG_OLD.Xcoast;
% y0 = MDAdata_ORIG_OLD.Ycoast;
% s0 = distXY(S.MDAdata_ORIG_OLD.Xi,S.MDAdata_ORIG_OLD.Yi);
% PRNdata = S.UB(1).results.PRNdata
% t0 = S.kml.t0;
% z_ref = S.z_ref;
% x_ref = S.x_ref;
% minid = find([length(PRNdata.z(:,1)),length(z_ref(:,1))]==min(length(PRNdata.z(:,1)),length(z_ref(:,1))));
P = S.PP.GEmapping.eco.P;
x0gridRough = S.PP.GEmapping.x0(1,:);
y0gridRough = S.PP.GEmapping.y0(1,:);
P_viewRation = 0.3;

%% time loop
for j = 1:length(tvec)
    time    = datenum((tvec(j)+t0),1,1);

    %% polygons
    % spatial loop (rough grid): polygons to KML
    for i=2:length(sgridRough)-1
            alpha    = atan((y0gridRough(i+1)-y0gridRough(i-1))/(x0gridRough(i+1)-x0gridRough(i-1)));
            if alpha>0
                xtip     = x0gridRough(i)+P(j,i)*P_viewRation*sVectorLength*cos(alpha+pi()/2);
                ytip     = y0gridRough(i)+P(j,i)*P_viewRation*sVectorLength*sin(alpha+pi()/2);
            elseif alpha<=0
                xtip     = x0gridRough(i)+P(j,i)*P_viewRation*sVectorLength*cos(alpha-pi()/2);
                ytip     = y0gridRough(i)+P(j,i)*P_viewRation*sVectorLength*sin(alpha-pi()/2);
            end
            xpoly(1)    = x0gridRough(i)+widthRough/2*cos(alpha);
            xpoly(2)    = xtip+widthRough/2*cos(alpha);
            xpoly(3)    = xtip-widthRough/2*cos(alpha);
            xpoly(4)    = x0gridRough(i)-widthRough/2*cos(alpha);
            xpoly(5)    = xpoly(1);
            ypoly(1)    = y0gridRough(i)+widthRough/2*sin(alpha);
            ypoly(2)    = ytip+widthRough/2*sin(alpha);
            ypoly(3)    = ytip-widthRough/2*sin(alpha);
            ypoly(4)    = y0gridRough(i)-widthRough/2*sin(alpha);
            ypoly(5)    = ypoly(1);
            % convert coordinates
            [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
            lonpoly     = lonpoly';
            latpoly     = latpoly';
            % color of polygon
            if P(j,i) < 0 % red
                S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 0 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)];
            else % green
                S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[0 1 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)]; 
            end
            % polygon to KML
            S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',time,'timeOut',time+364,'styleName','default')];
            clear lonpoly latpoly
    end  
%     % coast line to KML
     [lon2,lat2] = convertCoordinates(x0gridRough,y0gridRough,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
     S.PP.output.kml = [S.PP.output.kml KMLline(lat2,lon2,'timeIn',time,'timeOut',time+364,'lineColor',[1 1 0],'lineWidth',5,'lineAlpha',.7,'fileName',S.PP.output.kmlFileName)];  
end

%S.output = output;