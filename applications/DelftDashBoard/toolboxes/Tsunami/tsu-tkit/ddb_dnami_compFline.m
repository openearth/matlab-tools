function ddb_dnami_compFline()
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_dnami_compFline.m
% Version:      Version 1.0, March 2007
% By:           Deepak Vatvani
% Summary:
%
% Copyright (c) WL|Delft Hydraulics 2007 FOR INTERNAL USE ONLY
%
% ------------------------------------------------------------------------------------
%
% Syntax:       output = function(input)
%
% With:
%               variable description
%
% Output:       Output description
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth    disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch  mrkrpatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%

if (nseg >= 1)
   for i=1:nseg
      lon1 = faultX(i)*degrad ;
      lon2 = faultX(i+1)*degrad;
      lat1 = faultY(i)*degrad  ;
      lat2 = faultY(i+1)*degrad;
      bring= atan2(sin(lon2-lon1)*cos(lat2), .....
                   cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
      dist = sqrt((sin((lat2-lat1)/2.)*sin((lat2-lat1)/2.))+ ........
            (cos(lat1)*cos(lat2)*(sin((lon2-lon1)/2.)*sin((lon2-lon1)/2.))));
      strike(i)= mod(bring,2*pi)*raddeg;
      userfaultL(i)=2.*asin(dist)*rearth/1000.;
   end
   for i=nseg+1:5
      strike(i)=0;
      userfaultL(i)=0;
   end

   ddb_dnami_comp_Farea();
   faultTotL  = sum(userfaultL);
end
