function flags = meris_flags(varargin),
%SEAWIFS_FLAGS  select from table with SeaWiFS flag bits and descriptions
%
% T = SEAWIFS_FLAGS(<bit>)
%
% when no bit is supplied, all bits are returned.
%
% returns a struct T with the bit #s, names and properties fo all 24 MERIS flags.
%
% Table 3 from SeaWiFS Ocean_Level-2_Data_Products.pdf <http://oceancolor.gsfc.nasa.gov/VALIDATION/flags.html>
% <http://oceancolor.gsfc.nasa.gov/DOCS/>
% 
% +----------------------------------------------------------------------------------+
% |bit algorithm name    condition indicated                                         |
% | #                                                                                |
% +----------------------------------------------------------------------------------+
% | 1  ATM_FAIL          atmospheric correction failure from invalid inputs          |
% | 2  LAND              land                                                        |
% | 3  BADANC            missing ancillary data                                      |
% | 4  HIGLINT           severe Sun glint                                            |
% | 5  HILT              total radiance above knee in any band                       |
% | 6  HISATZEN          satellite zenith angle above limit                          |
% | 7  COASTZ            shallow water                                               |
% | 8  NEGLW             negative water leaving radiance                             |
% | 9  STRAYLIGHT        stray light contamination                                   |
% |10  CLDICE            clouds and/or ice                                           |
% |11  COCCOLITH         coccolothophore                                             |
% |12  TURBIDW           turbid, case 2 water                                        |
% |13  HISOLZEN          solar zenith angle above limit                              |
% |14  HITAU             high aearosol concentration                                 |
% |15  LOWLW             low water leaving radiance at 555 nm                        |
% |16  CHLFAIL           chlorophyll not calculable                                  |
% |17  NAVWARN           questionable navigation (e.g. tilt angle)                   |
% |18  ABSAER            absorbing aerosol index above treshold                      |
% |19  TRICHO            trichodesmium                                               |
% |20  MAXAERITER        maximum iterations of NIR algoritm                          |
% |21  MODGLINT          moderate Sun glint                                          |
% |22  CHLWARN           chlorophyll out of range                                    |
% |23  ATMWARN           epsilon out of range                                        |
% |24  DARKPIXEL         dark pixel(Lt - Lt < 0) for any band                        |
% |25  SEAICE            sea ice in pixel (based on climatology)                     |
% |26  NAVFAIL           navigation failure condition indicated in nav flags         |
% |27  FILTER            insufficient valid neighbouring pixles for epsilon filtering|
% |28  SSTWARN           sea surface temperature warning flag (MODIS only)           |
% |29  STTFAIL           sea surface temperature failure flag (MODIS only)           |
% |30  SPARE             spare flag                                                  |
% |31  ,,                spare flag                                                  |
% |32  OCEAN             clear ocean data (no clouds, land or ice)                   |
% +----------------------------------------------------------------------------------+
%
%See also: BITAND, SEAWIFS_MASK, SEAWIFS_L2_READ, MERIS_FLAGS
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   flags.bit  = [1:32];
   flags.name = ...
                {'ATM_FAIL',...    %  1
                 'LAND',...        %  2
                 'BADANC',...      %  3
                 'HIGLINT',...     %  4
                 'HILT',...        %  5
                 'HISATZEN',...    %  6
                 'COASTZ',...      %  7
                 'NEGLW',...       %  8
                 'STRAYLIGH',...   %  9
                 'CLDICE',...      % 10
                 'COCCOLITH',...   % 11
                 'TURBIDW',...     % 12
                 'HISOLZEN',...    % 13
                 'HITAU',...       % 14
                 'LOWLW',...       % 15
                 'CHLFAIL',...     % 16
                 'NAVWARN',...     % 17
                 'ABSAER',...      % 18
                 'TRICHO',...      % 19
                 'MAXAERITE',...   % 20
                 'MODGLINT',...    % 21
                 'CHLWARN',...     % 22
                 'ATMWARN',...     % 23
                 'DARKPIXEL',...   % 24
                 'SEAICE',...      % 25
                 'NAVFAIL',...     % 26
                 'FILTER',...      % 27
                 'SSTWARN',...     % 28
                 'STTFAIL',...     % 29
                 'SPARE',...       % 30
                 'SPARE',...       % 31
                 'OCEAN'};         % 32
 
    flags.description = ...
                {'atmospheric correction failure from invalid inputs',...          %  1
                 'land',...                                                        %  2
                 'missing ancillary data',...                                      %  3
                 'severe Sun glint',...                                            %  4
                 'total radiance above knee in any band',...                       %  5
                 'satellite zenith angle above limit',...                          %  6
                 'shallow water',...                                               %  7
                 'negative water leaving radiance',...                             %  8
                 'stray light contamination',...                                   %  9
                 'clouds and/or ice',...                                           % 10
                 'coccolothophore',...                                             % 11
                 'turbid, case 2 water',...                                        % 12
                 'solar zenith angle above limit',...                              % 13
                 'high aearosol concentration',...                                 % 14
                 'low water leaving radiance at 555 nm',...                        % 15
                 'chlorophyll not calculable',...                                  % 16
                 'questionable navigation (e.g. tilt angle)',...                   % 17
                 'absorbing aerosol index above treshold',...                      % 18
                 'trichodesmium',...                                               % 19
                 'maximum iterations of NIR algoritm',...                          % 20
                 'moderate Sun glint',...                                          % 21
                 'chlorophyll out of range',...                                    % 22
                 'epsilon out of range',...                                        % 23
                 'dark pixel(Lt - Lt < 0) for any band',...                        % 24
                 'sea ice in pixel (based on climatology)',...                     % 25
                 'navigation failure condition indicated in nav flags',...         % 26
                 'insufficient valid neighbouring pixles for epsilon filtering',...% 27
                 'sea surface temperature warning flag (MODIS only)',...           % 28
                 'sea surface temperature failure flag (MODIS only)',...           % 29
                 'spare flag',...                                                  % 30
                 'spare flag',...                                                  % 31
                 'clear ocean data (no clouds, land or ice)'};                     % 32   
   %% Extract one bit if requested
   %% -----------------------------
   
   if nargin==1
      bit   = varargin{1};
      index = find(flags.bit==bit);

      flags.bit              = flags.bit(index)           ;
      flags.name             = flags.name{index}          ;
      flags.description      = flags.description{index}   ;
      
   end

%% EOF