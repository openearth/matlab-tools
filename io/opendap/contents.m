% Tools for handling meta-data and data from an <a href="http://www.opendap.org/">OPeNDAP</a> server
%
% Three implemenations for OPeNDAP servers exist: <a href="http://www.unidata.ucar.edu/projects/THREDDS/">THREDDS</a> and <a href="http://www.opendap.org/download/hyrax.html">HYRAX</a> and <a href="http://www.pydap.org/server.html">pydap</a>.
% This toolbox is most frequencly being used with THREDDS.
%
% A list of operational OPeNDAP servers for marine and coastal data is:
% * Delft: <a href="http://opendap.deltares.nl/">http://opendap.deltares.nl/</a> (THREDDS + HYRAX)
% * Delft: <a href="http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/">http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/</a> (THREDDS test)
% * Rijkswaterstaat: <a href="http://matroos.deltares.nl:8080/thredds/">http://matroos.deltares.nl:8080/thredds/</a> (THREDDS + password)
% * Rijkswaterstaat: <a href="http://matroos.deltares.nl/direct/opendap.html">http://matroos.deltares.nl/direct/opendap.html</a> (HYRAX + password)
% * USGS: <a href="http://coast-enviro.er.usgs.gov/thredds/">http://coast-enviro.er.usgs.gov/thredds/</a> (THREDDS)
% * NOAA: <a href="http://data.nodc.noaa.gov/opendap">http://data.nodc.noaa.gov/opendap</a> (HYRAX)
% * NOAA: <a href="http://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.html">http://dods.ndbc.noaa.gov/thredds/catalog/data/catalog.html</a> (THREDDS)
% * EUMETSAT: <a href="http://gsics.eumetsat.int/thredds/catalog.html">http://gsics.eumetsat.int/thredds/catalog.html</a>
% * Great Lakes: <a href="http://michigan.glin.net/thredds/catalog.html">http://michigan.glin.net/thredds/catalog.html</a>
% * UCAR: <a href="http://motherlode.ucar.edu/thredds/catalog.html">http://motherlode.ucar.edu/thredds/catalog.html</a>
% * 3TU: <a href="http://opendap.tudelft.nl/thredds/catalog.html">http://opendap.tudelft.nl/thredds/catalog.html</a>
%
%   opendap_catalog     - get list of netCDF files (dataset) from opendap catalog
%                         NB: these Dataset urls from an OPeNDAP server can be 
%                         accessed directly with the snctools.
%   opendap_get_cache   - get a local cache of an opendap folder (catalogRef)
%
%See also: snctools
