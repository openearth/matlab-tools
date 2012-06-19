function ITHK_add_groyne(ii,phase,NGRO,sens)
%function ITHK_add_groyne(ii,phase,NGRO,sens)
%
% Adds groynes to the GRO file
%
% INPUT:
%      ii     number of beach extension
%      phase  phase number (of CL-model)
%      NGRO   number of groynes
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .EPSG
%              .settings.outputdir
%              .userinput.groyne(ii).lat
%              .userinput.groyne(ii).lon
%              .userinput.groyne(ii).filename
%              .userinput.groyne(ii).length
%              .userinput.phase(phase-1).GROfile
%              .settings.measures.groyne.coastlineupdate
%              .settings.measures.groyne.updatewidth
%              .settings.measures.groyne.angleshiftclimateA
%              .settings.measures.groyne.angleshiftclimateB
%      MDAfile  'BASIC.MDA' & 'BASIS_ORIG.MDA'
%      GKLfile  'locations5magrof2.GKL'
%
% OUTPUT:
%      GROfile  file with additional groyne and links to local climate rays
%      RAYfiles name of nearest ray with A,B,C as additional string (for sheltered climates)
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

global S

%% get info from struct
lat = S.userinput.groyne(ii).lat;
lon = S.userinput.groyne(ii).lon;

% GRO settings
cstupdate = str2double(S.settings.measures.groyne.coastlineupdate);
updatewidth = str2double(S.settings.measures.groyne.updatewidth);
angleA = str2double(S.settings.measures.groyne.angleshiftclimateA);
angleB = str2double(S.settings.measures.groyne.angleshiftclimateB);

%% convert coordinates
[x,y]               = convertCoordinates(lon,lat,S.EPSG,'CS1.name','WGS 84','CS1.type','geo','CS2.code',28992);

%% read files
[MDAdata]=ITHK_io_readMDA('BASIS.MDA');
[MDAdata_ORIG]=ITHK_io_readMDA('BASIS_ORIG.MDA');
if phase==1 || NGRO>1
    [GROdata]=ITHK_io_readGRO([S.settings.outputdir S.userinput.groyne(ii).filename]);
else
    [GROdata]=ITHK_io_readGRO([S.settings.outputdir S.userinput.phase(phase-1).GROfile]);
end

%% Find groyne location on initial coastline
[idNEAREST,idRANGE]=findGRIDinrange(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast,x,y,updatewidth*S.userinput.groyne(ii).length);
S.userinput.groyne(ss).idNEAREST = idNEAREST;

% Groyne points
S.UB.input(sens).groyne(ii).length = S.userinput.groyne(ii).length;
Xw = MDAdata_ORIG.Xcoast(idNEAREST);
Yw = MDAdata_ORIG.Ycoast(idNEAREST);
s0 = distXY(MDAdata_ORIG.Xcoast,MDAdata_ORIG.Ycoast);
s1 = s0(idNEAREST);

%% Update initial coastline around groyne (in MDA)
if cstupdate == 1   
    % Beach extension south of groyne (0.5 GRO length)
    if length(idRANGE(1):idNEAREST)>1
        Y1south = interp1([MDAdata_ORIG.Xcoast(idRANGE(1)) MDAdata_ORIG.Xcoast(idNEAREST)],[0 0.5*S.userinput.groyne(ii).length],MDAdata_ORIG.Xcoast(idRANGE(1):idNEAREST));
    end
    Y1_new = MDAdata.Y1i;
    Y1_new(idRANGE(1):idNEAREST) = MDAdata.Y1i(idRANGE(1):idNEAREST)+Y1south;
    
    % Beach extension nord of groyne  (0.5 GRO length)
    if length(idNEAREST+1:idRANGE(end))>1
        Y1north = interp1([MDAdata_ORIG.Xcoast(idNEAREST) MDAdata_ORIG.Xcoast(idRANGE(end))],[0.5*S.userinput.groyne(ii).length 0],x0(idNEAREST+1:idRANGE(end)));
    end
    Y1_new(idNEAREST+1:idRANGE(end)) = MDAdata.Y1i(idNEAREST+1:idRANGE(end))+Y1north;
    
    % Refine grid cells around groyne
    MDAdata.nrgridcells=MDAdata.Xi.*0+1;MDAdata.nrgridcells(1)=0;
    MDAdata.nrgridcells(idNEAREST:idNEAREST+1)=8;
    ITHK_io_writeMDA('BASIS.MDA',[MDAdata.Xi MDAdata.Yi],Y1_new,[],MDAdata.nrgridcells);

    % For post-processing (same number of points)
    MDAdata_ORIG.nrgridcells=MDAdata_ORIG.Xi.*0+1;MDAdata_ORIG.nrgridcells(1)=0;
    MDAdata_ORIG.nrgridcells(idNEAREST:idNEAREST+1)=8;
    ITHK_io_writeMDA('BASIS_ORIG.MDA',[MDAdata_ORIG.Xi MDAdata_ORIG.Yi],MDAdata_ORIG.Y1i,[],MDAdata_ORIG.nrgridcells);    
