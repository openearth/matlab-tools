%D-Flow FM    toolbox for mangling Deltares D-Flow Flexible Mesh (FM) files
%
% D-Flow FM (Flexible Mesh) is the new (1D, 2D, 3D) unstructured hydrodynamic
% flow model solver of Deltares, developed within the UNSTRUC project. D-Flow FM
% is currently in development phase, and was published in the <a href="http://dx.doi.org/DOI:10.1007/s10236-011-0423-6">JONSMOD 2010</a>
% special issue. It can currently solve 1D flow systems as SOBEK, and 2D flow 
% systems as Delft3D-FLOW and SIMONA's WAQUA/TRIWAQ. A 3D extension is foreseen.
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at delft3d.sales@deltares.nl or sobek.sales@deltares.nl.
% The D-Flow FM netCDF output specification according to <a href="https://groups.google.com/forum/?fromgroups#!forum/ugrid-interoperability">UGRID</a> has been published at
% the Deltares wiki: http://public.deltares.nl/display/NETCDF/netCDF. For more
% info please see the <a href="http://publicwiki.deltares.nl/display/nghs/Projects-Flexible+Mesh">NGHS wiki</a>.
%
% POST-PROCESSING:  Read/plot grid (no time)
%  dflowfm.readNet            - Reads network data of unstructured net.
%  dflowfm.writeNet           - Write network nodes of unstructured net from curvilinear mesh
%  dflowfm.plotNet            - Plot an unstructured grid (net).
%  dflowfm.plotNetkml         - Plot a net for Google Earth (kml), connecting segments for performance
%  dflowfm.peri2cell          - turn perimeter matrix into cell
%
% POST-PROCESSING:  Read/plot map (per timestep)
%  dflowfm.readMap            - Reads solution data on an unstructured net.
%  dflowfm.plotMap            - Plot an unstructured map.
%  dflowfm.plotMapkml         - Plot an unstructured map as Google Earth kml file (beta).
%  dflowfm.add_CF_coordinates - appends CF coordinates to ncfile
%
% PRE-PROCESSING: Convert delft3d-flow model to  Delft3D-FM
%  dflowfm.mdf2mdu              - convert Delft3D-flow model input to D-Flow FM model input
%  dflowfm.opendap2obs          - get list of observation points from netCDF (OPeNDAP) time series collection
%  dflowfm.analyseHis           - validate waterlevels against netCDF-OPeNDAP data for time series and with t_tide
%  dflowfm.indexHis             - show overview of locations incl. coordinates
%  dflowfm.fillDep              - fill depth values from OPeNDAP data source (single grid or gridset of tiles)
%  dflowfm.obs_file_in_polygon  - construct an obervation file (*_obs.xyn) from all locations within a polygon
%
% See also: delft3d
