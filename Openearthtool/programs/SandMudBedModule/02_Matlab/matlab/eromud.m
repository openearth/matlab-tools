function [sink, sour, sinkf, sourf ] = eromud(ws       , fixfac    , taub      , frac      , fracf     , ...
                 tcrdep   , tcrero    , eropar    , flufflyr  , mflufftot , ...
                 tcrfluff , depeff    , depfac    , parfluff0 , parfluff1  )
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
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/eromud.m $
%   $Id: eromud.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
%    Function: Computes sediment fluxes at the bed using
%              the Pariades-Krone formulations.
%
%% executable statements -------------------------------------------------------
%
    sour    = 0.0;
    sourf   = 0.0;
    sink    = 0.0;
    sinkf   = 0.0;
    %
    % Default Pariades-Krone formula
    %
    taum = 0.0;
    if (tcrero>0.0) 
        taum = max(0.0, taub/tcrero - 1.0);
    end
    sour = eropar * taum;
    if (tcrdep > 0.0) 
        sink = max(0.0 , 1.0-taub/tcrdep);
    end
    %
    % Erosion and deposition to fluff layer
    %
    if (flufflyr>0) 
        taum    = max(0.0, taub - tcrfluff);
        sourf   = min(mflufftot*parfluff1,parfluff0)*taum;
        sinkf   = depeff;
        sink    = 0.0;
    end
    if (flufflyr==2) 
        sinkf   = (1.0 - depfac)*sinkf;
        sink    = depeff*depfac;
    end
    %
    %   Sediment source and sink fluxes
    %
    sink    = ws * sink;
    sinkf   = ws * sinkf;
    sour    = fixfac * frac  * sour;
    sourf   =          fracf * sourf ;         
    %
end 
