function [sbot, ssus] = vanRijn84(utot      ,d50       ,d90       ,h         ,ws       , ...
                    rhosol    ,alf1      ,rksc       ,smfac     )
%----- LGPL --------------------------------------------------------------------
%                                                                               
%   Copyright (C) 2011-2012 Stichting Deltares.                                     
%                                                                               
%   This library is free software; you can redistribute it and/or                
%   modify it under the terms of the GNU Lesser General Public                   
%   License as published by the Free Software Foundation version 2.1.                         
%                                                                               
%   This library is distributed in the hope that it will be useful,              
%   but WITHOUT ANY WARRANTY; without even the implied warranty of               
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU            
%   Lesser General Public License for more details.                              
%                                                                               
%   You should have received a copy of the GNU Lesser General Public             
%   License along with this library; if not, see <http://www.gnu.org/licenses/>. 
%                                                                               
%   contact: delft3d.support@deltares.nl                                         
%   Stichting Deltares                                                           
%   P.O. Box 177                                                                 
%   2600 MH Delft, The Netherlands                                               
%                                                                               
%   All indications and logos of, and references to, "Delft3D" and "Deltares"    
%   are registered trademarks of Stichting Deltares, and remain the property of  
%   Stichting Deltares. All rights reserved.                                     
%                                                                               
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/vanRijn84.m $
%   $Id: vanRijn84.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
% computes sediment transport according to
% van rijn (1984)
%
%% executable statements -------------------------------------------------------
%
    sbot = 0.0;
    ssus = 0.0;
    %
    ag      = 9.81;
    rhowat  = 1000.0;
    del     = (rhosol - rhowat) / rhowat;
    rnu     = 1e-6;
    vonkar  = 0.41;
    %
    if (h/rksc<1.33 || utot<1.E-3) 
       return
    end
    %
    a = rksc;
    dstar = d50*(del*ag/rnu/rnu)^(1./3.);
    %
    rmuc = (log10(12.*h/rksc)/log10(12.*h/3./d90))^2;
    fc = .24*(log10(12.*h/rksc))^( - 2);
    tbc = .125*rhowat*fc*utot^2;
    tbce = rmuc*tbc;
    thetcr = shield(dstar);
    tbcr = (rhosol - rhowat)*ag*d50*thetcr*smfac;
    t = (tbce - tbcr)/tbcr;
    %
    if (t<.000001) 
        t = .000001;
    end
    ca = .015*alf1*d50/a*t^1.5/dstar^.3;
    %
    ustar = sqrt(.125*fc)*utot;
    zc = 0.;
    beta = 1. + 2.*(ws/ustar)^2;
    beta = min(beta, 1.5);
    psi = 2.5*(ws/ustar)^0.8*(ca/0.65)^0.4;
    if (ustar>0.) 
        zc = ws/vonkar/ustar/beta + psi;
    end
    if (zc>20.) 
        zc = 20.;
    end
    ah = a/h;
    if (abs(zc - 1.2)>1.E-4) 
       fc = (ah^zc - ah^1.2)/(1. - ah)^zc/(1.2 - zc);
    else
       fc = -(ah/(1. - ah))^1.2*log(ah);
    end
    ff = fc;
    ssus = ff*utot*h*ca;
    %
    if (t<3.) 
       sbot = 0.053*(del)^0.5*sqrt(ag)*d50^1.5*dstar^( - 0.3)*t^2.1;
    else
       sbot = 0.100*(del)^0.5*sqrt(ag)*d50^1.5*dstar^( - 0.3)*t^1.5;
    end
end 
