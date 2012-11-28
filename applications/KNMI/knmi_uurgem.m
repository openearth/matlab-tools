function data = knmi_uurgem(uurgem_fname)
% KNMI_UURGEM reads hourly KNMI data from a file downloaded from
% http://www.knmi.nl/klimatologie/uurgegevens/
%
%   Syntax:
%   data = knmi_uurgem(uurgem_fname)
%
%   Input:
%   uurgem_fname  = filename with hourly data (.txt)
%
%   Output:
%   data = struct with hourly data
%
%    DD        = Windrichting (in graden) gemiddeld over de laatste 10 minuten van het afgelopen uur (360=noord, 90=oost, 180=zuid, 270=west, 0=windstil 990=veranderlijk / Mean wind direction (in degrees) during the 10-minute period preceding the time of observation (360=north, 90=east, 180=south, 270=west, 0=calm 990=variable)
%    FH        = Uurgemiddelde windsnelheid (in 0.1 m/s) / Hourly mean wind speed (in 0.1 m/s)
%    FF        = Windsnelheid (in 0.1 m/s) gemiddeld over de laatste 10 minuten van het afgelopen uur / Mean wind speed (in 0.1 m/s) during the 10-minute period preceding the time of observation 
%    FX        = Hoogste windstoot (in 0.1 m/s) over het afgelopen uurvak / Maximum wind gust (in 0.1 m/s) during the hourly division
%    T         = Temperatuur (in 0.1 graden Celsius) op 1.50 m hoogte tijdens de waarneming / Temperature (in 0.1 degrees Celsius) at 1.50 m at the time of observation
%    T10N      = Minimumtemperatuur (in 0.1 graden Celsius) op 10 cm hoogte in de afgelopen 6 uur / Minimum temperature (in 0.1 degrees Celsius) at 0.1 m in the preceding 6-hour period
%    TD        = Dauwpuntstemperatuur (in 0.1 graden Celsius) op 1.50 m hoogte tijdens de waarneming / Dew point temperature (in 0.1 degrees Celsius) at 1.50 m at the time of observation
%    SQ        = Duur van de zonneschijn (in 0.1 uren) per uurvak, berekend uit globale straling  (-1 for <0.05 uur) / Sunshine duration (in 0.1 hour) during the hourly division, calculated from global radiation (-1 for <0.05 hour)
%    Q         = Globale straling (in J/cm2) per uurvak / Global radiation (in J/cm2) during the hourly division
%    DR        = Duur van de neerslag (in 0.1 uur) per uurvak / Precipitation duration (in 0.1 hour) during the hourly division
%    RH        = Uursom van de neerslag (in 0.1 mm) (-1 voor <0.05 mm) / Hourly precipitation amount (in 0.1 mm) (-1 for <0.05 mm)
%    P         = Luchtdruk (in 0.1 hPa) herleid naar zeeniveau, tijdens de waarneming / Air pressure (in 0.1 hPa) reduced to mean sea level, at the time of observation
%    VV        = Horizontaal zicht tijdens de waarneming (0=minder dan 100m, 1=100-200m, 2=200-300m,..., 49=4900-5000m, 50=5-6km, 56=6-7km, 57=7-8km, ..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=meer dan 70km) / Horizontal visibility at the time of observation (0=less than 100m, 1=100-200m, 2=200-300m,..., 49=4900-5000m, 50=5-6km, 56=6-7km, 57=7-8km, ..., 79=29-30km, 80=30-35km, 81=35-40km,..., 89=more than 70km)
%    N         = Bewolking (bedekkingsgraad van de bovenlucht in achtsten), tijdens de waarneming (9=bovenlucht onzichtbaar) / Cloud cover (in octants), at the time of observation (9=sky invisible)
%    U         = Relatieve vochtigheid (in procenten) op 1.50 m hoogte tijdens de waarneming / Relative atmospheric humidity (in percents) at 1.50 m at the time of observation    WW        = Weercode (00-99), visueel(WW) of automatisch(WaWa) waargenomen, voor het actuele weer of het weer in het afgelopen uur. Zie http://www.knmi.nl/klimatologie/achtergrondinformatie/ww_lijst_nederlands.pdf / Present weather code (00-99), description for the hourly division. See http://www.knmi.nl/klimatologie/achtergrondinformatie/ww_lijst_engels.pdf
%    IX        = Weercode indicator voor de wijze van waarnemen op een bemand of automatisch station (1=bemand gebruikmakend van code uit visuele waarnemingen, 2,3=bemand en weggelaten (geen belangrijk weersverschijnsel, geen gegevens), 4=automatisch en opgenomen (gebruikmakend van code uit visuele waarnemingen), 5,6=automatisch en weggelaten (geen belangrijk weersverschijnsel, geen gegevens), 7=automatisch gebruikmakend van code uit automatische waarnemingen) / Indicator present weather code (1=manned and recorded (using code from visual observations), 2,3=manned and omitted (no significant weather phenomenon to report, not available), 4=automatically recorded (using code from visual observations), 5,6=automatically omitted (no significant weather phenomenon to report, not available), 7=automatically set (using code from automated observations)
%    M         = Mist 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming / Fog 0=no occurrence, 1=occurred during the preceding hour and/or at the time of observation
%    R         = Regen 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming / Rainfall 0=no occurrence, 1=occurred during the preceding hour and/or at the time of observation
%    S         = Sneeuw 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming / Snow 0=no occurrence, 1=occurred during the preceding hour and/or at the time of observation
%    O         = Onweer 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming / Thunder  0=no occurrence, 1=occurred during the preceding hour and/or at the time of observation    Y         = IJsvorming 0=niet voorgekomen, 1=wel voorgekomen in het voorgaande uur en/of tijdens de waarneming / Ice formation 0=no occurrence, 1=occurred during the preceding hour and/or at the time of observation
%
%   Example
%   uurgem_fname = 'l:\B02047_000031_MER_Vaarweg_Eemshaven\data\uurgem_from_knmi\uurgeg_277_2011-2020.txt';
%   data = KNMI_uurgem(uurgem_fname)
%
%   See also KNMI_POTWIND, KNMI_ETMGEG2NC, KNMI_ETMGEG_GET_URL, KNMI_ETMGEG_STATIONS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

fid = fopen(uurgem_fname);
myformat = repmat('%f ',[1,25]);
C = textscan(fid,myformat,'delimiter',',','headerlines',33);
fclose(fid); 
D = cell2mat(C);
ymd = num2str(D(:,2));
hh = num2str(D(:,3),'%0f');
mydatenum = datenum([ymd,hh],'yyyymmddHH');
datestr(mydatenum(1))

data.datenum = mydatenum;
data.DD = D(:,4);
data.FH = D(:,5);
data.FF = D(:,6);
data.FX = D(:,7);
data.T = D(:,8);
data.T10N = D(:,9);
data.TD = D(:,10);
data.SQ = D(:,11);
data.Q = D(:,12);
data.DR = D(:,13);
data.RH = D(:,14);
data.P = D(:,15);
data.VV = D(:,16);
data.N = D(:,17);
data.U = D(:,18);
data.WW = D(:,19);
data.IX = D(:,20);
data.M = D(:,21);
data.R = D(:,22);
data.S = D(:,23);
data.O = D(:,24);
data.Y = D(:,25);

