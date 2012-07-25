function segnr = delwaq_xy2segnr(lgaFile,x,y,type)
%DELWAQ_XY2SEGNR Read Delwaq LGA files and gives back corresponding segment
%   number for x and y coordenates
%
%   SEGNR = DELWAQ_XY2SEGNR(LGAFILE,X,Y,TYPE)
%
%   SEGNR = DELWAQ_XY2SEGNR(...,TYPE)
%   TYPE = 'LL' for lat lon coordenates
%   If TYPE is not provided then TYPE = 'XY'
%
%   See also: DELWAQ, DELWAQ_CONC, DELWAQ_RES, DELWAQ_TIME, DELWAQ_STAT, 
%             DELWAQ_INTERSECT

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------

x = x(:);
y = y(:);
if nargin<4
    type = 'XY';
end
    
if strcmp(type,'LL')
  [x, y] =  convertCoordinates(x,y,'CS1.code',4326,'CS2.code',28992);
end

gridStruct = delwaq('open',lgaFile);
[Xcen Ycen] = corner2center(gridStruct.X,gridStruct.Y);
segnr  = naninterp(Xcen,Ycen,gridStruct.Index(2:end,2:end,1),x,y,'nearest');

inot = (segnr<=0);
segnr(inot) = nan;

