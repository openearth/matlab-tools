function output = readCFS(filename)
%read CFS : Reads a unibest transport parameter file
%
%   Syntax:
%     function readCFS(filename)
% 
%   Input:
%     filename              string with filename
%     
%     Parameters for Bijker formula:
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       rc                   Bottom roughness (m)
%       wval                 Sediment fall velocity (m/s)
%       crit_d               Criterion deep water, Hsig/h (-)
%       b_d1                 Coefficient b deep water (-)
%       crit_s               Criterion shallow water, Hsig/h (-)
%       b_d2                 Coefficient b shallow water (-)
%     
%     Parameters for Van Rijn formula:
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       rho                  Sediment density (kg/m3)
%       rc                   Current related bottom roughness (m)
%       rw                   Wave related bottom roughness (m)
%       wval                 Sediment fall velocity (m/s)
%       visc                 Viscosity []*10e-6
%       alfa                 Correction factor (-)
%       A                    Relative bottom transport layer thickness (-)
%       por                  Porosity (-)
%     
%     Parameters for GRA formula:
%       Dn50                 Dn50 nominal diameter (m)
%       R                    Roughness length (m)
%       rho                  Density of material (kg/m3)
%       shields              Shields number (-)
%       n                    Multiplication factor (-)
%     
%     Parameters for CERC formula:
%       A                    Coefficient A (-)
%       gamma                Wave breaking coefficient gamma (-)
%
%  Please resort to the manual as more formulas are encorporated, these
%  are all supported by this script, though their variables might not be
%  mentioned here in the help..
%  
%   Output:
%     data structure for cfs file containing variables, their values and
%     selected transport formula
%
%   Example:
%     readCFS('test.cfs')
%
%   This script was not tested much, please contact me including the CFS
%   file if errors arise
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       freek.scheel@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.


%-----------Read data to structure----------
%-------------------------------------------

fid = fopen(filename,'rt');

transp_formula = strrep(fgetl(fid),' ','');

line2 = fgetl(fid);

values = str2num(fgetl(fid));

inds = find((double(line2)~=32)==1);

start_inds = [1 (find(diff(inds)~=1)+1) size(inds,2)];

for ii=1:(size(start_inds,2)-1)
    names{ii,1} = strrep(line2(inds(start_inds(ii)):(inds(start_inds(ii+1)-1))),'.','');
    eval(['output.' names{ii,1} ' = values(1,ii);']);
    if ii==1
        output.TRANSPORT_FORMULA = strrep(transp_formula,'''','');
    end
end

fclose(fid);
