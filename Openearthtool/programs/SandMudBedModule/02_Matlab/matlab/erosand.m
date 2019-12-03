function [sour, sink ] = erosand(umod     , chezy    , ws    , rsedeq  )
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
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/erosand.m $
%   $Id: erosand.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
%    Function: Computes the sour and sink terms for the 2D case
%              (Gallappatti aproach)
%
%% executable statements -------------------------------------------------------
%
    eps     = 0;
    sg      = sqrt(9.81);
    %    
    sour = 0.0;
    sink    = 0.0;
    %
    % local bed shear stress due to currents
    %
    ustarc  = umod*sg/chezy;
    %
    wsl = max(1.0e-3,ws);
    if (umod > eps && ustarc > eps) 
        %
        % compute relaxation time using the Gallappatti formulations
        %
        u = ustarc/umod;
        %
        % limit u to prevent overflow in tsd below
        %
        u = min(u, 0.15);
        if (ustarc > wsl) 
            w = wsl/ustarc;
        else
            w = 1.0;
        end
        b    = 1.0;
        x    = w/b;
        x2   = x*x;
        x3   = x2*x;
        ulog = log(u);
        tsd  = x*exp((  1.547           - 20.12*u )*x3 ...
                + (326.832 *u^2.2047 -  0.2   )*x2 ...
                + (  0.1385*ulog      -  6.4061)*x  ...
                + (  0.5467*u         +  2.1963) );
        %
        hots = wsl/tsd;        
        sour = rsedeq*hots;
        sink = hots;
    else
        sink = wsl;
    end
end 

%