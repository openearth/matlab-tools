function varargout = swan_quantity
%SWAN_QUANTITY   returns default properties of SWAN output parameters
%
%  DAT       = SWAN_QUANTITY returns properties per parameter
% [DAT,DAT0] = SWAN_QUANTITY returns also properties per property
%
%
%  OVKEYW(IVTYPE) =    keyword used in SWAN command      
%  OVSNAM(IVTYPE) =    short name                        
%  OVLNAM(IVTYPE) =    long name                         
%  OVUNIT(IVTYPE) =    unit name                         
%  OVSVTY(IVTYPE) =    type (scalar/vector etc.)         
%  OVLLIM(IVTYPE) =    lower and upper limit             
%  OVULIM(IVTYPE) =                                      
%  OVLEXP(IVTYPE) =    lowest and highest expected value 
%  OVHEXP(IVTYPE) =                                      
%  OVEXCV(IVTYPE) =    exception value                   
%
%See also: SWAN_INPUT, SWAN_SPECTRUM, SWAN_TABLE, SWAN_DEFAULTS

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

%% Pre-allocate for speed
%% ----------------------

   OVKEYW = cell(1,59);
   OVSNAM = cell(1,59);
   OVLNAM = cell(1,59);
   OVUNIT = cell(1,59);
   OVSVTY = cell(1,59);
   OVLLIM = cell(1,59);
   OVULIM = cell(1,59);
   OVLEXP = cell(1,59);
   OVHEXP = cell(1,59);
   OVEXCV = cell(1,59);

%% Manually edited 3 things from code form SWANMAIN.for below
%% ----------------------
   %% 1
   %OVUNIT{IVTYPE} = UL
   %OVUNIT{IVTYPE} = UH
   %OVUNIT{IVTYPE} = UV
   %OVUNIT{IVTYPE} = UT
   %OVUNIT{IVTYPE} = UDI
   %OVUNIT{IVTYPE} = UF
   %% 2 removed version SWAN numbers
   %% 3 added ; at end of line using regular expressions


%;
      IVTYPE = 1;
      OVKEYW{IVTYPE} = 'XP'                                        ;
      OVSNAM{IVTYPE} = 'Xp';
      OVLNAM{IVTYPE} = 'X user coordinate';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
%;
      IVTYPE = 2;
      OVKEYW{IVTYPE} = 'YP'                                        ;
      OVSNAM{IVTYPE} = 'Yp';
      OVLNAM{IVTYPE} = 'Y user coordinate';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
%;
      IVTYPE = 3;
      OVKEYW{IVTYPE} = 'DIST'                                      ;
      OVSNAM{IVTYPE} = 'Dist';
      OVLNAM{IVTYPE} = 'distance along output curve';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 4;
      OVKEYW{IVTYPE} = 'DEP'                                       ;
      OVSNAM{IVTYPE} = 'Depth';
      OVLNAM{IVTYPE} = 'Depth';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 5;
      OVKEYW{IVTYPE} = 'VEL'                                       ;
      OVSNAM{IVTYPE} = 'Vel';
      OVLNAM{IVTYPE} = 'Current velocity';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -2.;
      OVHEXP{IVTYPE} = 2.;
      OVEXCV{IVTYPE} = 0.;
%;
      IVTYPE = 6;
      OVKEYW{IVTYPE} = 'UBOT'                                      ;
      OVSNAM{IVTYPE} = 'Ubot';
      OVLNAM{IVTYPE} = 'Orbital velocity at the bottom';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -10.;
%;
      IVTYPE = 7;
      OVKEYW{IVTYPE} = 'DISS'                                      ;
      OVSNAM{IVTYPE} = 'Dissip';
      OVLNAM{IVTYPE} = 'Energy dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 8;
      OVKEYW{IVTYPE} = 'QB'                                        ;
      OVSNAM{IVTYPE} = 'Qb';
      OVLNAM{IVTYPE} = 'Fraction breaking waves';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -1.;
%;
      IVTYPE = 9;
      OVKEYW{IVTYPE} = 'LEA'                                       ;
      OVSNAM{IVTYPE} = 'Leak';
      OVLNAM{IVTYPE} = 'Energy leak over spectral boundaries';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 10;
      OVKEYW{IVTYPE} = 'HS'                                        ;
      OVSNAM{IVTYPE} = 'Hsig';
      OVLNAM{IVTYPE} = 'Significant wave height';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = -9.;
