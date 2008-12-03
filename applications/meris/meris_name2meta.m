function varargout = meris_name2meta(name),
%MERIS_NAME2META  retrieves meta-information from MERIS filename.
%
% D = MERIS_NAME2META(filename) where D is a struct
%
% See MERIS product handbook section 2.2.1.
% <http://envisat.esa.int/handbooks/meris/>
%
%See also: MERIS_MASK, MERIS_FLAGS, READNOAAPC

%   --------------------------------------------------------------------
%   Copyright (C) 2008 May Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------


%%  meris.ProductHandbook.2_0.pdf page 39 excerpt
%%  ---------------------------------------------------------------------------------- 
%%  2.2 Organisation of Products
%%
%%     2.2.1 File naming convention
%%
%%        2.2.1.1 Product identification scheme
%%
%%        As detailed in the “Envisat-1 Products Specifications - Volume 4 – Product overview” document (R-6),
%%        MERIS products are identified according to the following syntax:
%%
%%        MER_XXX_YZ
%%
%%        where
%%
%%        * XXX is the mode (when relevant) or contains letters used to differentiate between
%%              several products created at the same processing level (e.g., several Level 2
%%              products. Unused letters are replaced by underscore characters. These codes
%%              are instrument specific.
%%        * Y   is the product level code:
%%              - 0: Level 0,
%%              - 1: Level 1B,
%%              - 2: Level 2,
%%              - B: Browse
%%        * Z   indicates whether the product is a Parent (also called segment for MERIS
%%              acquisition) or Child (extracted) product:
%%              - P : Parent Product
%%              - C : Child Product
%%
%%        As listed below, all the MERIS products obey the above syntax.
%%
%%        Table 2.2 - MERIS product names.
%%
%%        MER_CA__0P MERIS Level 0 Calibration (all calibration modes)
%%        MER_RR__0P MERIS Level 0 Reduced Resolution
%%        MER_RR__1P Reduced Resolution Geolocated and Calibrated TOA Radiance (stripline)
%%        MER_RR__2P Reduced Resolution Geophysical Product for Ocean, Land and Atmosphere
%%                   (stripline)
%%        MER_LRC_2P Extracted Cloud Thickness and Water Vapour for Meteo users. Level 2 Product
%%                   generated from MER_RR__2P (Cloud thickness and water vapour content for the
%%                   Meteo at reduced resolution > 5 km) (stripline)
%%        MER_RRC_2P Extracted Cloud Thickness and Water Vapour (non-Meteo users). Level 2 product
%%                   extracted from MER_RR__2P (Cloud thickness and water vapour content at nominal
%%                   RR resolution) for NRT distribution (stripline)
%%        MER_RRV_2P Extracted Vegetation Indices. Level 2 product extracted from MER_RR__2P
%%                   (Vegetation indices including atmospheric corrections for selected land regions) for
%%                   NRT distribution (stripline)
%%        MER_RR__BP Browse (covers FR and RR requirements) (stripline)
%%        MER_FR__0P MERIS Level 0 Full Resolution
%%        MER_FR__1P Full Resolution Geolocated and Calibrated TOA Radiance
%%        MER_FR__2P Full Resolution Geophysical Product for Ocean, Land
%%
%%        2.2.1.2 Acquisition identification scheme
%%
%%        As detailed in the “Envisat-1 Products Specifications – Annex A – Product data conventions”
%%        document (R-9), the second part (see the first part in the section above) of the MERIS product file
%%        names identifies the acquisition context according to the following syntax:
%%
%%        MER_XXX_YZpGGGyyyymmdd_HHMMSS_ttttttttPccc_OOOOO_aaaaa_QQQQ.SS
%%
%% GJdB   000000000 111111111 222222222 333333333 444444444 555555555 666666666 777777777 888888888 9999
%% GjdB   123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234 
%%
%%        Example : 
%%        MER_FR__1PNUPA20030921_092217_000000982020_00079_08149_0354.N1
%% GJdB   MER_RR__2CQACR20030808_103132_000026322018_00452_07520_0000_hydropt_optimizedSIOP_MEGS74TSMNew.*
%%
%%        where
%%
%%        * p   is processing stage flag :
%%              - N: Near Real Time product,
%%              - V : fully validated (consolidated) product,
%%              - T : test product,
%%              - S : special product.
%%        * GGG identifies the center which generated the file:
%%              - PDK = PDHS-K
%%              - PDE = PDHS-E
%%              - IEC = IECF
%%              - LRA = LRAC
%%              - PDC = PDCC
%%              - FOS = FOS-ES
%%              - PDA = PDAS-F
%%              - PAM = Matera for NRT production
%%              - UPA = UK-PAC
%%              - DPA = D-PAC
%%              - IPA = I-PAC
%%              - FPA = F-PAC
%%              - SPA = S-PAC
%%              - EPA = E-PAC
%%              - ECM = ECMWF
%%              - ACR = ACRI
%%              - FIN = FINPAC
%%        * yyyymmdd  is the start day of the acquisition,
%%        * HHMMSS    is the start time of the acquisition,
%%        * tttttttt  is the duration (in seconds) of the acquisition,
%%        * P         identifies the phase of the mission,
%%        * ccc       is the number of the cycle in the mission phase_,
%%        * OOOOO     is the relative orbit number within the cycle,
%%        * aaaaa     is the absolute orbit number,
%%        * QQQQ      is a numerical wrap-around counter for quick file identification. For a given
%%                    product type the counter is incremented by 1 for each new product generated by
%%                    the product originator.
%%        * SS identifies the satellite (E1 = ERS-1, E2 = ERS-2, N1 = ENVISAT-1).
%%  ---------------------------------------------------------------------------------- 

%% 2.2.1.1 Product identification scheme
%% --------------------------------------------

   DAT.filename                = name;
   DAT.sensor                  = name( 1: 3);% MER

   DAT.product                 = name( 5: 7);% XXX
   
   DAT.product                 = strrep(DAT.product,'_','');

   DAT.product_level           = name( 9: 9);% Y
   DAT.parent_child            = name(10:10);% Z

%% 2.2.1.2 Acquisition identification scheme
%% --------------------------------------------

   DAT.processing_stage_flag   = name(11:11); % p
   DAT.center                  = name(12:14); % GGG

   DAT.timezone                = 'UTC';

   DAT.start_day               = name(15:22); % yyyymmdd
   
   DAT.start_time              = name(24:29); % HHMMSS
   
   DAT.duration_in_seconds     = str2num(name(31:38)); % tttttttt
   
   DAT.datenum                 = datenum([DAT.start_day, DAT.start_time],'yyyymmddHHMMSS');
   DAT.datenum(2)              = DAT.datenum(1) + DAT.duration_in_seconds./3600./24;

   DAT.mission_phase           = str2num(name(39:39)); % P
   DAT.cycle_number            = str2num(name(40:42)); % ccc

   DAT.relative_orbit_number   = str2num(name(44:48)); % OOOOO

   DAT.absolute_orbit_number   = str2num(name(50:54)); % aaaaa

   DAT.counter                 = str2num(name(56:59)); % QQQQ

%% Place
%% --------------------------------------------

   DAT.coordinate_system       = 'geographic';
   DAT.coordinate_units        = 'deg';
   DAT.geoid                   = 'WGS84';

%% Processing type
%% Not quite waterproof, because storing meta-info in filename is not a professional approach.
%% --------------------------------------------

if length(name) > 60
   DAT.satellite               = name(61:62); % SS

   if strcmp(DAT.satellite,'E1') || ...
      strcmp(DAT.satellite,'E2') || ...
      strcmp(DAT.satellite,'N1')
   
      DAT.algorithm            = '?';

   else   
   
      DAT.satellite            = '?';
      DAT.algorithm            = filename(name(60:end)); % remove extension
   
   end
end

if nargout==1
   varargout = {DAT};
%elseif nargout==2
%   varargout = {DAT,INFO};
end

%% EOF