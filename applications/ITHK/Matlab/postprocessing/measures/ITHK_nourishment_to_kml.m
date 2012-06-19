function ITHK_nourishment_to_kml(sens)
%function ITHK_nourishment_to_kml(sens)
%
% Adds nourishments to the KML file
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .userinput.phases
%              .userinput.phase(idphase).SOSfile
%              .userinput.phase(idphase).supids
%              .userinput.suppletion(ids).volume
%              .userinput.suppletion(ids).idNEAREST
%              .userinput.suppletion(ids).idRANGE
%              .userinput.suppletion(ids).width
%              .userinput.suppletion(ids).category
%              .userinput.suppletion(ids).start
%              .userinput.suppletion(ids).stop
%              .PP(sens).settings.sVectorLength
%              .PP(sens).settings.t0
%              .PP(sens).settings.x0
%              .PP(sens).settings.y0
%              .PP(sens).output.kml
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).output.kml
%

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Adding nourishments to KML\n');

global S

S.PP(sens).output.kml_nourishment=[];

for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).SOSfile,'.')),'basis')
    for ii = 1:length(S.userinput.phase(jj).supids)
        ss = S.userinput.phase(jj).supids(ii);

        %% Get info from structure
        t0 = S.PP(sens).settings.t0;
        % lat = S.userinput.suppletion(ss).lat;
        % lon = S.userinput.suppletion(ss).lon;
        mag = S.userinput.suppletion(ss).volume;
        % MDA info
        x0 = S.PP(sens).settings.x0;
        y0 = S.PP(sens).settings.y0;
        % s0 = S.PP(sens).settings.s0;
        % Grid info
        % sgridRough = S.PP(sens).settings.sgridRough; 
        % dxFine = S.PP(sens).settings.dxFine;
        sVectorLength = S.PP(sens).settings.sVectorLength;
        % idplotrough = S.PP(sens).settings.idplotrough;
        
        %% preparation
        idNEAREST = S.userinput.suppletion(ss).idNEAREST;
        idRANGE = S.userinput.suppletion(ss).idRANGE;
        width = S.userinput.suppletion(ss).width;
        
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
            S.PP(sens).output.kml_nourishment = KML_stylePoly('name','default','fillColor',[1 1 0],'lineColor',[0 0 0],'lineWidth',0,'fillAlpha',0.7);
            % polygon to KML
            S.PP(sens).output.kml_nourishment = [S.PP(sens).output.kml_nourishment KML_poly(latpoly ,lonpoly ,'timeIn',datenum(t0+S.userinput.suppletion(ss).start,1,1),'timeOut',datenum(t0+S.userinput.suppletion(ss).stop,1,1)+364,'styleName','default')];
            clear lonpoly latpoly
        end
    end
    end
end        
        
        
        
        