%                                                                  ;
      IVTYPE = 11;
      OVKEYW{IVTYPE} = 'TM01'                                      ;
      OVSNAM{IVTYPE} = 'Tm01'                                      ;
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 12;
      OVKEYW{IVTYPE} = 'RTP'                                       ;
      OVSNAM{IVTYPE} = 'RTpeak'                                    ;
      OVLNAM{IVTYPE} = 'Relative peak period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 13;
      OVKEYW{IVTYPE} = 'DIR'                                       ;
      OVSNAM{IVTYPE} = 'Dir';
      OVLNAM{IVTYPE} = 'Average wave direction';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
%;
      IVTYPE = 14;
      OVKEYW{IVTYPE} = 'PDI'                                       ;
      OVSNAM{IVTYPE} = 'PkDir';
      OVLNAM{IVTYPE} = 'direction of the peak of the spectrum';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
%;
      IVTYPE = 15;
      OVKEYW{IVTYPE} = 'TDI'                                       ;
      OVSNAM{IVTYPE} = 'TDir';
      OVLNAM{IVTYPE} = 'direction of the energy transport';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 2;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 360.;
      OVEXCV{IVTYPE} = -999.;
%;
      IVTYPE = 16;
      OVKEYW{IVTYPE} = 'DSPR'                                      ;
      OVSNAM{IVTYPE} = 'Dspr';
      OVLNAM{IVTYPE} = 'directional spreading';
      OVUNIT{IVTYPE} = ' UDI'                                         ;
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 360.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 60.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 17;
      OVKEYW{IVTYPE} = 'WLEN'                                      ;
      OVSNAM{IVTYPE} = 'Wlen';
      OVLNAM{IVTYPE} = 'Average wave length';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 200.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 18;
      OVKEYW{IVTYPE} = 'STEE'                                      ;
      OVSNAM{IVTYPE} = 'Steepn';
      OVLNAM{IVTYPE} = 'Wave steepness';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 19;
      OVKEYW{IVTYPE} = 'TRA'                                       ;
      OVSNAM{IVTYPE} = 'Transp';
      OVLNAM{IVTYPE} = 'Wave energy transport';
      OVUNIT{IVTYPE} = 'm3/s'                                      ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = 0.;
%;
      IVTYPE = 20;
      OVKEYW{IVTYPE} = 'FOR'                                       ;
      OVSNAM{IVTYPE} = 'WForce';
      OVLNAM{IVTYPE} = 'Wave driven force per unit surface';
      OVUNIT{IVTYPE} = 'UF'                                          ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -1.E5;
      OVULIM{IVTYPE} =  1.E5;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = 0.;
%;
      IVTYPE = 21;
      OVKEYW{IVTYPE} = 'AAAA'                                      ;
      OVSNAM{IVTYPE} = 'AcDens';
      OVLNAM{IVTYPE} = 'spectral action density';
      OVUNIT{IVTYPE} = 'm2s';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 22;
      OVKEYW{IVTYPE} = 'EEEE'                                      ;
      OVSNAM{IVTYPE} = 'EnDens';
      OVLNAM{IVTYPE} = 'spectral energy density';
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 23;
      OVKEYW{IVTYPE} = 'AAAA'                                      ;
      OVSNAM{IVTYPE} = 'Aux';
      OVLNAM{IVTYPE} = 'auxiliary variable';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E10;
      OVULIM{IVTYPE} = 1.E10;
      OVLEXP{IVTYPE} = -1.E10;
      OVHEXP{IVTYPE} = 1.E10;
      OVEXCV{IVTYPE} = -1.E10;