end

%% Add local climates & adjust GROfile
% Updated coastline
MDAdatanew=ITHK_io_readMDA('BASIS.MDA');
% Find closest ray in GKL
[xGKL,yGKL,rayfiles]=ITHK_io_readGKL('locations5magrof2.GKL');
idRAY=findGRIDinrange(xGKL,yGKL,x,y,0);

%% Info local climates
% Ray at GRO
RAYfilename = rayfiles(idRAY);
RAY = ITHK_io_readRAY([RAYfilename{1}(2:end-1) '.ray']);
equiA = mod(RAY.equi-angleA,360);
XA = MDAdatanew.Xcoast(idNEAREST+8);
YA = MDAdatanew.Ycoast(idNEAREST+8);
% Ray 2 GRO lengths from GRO
distC = abs(s1+2*S.userinput.groyne(ii).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
idC = find(distC==min(distC));
XC = MDAdatanew.Xcoast(idC);
YC = MDAdatanew.Ycoast(idC);
% Ray 1 GRO length from GRO
equiB = mod(RAY.equi-angleB,360);
distB = abs(s1+S.userinput.groyne(ii).length-distXY(MDAdatanew.Xcoast,MDAdatanew.Ycoast));
idB = find(distB==min(distB));
XB = MDAdatanew.Xcoast(idB);
YB = MDAdatanew.Ycoast(idB);


%% Summarize
XY = [XA YA; XB YB; XC YC];
nameA = [RAYfilename{1}(2:end-1) 'A.RAY'];
nameB = [RAYfilename{1}(2:end-1) 'B.RAY'];
nameC = [RAYfilename{1}(2:end-1) 'C.RAY'];
names = {nameA(1:end-4),nameB(1:end-4),nameC(1:end-4)};

%% Write RAY files
RAY.path = {S.settings.outputdir};
RAY.name = {nameC};
ITHK_io_writeRAY(RAY);
RAY.name = {nameA};
RAY.equi = equiA;
ITHK_io_writeRAY(RAY);
RAY.name = {nameB};
RAY.equi = equiB;
ITHK_io_writeRAY(RAY);


%% GROdata
Ngroynes = length(GROdata);
GROdata(Ngroynes+1).Xw = Xw;
GROdata(Ngroynes+1).Yw = Yw;
GROdata(Ngroynes+1).Length = S.userinput.groyne(ii).length;%0.2*Length; %Because length is not accurately represented in UNIBEST
GROdata(Ngroynes+1).BlockPerc = 100;
GROdata(Ngroynes+1).Yreference = 0;
GROdata(Ngroynes+1).option = 'right';
GROdata(Ngroynes+1).xyl = [];
GROdata(Ngroynes+1).ray_file1 = [];
GROdata(Ngroynes+1).xyr = XY;
GROdata(Ngroynes+1).ray_file2 = names;
ITHK_io_writeGRO([S.settings.outputdir S.userinput.groyne(ii).filename],GROdata);
S.UB.input(sens).groyne(ii).GROdata = GROdata;
S.UB.input(sens).groyne(ii).Ngroynes = length(GROdata)-4;
S.UB.input(sens).groyne(ii).rayfiles = {nameA,nameB,nameC};

%% Function find grid in range
function [idNEAREST,idRANGE]=findGRIDinrange(Xcoast,Ycoast,x,y,radius)
    dist2 = ((Xcoast-x).^2 + (Ycoast-y).^2).^0.5;
    idNEAREST  = find(dist2==min(dist2));
    dist3 = ((Xcoast-Xcoast(idNEAREST)).^2 + (Ycoast-Ycoast(idNEAREST)).^2).^0.5;
    idRANGE  = find(dist3<radius);
end
end