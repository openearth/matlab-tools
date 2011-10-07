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

x = x(:);
y = y(:);
if nargin<4
    type = 'XY';
end
    
if strcmp(type,'LL')
  [x  y] = ctransdv(x,y,'LL','PAR'); 
end

gridStruct = delwaq('open',lgaFile);
[Xcen Ycen] = corner2center(gridStruct.X,gridStruct.Y);
 segnr  = naninterp2(Xcen,Ycen,gridStruct.Index(1:end-1,1:end-1,1),x,y,'nearest');
% segnr  = naninterp2(gridStruct.X,gridStruct.Y,gridStruct.Index(:,:,1),x,y,'nearest');

inot = (segnr<=0);
segnr(inot) = nan;

