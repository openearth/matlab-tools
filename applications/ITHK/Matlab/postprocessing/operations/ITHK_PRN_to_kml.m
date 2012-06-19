function ITHK_PRN_to_kml(sens)
% function ITHK_PRN_to_kml(sens)
%
% Writes coastline information from UNIBEST output (PRN-file) to 
% a datafield that is later on used to generate the KML file
% 
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB(sens).results.PRNdata
%              .UB(sens).data_ref.PRNdata.x
%              .UB(sens).data_ref.PRNdata.z
%              .UB(sens).results.PRNdata.xSLR
%              .UB(sens).results.PRNdata.ySLR
%              .UB(sens).results.PRNdata.zSLR
%              .PP(sens).settings.t0
%              .PP(sens).settings.tvec 
%              .PP(sens).settings.MDAdata_ORIG.X
%              .PP(sens).settings.MDAdata_ORIG.Y
%              .PP(sens).settings.MDAdata_ORIG.Xcoast
%              .PP(sens).settings.MDAdata_ORIG.Ycoast
%              .PP(sens).settings.sgridRough
%              .PP(sens).coast.x0gridRough
%              .PP(sens).coast.y0gridRough
%              .PP(sens).coast.zgridRough
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%              .PP(sens).coast.xcoast
%              .PP(sens).coast.ycoast
%              .PP(sens).output.kmlFileName
%              .settings.postprocessing.reference
%              .settings.indicators.coast.offset
%              .EPSG
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

fprintf('ITHK postprocessing : Processing coastline information + Adding it to KML\n');

global S

NRtimesteps   = length(S.PP(sens).settings.tvec);

%% initial coast line
t0 = S.PP(sens).settings.t0;
x0 = S.PP(sens).settings.MDAdata_ORIG.Xcoast; x0_ref = S.PP(sens).settings.MDAdata_ORIG.X;
y0 = S.PP(sens).settings.MDAdata_ORIG.Ycoast; y0_ref = S.PP(sens).settings.MDAdata_ORIG.Y;
s0 = distXY(S.PP(sens).settings.MDAdata_ORIG.Xcoast,S.PP(sens).settings.MDAdata_ORIG.Ycoast);
s0_ref = distXY(S.PP(sens).settings.MDAdata_ORIG.X,S.PP(sens).settings.MDAdata_ORIG.Y);

reference       = S.settings.plotting.reference;
%reference       = 'relative'; %'natural';

%% Map UB coastline to GE grid
S.PP(sens).coast.x0gridRough = interp1(s0,x0,S.PP(sens).settings.sgridRough); S.PP(sens).coast.x0_refgridRough = interp1(s0_ref,x0_ref,S.PP(sens).settings.sgridRough);
S.PP(sens).coast.y0gridRough = interp1(s0,y0,S.PP(sens).settings.sgridRough); S.PP(sens).coast.y0_refgridRough = interp1(s0_ref,y0_ref,S.PP(sens).settings.sgridRough);

if ~isfield(S.settings,'indicators')
S.settings.indicators.coast.offset='0';
end

for jj = 1:NRtimesteps
    %% grid data
    % coast line at t=tvec(j)
    xcoast(:,jj) = S.UB(sens).results.PRNdata.xSLR(:,jj);   % x-position of coast line
    ycoast(:,jj) = S.UB(sens).results.PRNdata.ySLR(:,jj);   % y-position of coast line
    zcoast(:,jj) = S.UB(sens).results.PRNdata.zSLR(:,jj);   % z-position of coast line
    
    %% coast line change relative to reference coast line at t=tvec(j)
    %% omit double x-entries in interpolation
    [AA,ids1]=unique(xcoast(:,jj));
    
    if strcmp(reference,'natural') || strcmp(reference,'relative')
        % Relative to autonomous situation 
        [BB,ids2]=unique(S.UB(sens).data_ref.PRNdata.x(:,jj));
    
        % interpolate data to shortest dataset
        if  length(ids1)==length(ids2)  
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
        % Relative to t0-situation
        zPRN = zcoast(sort(ids1),jj);
        zPRN1 = zcoast(sort(ids1),1);
        z(:,jj) = zPRN-zPRN1;
        
        % if x is longer than x0, interpolate to x0 (now interpolation in 2 steps, because direct interpolation gave unstable results) 
        if  length(z)~=length(s0)
            z(:,jj)=interp1(xcoast(sort(ids1),jj),z(:,jj),x0); 
        end
    end

    %% Save rough grid to structure
    S.PP(sens).coast.zgridRough(:,jj) = interp1(s0,z(:,jj),S.PP(sens).settings.sgridRough);
    S.PP(sens).coast.xcoast(:,jj) = xcoast(:,jj);
    S.PP(sens).coast.ycoast(:,jj) = ycoast(:,jj);
    S.PP(sens).coast.zcoast(:,jj) = z(:,jj);
end

%% Add to kml
if S.userinput.indicators.coast == 1
    % bars to KML
    KMLdata = ITHK_kmlbarplot(S.PP(sens).coast.x0gridRough,S.PP(sens).coast.y0gridRough,S.PP(sens).coast.zgridRough,S.settings.indicators.coast.offset,sens);
    S.PP(sens).output.kml = KMLdata;
    % coast line to KML
    for jj = 1:NRtimesteps
        time    = datenum((S.PP(sens).settings.tvec(jj)+S.PP(sens).settings.t0),1,1);
        [lon2,lat2] = convertCoordinates(S.PP(sens).coast.xcoast(:,jj),S.PP(sens).coast.ycoast(:,jj),S.EPSG,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
        KMLdata     = ITHK_KMLline(lat2,lon2,'timeIn',time,'timeOut',time+364,'lineColor',[1 1 0],'lineWidth',4,'lineAlpha',.7,'writefile',0);
        S.PP(sens).output.kml = [S.PP(sens).output.kml KMLdata];
    end
end
