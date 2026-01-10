
function d3dgridexample()
% D3DGRIDEXAMPLE - Recreates the physical domain from Booij (2003)
%
% syntax: d3dgridexample
%
% Booij R. 2003 - Measurements and large-eddy simulations of turbulence, J.
% Turbulence Vol. 4. p.1-17.
%
% 
% See also d3dmakestraightgrid, d3dmakecurvedgrid, d3dplotgrid, wlgrid  
%
% -------------------------------------------------------------------------
%  Copyright (C) 2008 Delft University of Technology
%    Faculty of Civil Engineering and Geosciences
%    Willem Ottevanger  (email: w.ottevanger@tudelft.nl)
%    Version 0.2 (11-08-08)
% -------------------------------------------------------------------------


B = 50;
R = 200;
ang = 360;
m = 5;
file='doughnut.grd';
enc =[];
grd  = d3dmakecurvedgrid  (B,R,ang,m,round(ang/180*pi*R/B*m));
[grd2] = d3dtranslategrid(grd,-0.5*(min(grd.X(:))+max(grd.X(:))),...
                              -0.5*(min(grd.Y(:))+max(grd.Y(:))));

try
   ok=wlgrid('write','FileName', file, 'X', grd2.X,'Y', grd2.Y,'Enclosure', enc);
   disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end


[grd] = d3dmakestraightgrid(2*(R+B),2*(R+B),60,60)
[grd2] = d3dtranslategrid(grd,-0.5*(min(grd.X(:))+max(grd.X(:))),...
                              -0.5*(min(grd.Y(:))+max(grd.Y(:))));

file='meteo60x60.grd'
try
   ok=wlgrid('write','FileName', file, 'X', grd2.X,'Y', grd2.Y,'Enclosure', enc);
   disp(['Gridfile written to ',file]) 
catch
   error('Function wlgrid could not be accessed')
end
