function ddb_dnami_compEQpar()
%
% ------------------------------------------------------------------------------------
%
%
% Function:     ddb_dnami_compEQpar.m
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
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%global Areaeq

%
L1  = 0;
L2  = 0;
fact= 1;
fw1 = 0.;
fw2 = 0.;

Areaeq = str2num(getINIValue('DTT_config.txt','Area_eq'));
if isempty(Areaeq) | Areaeq<=0 | Areaeq >4
    Areaeq = 3;
end    

mwstr = get(gcbo,'string');
if (~isempty(mwstr))
   Mw = str2num(mwstr);
   if (Mw > 5)
     Mo = 10.^(1.5*Mw+9.05);
     disloc = 0.02*10.^(0.5*Mw-1.8); % dslip in meters

      if (Areaeq == 1)
         totflength  = 10.^(0.5*Mw-1.8);
         mu1         = mu * 1.66666;
         area        = Mo/(mu1*disloc)/1000000.;
         fwidth      = area /totflength;
      elseif (Areaeq == 2 )
         totflength = 10^(-2.44+0.59*Mw);
         area       = 10^(-3.49+0.91*Mw);
         fwidth     = area/totflength; 
      elseif (Areaeq == 3)
         L1  = 10.^(0.5*Mw-1.8);
         mu1 = mu * 1.66666;
         area= Mo/(mu1*disloc)/1000000.;
         fw1 = area /L1;
         L2    = 10^(-2.44+0.59*Mw);
         area2 = 10^(-3.49+0.91*Mw);
         fw2   = area2/L2; 
         totflength = 0.5*(L1+L2);
         fwidth = 0.5*(fw1 + fw2);
      elseif (Areaeq == 4)
         totflength = 10^(-2.44+0.59*Mw);
         area       = Mo/(mu*disloc)/1000000.;
         fwidth     = area/totflength;
      end

      nseg   = max(nseg,1);
      for i=1:nseg
         fdepth(i) = 0.5*fwidth*sin(dip(i)*degrad) + fdtop;
      end
   else
      Mw = 0
   end
   ddb_dnami_setValues()
end