%;
      IVTYPE = 24;
      OVKEYW{IVTYPE} = 'XC'                                        ;
      OVSNAM{IVTYPE} = 'Xc';
      OVLNAM{IVTYPE} = 'X computational grid coordinate';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 25;
      OVKEYW{IVTYPE} = 'YC'                                        ;
      OVSNAM{IVTYPE} = 'Yc';
      OVLNAM{IVTYPE} = 'Y computational grid coordinate';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 26;
      OVKEYW{IVTYPE} = 'WIND'                                      ;
      OVSNAM{IVTYPE} = 'Windv';
      OVLNAM{IVTYPE} = 'Wind velocity at 10 m above sea level';
      OVUNIT{IVTYPE} = 'UV'                                          ;
      OVSVTY{IVTYPE} = 3;
      OVLLIM{IVTYPE} = -100.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = -50.;
      OVHEXP{IVTYPE} = 50.;
      OVEXCV{IVTYPE} = 0.;
%;
      IVTYPE = 27;
      OVKEYW{IVTYPE} = 'FRC'                                       ;
      OVSNAM{IVTYPE} = 'FrCoef';
      OVLNAM{IVTYPE} = 'Bottom friction coefficient';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%                                                                  ;
      IVTYPE = 28;
      OVKEYW{IVTYPE} = 'RTM01'                                     ;
      OVSNAM{IVTYPE} = 'RTm01'                                     ;
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 29                                                  ;
      OVKEYW{IVTYPE} = 'EEEE'                                      ;
      OVSNAM{IVTYPE} = 'EnDens';
      OVLNAM{IVTYPE} = 'energy density integrated over direction'  ;
      OVUNIT{IVTYPE} = 'm2';
      OVSVTY{IVTYPE} = 5;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 30                                                  ;
      OVKEYW{IVTYPE} = 'DHS'                                       ;
      OVSNAM{IVTYPE} = 'dHs';
      OVLNAM{IVTYPE} = 'difference in Hs between iterations';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 31                                                  ;
      OVKEYW{IVTYPE} = 'DRTM01'                                    ;
      OVSNAM{IVTYPE} = 'dTm';
      OVLNAM{IVTYPE} = 'difference in Tm between iterations';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 2.;
      OVEXCV{IVTYPE} = -9.;
%                                                                  ;
      IVTYPE = 32;
      OVKEYW{IVTYPE} = 'TM02'                                      ;
      OVSNAM{IVTYPE} = 'Tm02';
      OVLNAM{IVTYPE} = 'Zero-crossing period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%                                                                  ;
      IVTYPE = 33;
      OVKEYW{IVTYPE} = 'FSPR'                                      ;
      OVSNAM{IVTYPE} = 'FSpr'                                      ;
      OVLNAM{IVTYPE} = 'Frequency spectral width {Kappa}';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 34                                                  ;
      OVKEYW{IVTYPE} = 'URMS'                                      ;
      OVSNAM{IVTYPE} = 'Urms';
      OVLNAM{IVTYPE} = 'RMS of orbital velocity at the bottom';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 35                                                  ;
      OVKEYW{IVTYPE} = 'UFRI'                                      ;
      OVSNAM{IVTYPE} = 'Ufric';
      OVLNAM{IVTYPE} = 'Friction velocity';
      OVUNIT{IVTYPE} = 'UV';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 36                                                  ;
      OVKEYW{IVTYPE} = 'ZLEN'                                      ;
      OVSNAM{IVTYPE} = 'Zlen';
      OVLNAM{IVTYPE} = 'Zero velocity thickness of boundary layer';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 37                                                  ;
      OVKEYW{IVTYPE} = 'TAUW'                                      ;
      OVSNAM{IVTYPE} = 'TauW';
      OVLNAM{IVTYPE} = '    ';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 10.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 38                                                  ;
      OVKEYW{IVTYPE} = 'CDRAG'                                     ;
      OVSNAM{IVTYPE} = 'Cdrag';
      OVLNAM{IVTYPE} = 'Drag coefficient';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
%     *** wave-induced setup ***                                   ;
%;
      IVTYPE = 39                                                  ;
      OVKEYW{IVTYPE} = 'SETUP'                                     ;
      OVSNAM{IVTYPE} = 'Setup'                                     ;
      OVLNAM{IVTYPE} = 'Setup due to waves'                        ;
      OVUNIT{IVTYPE} = 'm'                                         ;
      OVSVTY{IVTYPE} = 1                                           ;
      OVLLIM{IVTYPE} = -1.                                         ;
      OVULIM{IVTYPE} = 1.                                          ;
      OVLEXP{IVTYPE} = -1.                                         ;
      OVHEXP{IVTYPE} = 1.                                          ;
      OVEXCV{IVTYPE} = -9.                                         ;
