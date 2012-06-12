function HKtool_PRN_to_kml(sens)

global S

%% input

EPSG = load('EPSG.mat');

% General info
t0 = S.PP.settings.t0;
tvec = S.PP.settings.tvec;
% MDA info
x0 = S.PP.settings.MDAdata_ORIG_OLD.Xcoast;
y0 = S.PP.settings.MDAdata_ORIG_OLD.Ycoast;
s0 = distXY(S.PP.settings.MDAdata_ORIG_OLD.Xcoast,S.PP.settings.MDAdata_ORIG_OLD.Ycoast);
% Grid info
sgridRough = S.PP.settings.sgridRough; 
dsRough = S.PP.settings.dsRough;
sgridFine = S.PP.settings.sgridFine;
dsFine = S.PP.settings.dsFine;
dxFine = S.PP.settings.dxFine;
sVectorLength = S.PP.settings.sVectorLength;
idplotrough = S.PP.settings.idplotrough;
idFR = S.PP.settings.idFR;
% minid = find([length(PRNdata.z(:,1)),length(z_ref(:,1))]==min(length(PRNdata.z(:,1)),length(z_ref(:,1))));

%% time loop
for j = 1:length(tvec)
    time    = datenum((tvec(j)+t0),1,1);

    %% grid data
    % coast line at t=tvec(j)
    if S.userinput.indicators.slr == 1
        xcoast(:,j) = S.UB(sens).results.PRNdata.xSLR(:,j);      % x-position of coast line
        ycoast(:,j) = S.UB(sens).results.PRNdata.ySLR(:,j);      % y-position of coast line
        zcoast(:,j) = S.UB(sens).results.PRNdata.zSLR(:,j);      % z-position of coast line
    else
        xcoast(:,j) = S.UB(sens).results.PRNdata.x(:,j);      % x-position of coast line
        ycoast(:,j) = S.UB(sens).results.PRNdata.y(:,j);      % y-position of coast line
        zcoast(:,j) = S.UB(sens).results.PRNdata.z(:,j);      % z-position of coast line
    end
 
    % coast line change relative to reference coast line at t=tvec(j)
    % omit double x-entries in interpolation
    [AA,ids1]=unique(xcoast(:,j));
%     [AA,ids1]=unique(S.UB(sens).results.PRNdata.x(:,j));
    [BB,ids2]=unique(S.UB(sens).data_ref.PRNdata.x(:,j));
    
%     % interpolate data to shortest dataset
%     if      length(zcoast(ids1,1))==length(S.UB(sens).data_ref.PRNdata.z(ids2,1))  
%             zPRN = zcoast(sort(ids1),j);
%             zref = S.UB(sens).data_ref.PRNdata.z(sort(ids2),j);
% %     elseif  minid==1
% %             zPRN = S.UB(sens).results.PRNdata.z(sort(ids1),j);
% %             zref = interp1(S.UB(sens).data_ref.PRNdata.x(sort(ids2),j),S.UB(sens).data_ref.PRNdata.z(sort(ids2),j),S.UB(sens).results.PRNdata.x(sort(ids1),j));
%     else
%             %zPRN = interp1(S.UB(sens).results.PRNdata.x(sort(ids1),j),S.UB(sens).results.PRNdata.z(sort(ids1),j),S.UB(sens).data_ref.PRNdata.x(sort(ids2),j));
%             zPRN = interp1(xcoast(sort(ids1),j),zcoast(sort(ids1),j),S.UB(sens).data_ref.PRNdata.x(sort(ids2),j));
%             zref = S.UB(sens).data_ref.PRNdata.z(sort(ids2),j);%!!!  
%     end
%     z = zPRN-zref;
%     % if x is longer than x0, interpolate to x0 (now interpolation in 2 steps, because direct interpolation gave unstable results) 
%     if  length(z)~=length(s0)
% %         if minid==1
% %             z=interp1(S.UB(sens).results.PRNdata.x(sort(ids1),j),z,x0); 
% %         else
%             z=interp1(S.UB(sens).data_ref.PRNdata.x(sort(ids2),j),z,x0);
% %         end
%     end
    
    zPRN = zcoast(sort(ids1),j);
    zPRN1 = zcoast(sort(ids1),1);
    z = zPRN-zPRN1;
    
    % if x is longer than x0, interpolate to x0 (now interpolation in 2 steps, because direct interpolation gave unstable results) 
    if  length(z)~=length(s0)
        z=interp1(xcoast(sort(ids1),j),z,x0); 
