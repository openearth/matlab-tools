function varargout = getellipsoid(ell);
%GETELLIPSOID   Get properties of ellipsoides describing flattening on the earth.
%
% [a,e] = getellipsoid(name)
% [a e] = getellipsoid(name)
%
% where
% a         semi-major axis of ellipsoid
% e         excentricity of ellipsoid
%
% and name is one of:
%
% * 'hayford'
% * 'bessel'
% * 'wgs84'
% * 'clarke1880'
% * 'india1830'
% * 'international'
% * 'ed50' = 'international'
% * 'sa69' = 'south america 1969'
%
% and feel free to add more ellipsis...
%
% useful equations:
%
%  f = 1 - sqrt(1 - e.^2);
%  e = sqrt(2*f-f.^2);
% 
% See also: ALMANAC (from Matlab mapping toolbox)

   switch(lower(ell))
   case 'hayford'
       a = 6378388.0  ;e = 0.081992;
   case  'bessel'
       a = 6377397.0  ;e = 0.081690;
   case 'wgs84'
       a = 6378137.0  ;e = 0.081819;
   case  'clarke1880'
       a = 6378249.0  ;e = 0.082478;
   case  'india1830'
       a = 6377276.345;e = 0.081473;
   case 'international'
      % almanac('earth','international')
       a = 6.378388000000000e+006;
       e = 8.199188997902977e-002;
       f = 1 - sqrt(1 - e.^2);
   case 'ed50'
      [a,e] = getellipsoid('international');     
   case 'south america 1969'
       % http://www.colorado.edu/geography/gcraft/notes/datum/edlist.html
       a = 6378160;
       f = 1/298.25;
       e = sqrt(2*f-f.^2);
   case 'sa69'
       [a,e] = getellipsoid('south america 1969');     
   otherwise
      error('Ellipsoide not correct');
   end

   if nargout==1
       varargout = {[a e]};
   elseif nargout==2
       varargout = {a,e};
   end
      
%% EOF      