%;
      IVTYPE = 40                                                  ;
      OVKEYW{IVTYPE} = 'TIME'                                      ;
      OVSNAM{IVTYPE} = 'Time';
      OVLNAM{IVTYPE} = 'Date-time';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -99999.;
%;
      IVTYPE = 41                                                  ;
      OVKEYW{IVTYPE} = 'TSEC'                                      ;
      OVSNAM{IVTYPE} = 'Tsec';
      OVLNAM{IVTYPE} = 'Time in seconds from reference time';
      OVUNIT{IVTYPE} = 's';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100000.;
      OVLEXP{IVTYPE} = -100000.;
      OVHEXP{IVTYPE} = 1000000.;
      OVEXCV{IVTYPE} = -99999.;
%                                                               ;
      IVTYPE = 42;
      OVKEYW{IVTYPE} = 'PER'                                       ;
      OVSNAM{IVTYPE} = 'Period'                                    ;
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%                                                               ;
      IVTYPE = 43;
      OVKEYW{IVTYPE} = 'RPER'                                      ;
      OVSNAM{IVTYPE} = 'RPeriod'                                   ;
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 44                                                  ;
      OVKEYW{IVTYPE} = 'HSWE'                                      ;
      OVSNAM{IVTYPE} = 'Hswell';
      OVLNAM{IVTYPE} = 'Wave height of swell part';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 100.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 10.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 45;
      OVKEYW{IVTYPE} = 'URSELL'                                    ;
      OVSNAM{IVTYPE} = 'Ursell';
      OVLNAM{IVTYPE} = 'Ursell number';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 46;
      OVKEYW{IVTYPE} = 'ASTD'                                      ;
      OVSNAM{IVTYPE} = 'ASTD';
      OVLNAM{IVTYPE} = 'Air-Sea temperature difference';
      OVUNIT{IVTYPE} = 'K';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -50.;
      OVULIM{IVTYPE} =  50.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 47                                                  ;
      OVKEYW{IVTYPE} = 'TMM10';
      OVSNAM{IVTYPE} = 'Tm_10';
      OVLNAM{IVTYPE} = 'Average absolute wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 48                                                  ;
      OVKEYW{IVTYPE} = 'RTMM10';
      OVSNAM{IVTYPE} = 'RTm_10';
      OVLNAM{IVTYPE} = 'Average relative wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 49;
      OVKEYW{IVTYPE} = 'DIFPAR'                                    ;
      OVSNAM{IVTYPE} = 'DifPar';
      OVLNAM{IVTYPE} = 'Diffraction parameter';
      OVUNIT{IVTYPE} = ' ';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -50.;
      OVULIM{IVTYPE} =  50.;
      OVLEXP{IVTYPE} = -10.;
      OVHEXP{IVTYPE} =  10.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 50                                                  ;
      OVKEYW{IVTYPE} = 'TMBOT';
      OVSNAM{IVTYPE} = 'TmBot';
      OVLNAM{IVTYPE} = 'Bottom wave period';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 51                                                  ;
      OVKEYW{IVTYPE} = 'WATL';
      OVSNAM{IVTYPE} = 'Watlev';
      OVLNAM{IVTYPE} = 'Water level';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 52                                                  ;
      OVKEYW{IVTYPE} = 'BOTL';
      OVSNAM{IVTYPE} = 'Botlev';
      OVLNAM{IVTYPE} = 'Bottom level';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = -1.E4;
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = -100.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;
%;
      IVTYPE = 53                                                  ;
      OVKEYW{IVTYPE} = 'TPS';
      OVSNAM{IVTYPE} = 'TPsmoo';
      OVLNAM{IVTYPE} = 'Relative peak period {smooth}';
      OVUNIT{IVTYPE} = 'UT';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 54;
      OVKEYW{IVTYPE} = 'DISB'                                      ;
      OVSNAM{IVTYPE} = 'Disbot';
      OVLNAM{IVTYPE} = 'Bottom friction dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 55;
      OVKEYW{IVTYPE} = 'DISSU'                                     ;
      OVSNAM{IVTYPE} = 'Dissrf';
      OVLNAM{IVTYPE} = 'Wave breaking dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 56;
      OVKEYW{IVTYPE} = 'DISW'                                      ;
      OVSNAM{IVTYPE} = 'Diswcp';
      OVLNAM{IVTYPE} = 'Whitecapping dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
