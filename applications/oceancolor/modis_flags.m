function flags = modis_flags(varargin),
%MODIS_FLAGS  select from table with SeaWiFS level 2 and 3 flag bits and descriptions
%
%    T = modis_flags(<bit>)
%
% when no bit is supplied, all bits are returned (modis_flags = seawifs_flags).
%
% returns a struct T with the bit #s, names and properties fo all 24 MERIS flags.
%
% Table 3 from SeaWiFS Ocean_Level-2_Data_Products.pdf <http://oceancolor.gsfc.nasa.gov/VALIDATION/flags.html>
% <http://oceancolor.gsfc.nasa.gov/DOCS/>
% <http://modis-atmos.gsfc.nasa.gov/tools_bit_interpretation.html>
% 
% +---------------------------------------------------------------------------------- 
% |bit algorithm name    condition indicated
% | #                 3 are masked at Level 3 - ocean color processing, * = spare
% +---------------------------------------------------------------------------------- 
% | 0  ATM_FAIL       3  Atmospheric correction failure
% | 1  LAND           3  Pixel is over land
% | 2  PRODWARN          One or more product warnings
% | 3  HIGLINT           High sun glint
% | 4  HILT           3  Observed radiance very high or saturated
% | 5  HISATZEN       3  High sensor view zenith angle
% | 6  COASTZ            Pixel is in shallow water
% | 7  NEGLW           * negative water leaving radiance
% | 8  STRAYLIGHT     3  Straylight contamination is likely
% | 9  CLDICE         3  Probable cloud or ice contamination
% |10  COCCOLITH      3  Coccolithofores detected
% |11  TURBIDW           Turbid water detected
% |12  HISOLZEN       3  High solar zenith
% |13  HITAU           * high aearosol concentration
% |14  LOWLW          3  Very low water-leaving radiance (cloud shadow)
% |15  CHLFAIL        3  Derived product algorithm failure
% |16  NAVWARN        3  Navigation quality is reduced
% |17  ABSAER            possible absorbing aerosol (disabled)
% |18  TRICHO            trichodesmium
% |19  MAXAERITER     3* Aerosol iterations exceeded max
% |20  MODGLINT          Moderate sun glint contamination
% |21  CHLWARN        3  Derived product quality is reduced
% |22  ATMWARN        3  Atmospheric correction is suspect
% |23  DARKPIXEL       * dark pixel(Lt - Lt < 0) for any band
% |24  SEAICE            Possible sea ice contamination
% |25  NAVFAIL        3  Bad navigation
% |26  FILTER         3  Pixel rejected by user-defined filter
% |27  SSTWARN           SST quality is reduced
% |28  STTFAIL           SST quality is bad
% |29  HIPOL             High degree of polarization
% |30  PRODFAIL          Derived product failure
% |31  OCEAN           * clear ocean data (no clouds, land or ice)
% +---------------------------------------------------------------------------------- 
% Table indicates flags used in Fourth SeaWiFS Data Reprocessing.
%
% Note that the bits are ZERO_based, so the bit is not the index in 
% the table, because matlab is 1-based!
%
%See also: BITAND, SEAWIFS_MASK, SEAWIFS_L2_READ, MERIS_FLAGS, SEAWIFS_FLAGS
 
flags = seawifs_flags(varargin{:});