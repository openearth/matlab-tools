function E = sand_mud(nfrac, E, frac, mudfrac, sedtyp, pmcrit)
%
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
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/sand_mud.m $
%   $Id: sand_mud.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
%    Function: Computes erosion velocities based
%              on sand-mud interaction (Van Ledden (2003), Van Kessel (2002))
%              Array E is recomputed.
%
%% executable statements -------------------------------------------------------
    %     
    % No sand mud interaction if there is no mud, only mud or pmcrit<0
    if (pmcrit<0.0) 
        return
    end
    if (mudfrac==0.0) 
        return
    end
    if (mudfrac==1.0) 
        return
    end
    %
    Es_avg = 0.0;
    Em_avg = 0.0;
    % 
    % Compute average erosion velocity for sand fractions
    %
    for l = 1:nfrac
        if (sedtyp(l)~= 2) 
            Es_avg = Es_avg + frac(l)*E(l);
        end
    end 
    Es_avg = Es_avg/(1-mudfrac);
    % 
    if ( mudfrac <= pmcrit ) 
        %
        % Non-cohesive regime
        % (mud is proportionally eroded with the sand)
        %
        for l = 1: nfrac
            if (sedtyp(l) == 2) 
                if (Es_avg>0.0)
                    E(l) = Es_avg;
                else
                    E(l) = 0.0;
                end
            end
        end
    else
        %
        % Cohesive regime
        %
        % erosion velocity for mud is interpolated between the non-cohesive and fully mud regime 
        % fully mud regime   : mudfrac = 1       -> E(l) is not changed
        % non-cohesive regime: mudfrac = pmcrit  -> E(l) = Es_avg
        %
        for l = 1: nfrac
            if ( sedtyp(l)==2 )   
                if (Es_avg>0.0 && E(l)>0.0 ) 
                    E(l) = E(l)*(Es_avg/E(l))^((1.0-mudfrac)/(1.0-pmcrit));
                else
                    E(l) = 0.0;
                end
                Em_avg     = Em_avg + frac(l)*E(l);
            end
        end
        Em_avg = Em_avg/mudfrac;
        %
        % sand is proportionally eroded with the mud
        %
        for l = 1: nfrac
            if (sedtyp(l) ~= 2) 
                E(l) = Em_avg;
            end
        end
    end
end

