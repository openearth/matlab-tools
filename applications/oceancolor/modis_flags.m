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
% | 1  ATM_FAIL       3  Atmospheric correction failure
% | 2  LAND           3  Pixel is over land
% | 3  PRODWARN          One or more product warnings
% | 4  HIGLINT           High sun glint
% | 5  HILT           3  Observed radiance very high or saturated
% | 6  HISATZEN       3  High sensor view zenith angle
% | 7  COASTZ            Pixel is in shallow water
% | 8  NEGLW           * negative water leaving radiance
% | 9  STRAYLIGHT     3  Straylight contamination is likely
% |10  CLDICE         3  Probable cloud or ice contamination
% |11  COCCOLITH      3  Coccolithofores detected
% |12  TURBIDW           Turbid water detected
% |13  HISOLZEN       3  High solar zenith
% |14  HITAU           * high aearosol concentration
% |15  LOWLW          3  Very low water-leaving radiance (cloud shadow)
% |16  CHLFAIL        3  Derived product algorithm failure
% |17  NAVWARN        3  Navigation quality is reduced
% |18  ABSAER            possible absorbing aerosol (disabled)
% |19  TRICHO            trichodesmium
% |20  MAXAERITER     3* Aerosol iterations exceeded max
% |21  MODGLINT          Moderate sun glint contamination
% |22  CHLWARN        3  Derived product quality is reduced
% |23  ATMWARN        3  Atmospheric correction is suspect
% |24  DARKPIXEL       * dark pixel(Lt - Lt < 0) for any band
% |25  SEAICE            Possible sea ice contamination
% |26  NAVFAIL        3  Bad navigation
% |27  FILTER         3  Pixel rejected by user-defined filter
% |28  SSTWARN           SST quality is reduced
% |29  STTFAIL           SST quality is bad
% |30  HIPOL             High degree of polarization
% |31  PRODFAIL          Derived product failure
% |32  OCEAN           * clear ocean data (no clouds, land or ice)
% +---------------------------------------------------------------------------------- 
% Table indicates flags used in Fourth SeaWiFS Data Reprocessing.
%
%See also: BITAND, SEAWIFS_MASK, SEAWIFS_L2_READ, MERIS_FLAGS, SEAWIFS_FLAGS
 
flags = seawifs_flags(varargin{:});