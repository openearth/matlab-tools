function ITHK_revetment_to_kml(sens)
%function ITHK_revetment_to_kml(sens)
%
% Adds revetments to the KML file
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .userinput.phases
%              .userinput.phase(idphase).REVfile
%              .userinput.phase(idphase).revids
%              .userinput.revetment(ids).idRANGE
%              .userinput.revetment(ids).start
%              .userinput.revetment(ids).stop
%              .PP(sens).settings.MDAdata_NEW
%              .PP(sens).settings.sVectorLength
%              .PP(sens).settings.t0
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

fprintf('ITHK postprocessing : Adding revetments to KML\n');

global S

S.PP(sens).output.kml_revetment=[];

for jj = 1:length(S.userinput.phases)
    if ~strcmp(lower(strtok(S.userinput.phase(jj).REVfile,'.')),'basis')
    for ii = 1:length(S.userinput.phase(jj).revids)
        ss = S.userinput.phase(jj).revids(ii);

        % Get info from structure
        t0 = S.PP(sens).settings.t0;

        % MDA info
        MDAdata_NEW = S.PP(sens).settings.MDAdata_NEW;
        
        %Polygon for location of revetment
        xpoly2=MDAdata_NEW.Xcoast(S.userinput.revetment(ss).idRANGE);
        ypoly2=MDAdata_NEW.Ycoast(S.userinput.revetment(ss).idRANGE);
        
        % convert coordinates
        [lonpoly2,latpoly2] = convertCoordinates(xpoly2,ypoly2,S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        lonpoly2     = lonpoly2';
        latpoly2     = latpoly2';
        
        % orange line
        if jj==1 && ii==1
        S.PP(sens).output.kml_revetment = KML_stylePoly('name','revetment','lineColor',[238/255 118/255 0],'lineWidth',7);
        end
        % polygon to KML
        S.PP(sens).output.kml_revetment = [S.PP(sens).output.kml_revetment KML_line(latpoly2 ,lonpoly2 ,'timeIn',datenum(t0+S.userinput.revetment(ss).start,1,1),'timeOut',datenum(t0+S.userinput.revetment(ss).stop,1,1)+364,'styleName','revetment')];
        clear lonpoly2 latpoly2
    end
    end
end