function handles=ddb_dnami_compEQpar(handles)
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
% global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc    foption
% global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch
% global dip       strike      slip       fdepth    userfaultL  tolFlength
% global nseg      faultX      faultY     faultTotL xvrt        yvrt
% global mu        raddeg      degrad     rearth
%global Areaeq

%


L1  = 0;
L2  = 0;
fact= 1;
fw1 = 0.0;
fw2 = 0.0;

Areaeq = 4;

Mw=handles.Toolbox(tb).Input.Magnitude;
mu=30.0e9;

%
%       Options to detrmine the fault area, names below refers to the authors
%         1 = Ward 2004; 
%         2 = Coopersmith / Wells 1994 [Dreger 1999]; 
%         3 = average (Jef);
%         4 = Max. Length and Max width from options 1 & 2
%

if (Mw > 5)
    Mo = 10.0^(1.5*Mw+9.05);
    disloc = 0.02*10.0^(0.5*Mw-1.8); % dslip in meters
    if (Areaeq == 1)
        totflength  = 10.0^(0.5*Mw-1.8);
        mu1         = mu * 1.66666;
        area        = Mo/(mu1*disloc)/1000000.;
        fwidth      = area/totflength;
    elseif (Areaeq == 2 )
        totflength = 10^(-2.44+0.59*Mw);
        area       = 10^(-3.49+0.91*Mw);
        fwidth     = area/totflength;
    elseif (Areaeq == 3)
        L1  = 10.0^(0.5*Mw-1.8);
        mu1 = mu * 1.66666;
        area= Mo/(mu1*disloc)/1000000.0;
        fw1 = area/L1;
        L2    = 10^(-2.44+0.59*Mw);
        area2 = 10^(-3.49+0.91*Mw);
        fw2   = area2/L2;
        totflength = 0.5*(L1+L2);
        fwidth = 0.5*(fw1 + fw2);
    elseif (Areaeq == 4)
        totflength = 10^(-2.44+0.59*Mw);
        area       = Mo/(mu*disloc)/1000000.0;
        fwidth     = area/totflength;
    end

    handles.Toolbox(tb).Input.TotalFaultLength=totflength;
    handles.Toolbox(tb).Input.FaultWidth=fwidth;
    handles.Toolbox(tb).Input.Dislocation=disloc;
else
    handles.Toolbox(tb).Input.Mw=0.0;
    handles.Toolbox(tb).Input.TotalFaultLength=0;
    handles.Toolbox(tb).Input.FaultWidth=0;
    handles.Toolbox(tb).Input.Dislocation=0;
end
