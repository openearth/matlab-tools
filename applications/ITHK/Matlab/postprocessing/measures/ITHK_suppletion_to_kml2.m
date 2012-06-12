function ITHK_suppletion_to_kml2(ss)

global S

%% Get info from structure
% General info
t0 = S.PP.settings.t0;
% lat = S.userinput.suppletion(ss).lat;
% lon = S.userinput.suppletion(ss).lon;
mag = S.userinput.suppletion(ss).volume;
% MDA info
x0 = S.PP.settings.x0;
y0 = S.PP.settings.y0;
% s0 = S.PP.settings.s0;
% Grid info
% sgridRough = S.PP.settings.sgridRough; 
% dxFine = S.PP.settings.dxFine;
sVectorLength = S.PP.settings.sVectorLength;
% idplotrough = S.PP.settings.idplotrough;

%% preparation
idNEAREST = S.userinput.suppletion(ss).idNEAREST;
idRANGE = S.userinput.suppletion(ss).idRANGE;
width = S.userinput.suppletion(ss).width;
%EPSG  = load('EPSG.mat');

% % convert coordinates suppletion to RD new
% EPSG                = load('EPSG.mat');
% [x,y]               = convertCoordinates(lon,lat,EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);
% 
% % width suppletion
% width               = S.userinput.suppletion(ss).width;%(abs(x(1)-x(end))^2+abs(y(1)-y(end))^2)^0.5;
% 
% % project suppletion location on coast line
% dist2           = ((x0-mean(x)).^2 + (y0-mean(y)).^2).^0.5;  % distance to coast line
% idNEAREST       = find(dist2==min(dist2));
% x1              = x0(idNEAREST);
% y1              = y0(idNEAREST);
% s1              = s0(idNEAREST);
% clear dist2 idNEAREST
% 
% % soutern vertex
% dist2           = abs(s1-width/2 - s0);
% id1             = find(dist2==min(dist2));
% x2              = x0(id1);
% y2              = y0(id1);
% s2              = s0(id1);
% clear dist2
% 
% % northern vertex
% dist2           = abs(s1+width/2 - s0);
% id2             = find(dist2==min(dist2));
% x4              = x0(id2);
% y4              = y0(id2);
% s4              = s0(id2);
% clear dist2

% % southern boundary fine grid
% dist2           = abs(s2-dxFine - s0);
% idNEAREST       = find(dist2==min(dist2));
% sfine(1)        = s0(idNEAREST);
% clear dist2 idNEAREST
% 
% % northern boundary fine grid
% dist2           = abs(s4+dxFine - s0);
% idNEAREST       = find(dist2==min(dist2));
% sfine(2)        = s0(idNEAREST);
% clear dist2 idNEAREST

% % ids for barplots
% for jj=1:length(sfine)
%     dist{jj} = abs(sgridRough-sfine(jj));
%     idrough(jj) = find(dist{jj} == min(dist{jj}),1,'first');
% end
% %idplotrough(idrough(1):idrough(2)) = 0;
% 
% % soutern vertex
% dist2           = abs(s1-width/2 - sgridRough);
% idNEAREST       = find(dist2==min(dist2));
% idsth           = idNEAREST;
% clear dist2 idNEAREST
% 
% % northern vertex
% dist2           = abs(s1+width/2 - sgridRough);
% idNEAREST       = find(dist2==min(dist2));
% idnrth          = idNEAREST;
% clear dist2 idNEAREST
% 
% S.PP.GEmapping.supp(S.userinput.suppletion(ss).start:S.userinput.suppletion(ss).stop,idsth:idnrth) = 1;

%% suppletion to KML
h = mag/width;
%Only plot suppletion if extent is bigger than resolution
if S.userinput.suppletion(ss).idRANGE(1)~=S.userinput.suppletion(ss).idRANGE(end)%x2~=x4 
    % For single or cont, plot triangle
    if ~strcmp(S.userinput.suppletion(ss).category,'distr')
        alpha = atan((y0(idRANGE(end))-y0(idRANGE(1)))/(x0(idRANGE(end))-x0(idRANGE(1))));%alpha = atan((y4-y2)/(x4-x2));
        if alpha>0
            x3     = x0(idNEAREST)+0.5*sVectorLength*h*cos(alpha+pi()/2);%x1+0.5*sVectorLength*h*cos(alpha+pi()/2);
            y3     = y0(idNEAREST)+0.5*sVectorLength*h*sin(alpha+pi()/2);%y1+0.5*sVectorLength*h*sin(alpha+pi()/2);
        elseif alpha<=0
            x3     = x0(idNEAREST)+0.5*sVectorLength*h*cos(alpha-pi()/2);%x1+0.5*sVectorLength*h*cos(alpha-pi()/2);
            y3     = y0(idNEAREST)+0.5*sVectorLength*h*sin(alpha-pi()/2);%y1+0.5*sVectorLength*h*sin(alpha-pi()/2);
        end
        xpoly=[x0(idNEAREST) x0(idRANGE(1)) x3 x0(idRANGE(end)) x0(idNEAREST)];%[x1 x2 x3 x4 x1];
        ypoly=[y0(idNEAREST) y0(idRANGE(1)) y3 y0(idRANGE(end)) y0(idNEAREST)];%[y1 y2 y3 y4 y1];
    % For distr, plot rectangle
    else
        idsupp = idRANGE(1:end-1);%id1:id2;
        for jj=1:length(idsupp)-1
            alpha = atan((y0(idsupp(jj)+1)-y0(idsupp(jj)))/(x0(idsupp(jj)+1)-x0(idsupp(jj))));
            if alpha>0
                x2(jj)     = x0(idsupp(jj))+0.5*sVectorLength*h*cos(alpha+pi()/2);
                y2(jj)     = y0(idsupp(jj))+0.5*sVectorLength*h*sin(alpha+pi()/2);
            elseif alpha<=0
                x2(jj)     = x0(idsupp(jj))+0.5*sVectorLength*h*cos(alpha-pi()/2);
                y2(jj)     = y0(idsupp(jj))+0.5*sVectorLength*h*sin(alpha-pi()/2);
            end
        end
        xpoly=[x0(idsupp)' fliplr(x2) x0(idsupp(1))];
        ypoly=[y0(idsupp)' fliplr(y2) y0(idsupp(1))];
    end

    % convert coordinates
    [lonpoly,latpoly] = convertCoordinates(xpoly,ypoly,S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    lonpoly     = lonpoly';
    latpoly     = latpoly';

    % yellow triangle/rectangle
    S.PP.output.kml = [S.PP.output.kml KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7)];
    % polygon to KML
    S.PP.output.kml = [S.PP.output.kml KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.suppletion(ss).start,1,1),'timeOut',datenum(t0+S.userinput.suppletion(ss).stop,1,1)+364,'styleName','default')];
    clear lonpoly latpoly
end