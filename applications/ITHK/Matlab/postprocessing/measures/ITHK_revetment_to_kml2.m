function ITHK_revetment_to_kml2(ss)

global S

%% Get info from structure
% General info
t0 = S.PP.settings.t0;
% lat = S.userinput.revetment(ss).lat;
% lon = S.userinput.revetment(ss).lon;
% MDA info
MDAdata_NEW = S.PP.settings.MDAdata_NEW;
% x0 = S.PP.settings.x0;
% y0 = S.PP.settings.y0;
% s0 = S.PP.settings.s0;
% Grid info
% sgridRough = S.PP.settings.sgridRough; 
% dxFine = S.PP.settings.dxFine;
% idplotrough = S.PP.settings.idplotrough;

%% preparation
% EPSG                = load('EPSG.mat');
% [x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

% %% Find rev points on coastline
% dist2 = ((MDAdata_NEW.Xcoast-x).^2 + (MDAdata_NEW.Ycoast-y).^2).^0.5;
% idNEAREST  = find(dist2==min(dist2));
% dist3 = ((MDAdata_NEW.Xcoast-MDAdata_NEW.Xcoast(idNEAREST)).^2 + (MDAdata_NEW.Xcoast-MDAdata_NEW.Xcoast(idNEAREST)).^2).^0.5;
% idRANGE  = find(dist3<S.userinput.revetment(ss).length/2);
% s1 = s0(idRANGE);

%Polygon for location of revetment
xpoly2=MDAdata_NEW.Xcoast(S.userinput.revetment(ss).idRANGE);
ypoly2=MDAdata_NEW.Ycoast(S.userinput.revetment(ss).idRANGE);

% convert coordinates
[lonpoly2,latpoly2] = convertCoordinates(xpoly2,ypoly2,S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
lonpoly2     = lonpoly2';
latpoly2     = latpoly2';

% orange line
S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','lineColor',[238/255 118/255 0],'lineWidth',7)];
% polygon to KML
S.PP.output.kml = [S.PP.output.kml KML_line(latpoly2 ,lonpoly2 ,'timeIn',datenum(t0+S.userinput.revetment(ss).start,1,1),'timeOut',datenum(t0+S.userinput.revetment(ss).stop,1,1)+364,'styleName','default')];
clear lonpoly2 latpoly2

% % Ids for barplots
% if s1(1)<s1(end) 
%     sfine(1)        = s1(1)-dxFine;
%     sfine(2)        = s1(end)+dxFine;
% else
%     sfine(1)        = s1(end)-dxFine;
%     sfine(2)        = s1(1)+dxFine;
% end
% for ii=1:length(sfine)
%     dist{ii} = abs(sgridRough-sfine(ii));
%     idrough(ii) = find(dist{ii} == min(dist{ii}),1,'first');
% end
% %idplotrough(idrough(1):idrough(end)) = 0;
% 
% % soutern vertex
% dist2           = abs(s1(1) - sgridRough);
% idNEAREST       = find(dist2==min(dist2));
% idsth           = idNEAREST;
% clear dist2 idNEAREST
% 
% % northern vertex
% dist2           = abs(s1(end) - sgridRough);
% idNEAREST       = find(dist2==min(dist2));
% idnrth          = idNEAREST;
% clear dist2 idNEAREST
% 
% S.PP.GEmapping.rev(S.userinput.revetment(ss).start:S.userinput.revetment(ss).stop,idsth:idnrth) = 1;
% 
% % %% Save info fine and rough grids for plotting bars
% % S.kml.idplotrough = idplotrough;
% % S.output = output;
