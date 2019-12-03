function shld = shield(dstar     )
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
%   $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/programs/SandMudBedModule/02_Matlab/matlab/shield.m $
%   $Id: shield.m 7697 2012-11-16 14:10:17Z boer_aj $
%%--description-----------------------------------------------------------------
%
% determines shields parameter according
% to shields curve
%
%% executable statements -------------------------------------------------------
%
    if (dstar<=4.) 
       shld = 0.240/dstar;
    elseif (dstar<=10.) 
       shld = 0.140/dstar^0.64;
    elseif (dstar<=20.) 
       shld = 0.040/dstar^0.10;
    elseif (dstar<=150.) 
       shld = 0.013*dstar^0.29;
    else
       shld = 0.055;
    end
end