%         z=interp1(S.UB(sens).results.PRNdata.x(sort(ids1),j),z,x0); 
    end

    % rough grid
    zgridRough = interp1(s0,z,sgridRough);
    x0gridRough     = interp1(s0,x0,sgridRough);
    y0gridRough     = interp1(s0,y0,sgridRough);
    S.PP.coast.zgridRough(j,:) = zgridRough; 
    S.PP.coast.x0gridRough(j,:) = x0gridRough;
    S.PP.coast.y0gridRough(j,:) = y0gridRough;
    % fine grid
    zgridFine  = interp1(s0,z,sgridFine);
    x0gridFine      = interp1(s0,x0,sgridFine);
    y0gridFine      = interp1(s0,y0,sgridFine);
    S.PP.coast.zgridFine(j,:) = zgridFine; 
    S.PP.coast.x0gridFine(j,:) = x0gridFine;
    S.PP.coast.y0gridFine(j,:) = y0gridFine;

%     % dunes
%     aa = 1:4; range = 250;
%     xx = cos(aa*2*pi/aa(end))*range;
%     yy = sin(aa*2*pi/aa(end))*range;
%     xx = [xx xx(1)];yy = [yy yy(1)];
    
    %% polygons
    % spatial loop (rough grid): polygons to KML
    for i=2:length(sgridRough)-1
