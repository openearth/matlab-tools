function ldb2kml(ldb,kmlfile,linecolour)
%LDB2KML Converts ldb to kml-file
%
% Reads a landboundary file and save it to a kml-file which can be opened
% in Google Earth.
%
% Syntax:
% ldb2kml(ldb)
%
% ldb:      the landboury, which should already be specified by the 
%           function ldb=landboundary('read','landboundary')
%           (optional)
%
% See also: KML2LDB, LDBTOOL, LDB2SHAPE

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code

if nargin==0
    [nam pat]=uigetfile('*.ldb','Select landboundary file');
    if nam==0
        return
    end
    ldb=landboundary('read',[pat nam]);
    ldb=ldb(:,1:2);
    [fPat fName]=fileparts([pat nam]);
elseif ischar(ldb)
    ldb=landboundary('read',ldb);
    ldb=ldb(:,1:2);
    if nargin<2
        [fName fPat]=uiputfile('*.kml','Save kml-file to...');
    end
else
    [fName fPat]=uiputfile('*.kml','Save kml-file to...');
end
if nargin>1
    [fPat fName]=fileparts(kmlfile);
    if isempty(fPat);fPat=cd;end
end
if nargin>2
    clr = round(linecolour(:).*255);
else
    clr=str2num(char(inputdlg({'Red','Green','Blue'},'Specify RGB color',1,{'255','0','0'})));
end
if isempty(clr)
    clrString='ffff0000';
end
clr=[min(255,clr(1)); min(255,clr(2)); min(255,clr(3))];
clr=[max(0,clr(1)); max(0,clr(2)); max(0,clr(3))];

fid=fopen([fPat filesep fName '.kml'],'w');

fprintf(fid,'%s \n','<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'%s \n','<!--x=x+                  -->');
fprintf(fid,'%s \n','<!--y=y+                  -->');
fprintf(fid,'%s \n','<kml xmlns="http://earth.google.com/kml/2.1">');
fprintf(fid,'%s \n','<Document>');
fprintf(fid,'%s \n',['	<name>' fName '</name>']);
fprintf(fid,'%s \n','	<Style id="style_1">');
fprintf(fid,'%s \n','		<LineStyle>');
fprintf(fid,'%s \n',['			<color>FF' dec2hex(clr(3),2) dec2hex(clr(2),2) dec2hex(clr(1),2) '</color>']);
fprintf(fid,'%s \n','		</LineStyle>');
fprintf(fid,'%s \n','		<PolyStyle>');
fprintf(fid,'%s \n','			<fill>0</fill>');
fprintf(fid,'%s \n','		</PolyStyle>');
fprintf(fid,'%s \n','	</Style>');

if ~isnan(ldb(1,1))
    ldb=[nan nan;ldb];
end
if ~isnan(ldb(end,1))
    ldb=[ldb;nan nan];
end

did=find(isnan(ldb(:,1)));
if ~isempty(did)
    rid=abs(did(1:end-1)-did(2:end));
    remid=find(rid==1);
    ldb(did(remid),:)=[];
end

id=find(isnan(ldb(:,1)));

hW=waitbar(0,'Please wait while writing kml-file...');
for ii=1:length(id)-1
    data=ldb(id(ii)+1:id(ii+1)-1,:);
    fprintf(fid,'%s \n','	<Placemark>');
    fprintf(fid,'%s \n',['		<name>' num2str(ii) '</name>']);
    fprintf(fid,'%s \n','		<styleUrl>style_1</styleUrl>');
    fprintf(fid,'%s \n','		<Polygon>');
    fprintf(fid,'%s \n','			<tessellate>1</tessellate>');
    fprintf(fid,'%s \n','			<outerBoundaryIs>');
    fprintf(fid,'%s \n','				<LinearRing>');
    fprintf(fid,'%s \n','					<coordinates>');
    for ij=1:size(data,1)
        fprintf(fid,'%s \n',[num2str(data(ij,1),'%15.6f') ',' num2str(data(ij,2),'%15.6f') ' ']);
%        fprintf(fid,'%s \n',[num2str(data(ij,1),'%15.6f') ',' num2str(data(ij,2),'%15.6f') ', 0']);
    end
    fprintf(fid,'%s \n','</coordinates>');
    fprintf(fid,'%s \n','				</LinearRing>');
    fprintf(fid,'%s \n','			</outerBoundaryIs>');
    fprintf(fid,'%s \n','		</Polygon>');
    fprintf(fid,'%s \n','	</Placemark>');
    waitbar(ii/(length(id)-1),hW);
end
close(hW);
fprintf(fid,'%s \n','	</Document>');
fprintf(fid,'%s \n','</kml>');
fclose(fid);