%;
      IVTYPE = 57;
      OVKEYW{IVTYPE} = 'DISM'                                      ;
      OVSNAM{IVTYPE} = 'Dismud';
      OVLNAM{IVTYPE} = 'Fluid mud dissipation';
      OVUNIT{IVTYPE} = 'm2/s';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 0.1;
      OVEXCV{IVTYPE} = -9.;
% MUD special;
      IVTYPE = 58;
      OVKEYW{IVTYPE} = 'WLENMR'                                    ;
      OVSNAM{IVTYPE} = 'Wlenmr';
      OVLNAM{IVTYPE} = 'Average wave length with mud real part';
      OVUNIT{IVTYPE} = 'UL';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0.;
      OVULIM{IVTYPE} = 1000.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 200.;
      OVEXCV{IVTYPE} = -9.;
% % MUD special;
%       IVTYPE = 59;
%       OVKEYW{IVTYPE} = 'WLENMI'                                    ;
%       OVSNAM{IVTYPE} = 'Wlenmi';
%       OVLNAM{IVTYPE} = 'Average wave length with mud imag part';
%       OVUNIT{IVTYPE} = 'UL';
%       OVSVTY{IVTYPE} = 1;
%       OVLLIM{IVTYPE} = 0;
%       OVULIM{IVTYPE} = 1000000000.;
%       OVULIM{IVTYPE} = 9999990000.;
%       OVLEXP{IVTYPE} = 0.;
%       OVHEXP{IVTYPE} = 100000000. ;
%       OVHEXP{IVTYPE} = 999999000. ;
%       OVEXCV{IVTYPE} = -999.;
% MUD special;
      IVTYPE = 59;
      OVKEYW{IVTYPE} = 'KI'                                    ;
      OVSNAM{IVTYPE} = 'ki';
      OVLNAM{IVTYPE} = 'Average wave number with mud imag part';
      OVUNIT{IVTYPE} = 'rad/m';
      OVSVTY{IVTYPE} = 1;
      OVLLIM{IVTYPE} = 0;
      OVULIM{IVTYPE} = 1.;
      OVLEXP{IVTYPE} = 0.;
      OVHEXP{IVTYPE} = 1.;
      OVEXCV{IVTYPE} = -9.;
% MUD special;
      IVTYPE = 60;
      OVKEYW{IVTYPE} = 'MUDL';
      OVSNAM{IVTYPE} = 'Mudlayer';
      OVLNAM{IVTYPE} = 'Mudlayer thickness';
      OVUNIT{IVTYPE} = 'UH';
      OVSVTY{IVTYPE} = 1   ;
      OVLLIM{IVTYPE} = 0   ;% ! -1.E4
      OVULIM{IVTYPE} = 1.E4;
      OVLEXP{IVTYPE} = 0   ;%!-100.
      OVHEXP{IVTYPE} = 100.;
      OVEXCV{IVTYPE} = -99.;

      DAT0.OVKEYW = OVKEYW;
      DAT0.OVSNAM = OVSNAM;
      DAT0.OVLNAM = OVLNAM;
      DAT0.OVUNIT = OVUNIT;
      DAT0.OVSVTY = OVSVTY;
      DAT0.OVLLIM = OVLLIM;
      DAT0.OVULIM = OVULIM;
      DAT0.OVLEXP = OVLEXP;
      DAT0.OVHEXP = OVHEXP;
      DAT0.OVEXCV = OVEXCV;
      
      
%% Restructure per paramter rahther than per property
%% ----------------------

      for ipar=1:length(DAT0.OVEXCV)
       
         parname = DAT0.OVKEYW{ipar};

         valnames = fieldnames(DAT0);

         for ival=1:length(valnames)
         
            valname = valnames{ival};
         
            DAT.(parname).(valname) = DAT0.(valname){ipar};
       
         end
         
      end
      
if     nargout==1
     varargout = {DAT};
elseif nargout==2
     varargout = {DAT,DAT0};
end

%% EOF