%         % dunes to KML  
%         xxdune = x0gridRough(i);%+xx;
%         yydune = y0gridRough(i);%+yy;
%         [londune,latdune] = convertCoordinates(xxdune,yydune,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
%         dist2 = ((x0-x0gridRough(i)).^2 + (y0-y0gridRough(i)).^2).^0.5;
%         idNEAREST = [];
%         idNEAREST = find(dist2==min(dist2),1,'first');
%         if      S.duneclass(idNEAREST,j)==1
%                 OPT.icon = 'http://127.0.0.1:5000/images/dunes_red.png';
%         elseif  S.duneclass(idNEAREST,j)==2
%                 OPT.icon = 'http://127.0.0.1:5000/images/dunes_orange.png';
%         else    OPT.icon = 'http://127.0.0.1:5000/images/dunes_green.png';
%         end
%         output = [output ITHK_KML_textballoon(londune,latdune,'icon',OPT.icon,'timeIn',time,'timeOut',time+364)];
        %
        if idplotrough(i)==1
            alpha    = atan((y0gridRough(i+1)-y0gridRough(i-1))/(x0gridRough(i+1)-x0gridRough(i-1)));
            if alpha>0
                xtip     = x0gridRough(i)+zgridRough(i)*sVectorLength*cos(alpha+pi()/2);
                ytip     = y0gridRough(i)+zgridRough(i)*sVectorLength*sin(alpha+pi()/2);
            elseif alpha<=0
                xtip     = x0gridRough(i)+zgridRough(i)*sVectorLength*cos(alpha-pi()/2);
                ytip     = y0gridRough(i)+zgridRough(i)*sVectorLength*sin(alpha-pi()/2);
            end
            xpoly(1)    = x0gridRough(i)+S.PP.settings.widthRough/2*cos(alpha);
            xpoly(2)    = xtip+S.PP.settings.widthRough/2*cos(alpha);
            xpoly(3)    = xtip-S.PP.settings.widthRough/2*cos(alpha);
            xpoly(4)    = x0gridRough(i)-S.PP.settings.widthRough/2*cos(alpha);
            xpoly(5)    = xpoly(1);
            ypoly(1)    = y0gridRough(i)+S.PP.settings.widthRough/2*sin(alpha);
            ypoly(2)    = ytip+S.PP.settings.widthRough/2*sin(alpha);
            ypoly(3)    = ytip-S.PP.settings.widthRough/2*sin(alpha);
            ypoly(4)    = y0gridRough(i)-S.PP.settings.widthRough/2*sin(alpha);
            ypoly(5)    = ypoly(1);
            % convert coordinates
            [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
            lonpoly     = lonpoly';
            latpoly     = latpoly';
            % color of polygon
            if zgridRough(i) < 0 % red
                S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 0 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)];
            else % green
                S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[0 1 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)]; 
            end
            % polygon to KML
            S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',time,'timeOut',time+364,'styleName','default')];
            clear lonpoly latpoly
            

        else
            idplotfine = idFR(i-1):idFR(i+1);
            for ii = 3:length(idplotfine)-2
                alpha    = atan((y0gridFine(idplotfine(ii+1))-y0gridFine(idplotfine(ii-1)))/(x0gridFine(idplotfine(ii+1))-x0gridFine(idplotfine(ii-1))));
                if alpha>0
                     xtip     = x0gridFine(idplotfine(ii))+zgridFine(idplotfine(ii))*sVectorLength*cos(alpha+pi()/2);
                     ytip     = y0gridFine(idplotfine(ii))+zgridFine(idplotfine(ii))*sVectorLength*sin(alpha+pi()/2);
                elseif alpha<=0
                     xtip     = x0gridFine(idplotfine(ii))+zgridFine(idplotfine(ii))*sVectorLength*cos(alpha-pi()/2);
                     ytip     = y0gridFine(idplotfine(ii))+zgridFine(idplotfine(ii))*sVectorLength*sin(alpha-pi()/2);
                end
                xpoly(1)    = x0gridFine(idplotfine(ii))+S.PP.settings.widthFine/2*cos(alpha);
                xpoly(2)    = xtip+S.PP.settings.widthFine/2*cos(alpha);
                xpoly(3)    = xtip-S.PP.settings.widthFine/2*cos(alpha);
                xpoly(4)    = x0gridFine(idplotfine(ii))-S.PP.settings.widthFine/2*cos(alpha);
                xpoly(5)    = xpoly(1);
                ypoly(1)    = y0gridFine(idplotfine(ii))+S.PP.settings.widthFine/2*sin(alpha);
                ypoly(2)    = ytip+S.PP.settings.widthFine/2*sin(alpha);
                ypoly(3)    = ytip-S.PP.settings.widthFine/2*sin(alpha);
                ypoly(4)    = y0gridFine(idplotfine(ii))-S.PP.settings.widthFine/2*sin(alpha);
                ypoly(5)    = ypoly(1);
                % convert coordinates
                [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
                lonpoly     = lonpoly';
                latpoly     = latpoly';
                % color of polygon
                if zgridFine(idplotfine(ii)) < 0 % red
                    S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 0 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)];
                else % green
                    S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[0 1 0],'lineColor',[0 0 0],'lineWidth',1,'fillAlpha',0.7)]; 
                end
                % polygon to KML
                S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',time,'timeOut',time+364,'styleName','default')];
                clear lonpoly latpoly
            end
        end
    end   

    % coast line to KML
    [lon2,lat2] = convertCoordinates(xcoast(:,j),ycoast(:,j),EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    S.PP.output.kml = [S.PP.output.kml KMLline(lat2,lon2,'timeIn',time,'timeOut',time+364,'lineColor',[1 1 0],'lineWidth',5,'lineAlpha',.7,'fileName',S.PP.output.kmlFileName)];  
    
%     if isfield(S,'dunes')
%         % dunes to kml
%         [lon3,lat3] = convertCoordinates(S.dunes.x(:,j),S.dunes.y(:,j),EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
%         S.PP.output.kml = [S.PP.output.kml KMLline(lat3,lon3,'timeIn',time,'timeOut',time+364,'lineColor',[0 0 1],'lineWidth',2,'lineAlpha',.7,'fileName',S.PP.output.kmlFileName)];
%         %clear lat3 lon3
%     end
end
% 
% S.output = output;