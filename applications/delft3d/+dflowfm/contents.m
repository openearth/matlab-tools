%D-Flow FM    toolbox for handling Deltares D-Flow Flexible Mesh (FM) netCDF files
%
% D-Flow FM (Flexible Mesh) is the new (1D, 2D, 3D) unstructured  
% hydrodynamic flow model solver of Deltares, developed within the  
% UNSTRUC project. D-Flow FM is currently in development phase,
% and was as presented at the JONSMOD 2010 conference.
% It can currently solve 1D flow systems a la SOBEK, and 2D flow systems
% a la Delft3D-FLOW and SIMONA's WAQUA/TRIWAQ. A 3D extension is foreseen. 
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at delft3d.sales@deltares.nl or sobek.sales@deltares.nl.
%
% The D-Flow FM netCDF output specification has been published at
% the Deltares wiki: http://public.deltares.nl/display/NETCDF/netCDF.
%
% POST-PROCESSING
%
% Read/plot grid (no time)
%  dflowfm.readNet            - Reads network data of unstructured net.
%  dflowfm.writeNet           - Write network nodes of unstructured net.
%  dflowfm.plotNet            - Plot an unstructured grid.
%  dflowfm.plotNetkml         - Plot an unstructured grid as Google Earth kml file (beta).
%  dflowfm.peri2cell          - turn perimeter matrix into cell
%  dflowfm.readNet2tri        - Reads network and triangulates quadrilaterals and pentagons
%
% Read/plot map (per timestep)
%  dflowfm.readMap            - Reads solution data on an unstructured net.
%  dflowfm.plotMap            - Plot an unstructured map.
%  dflowfm.plotMapkml         - Plot an unstructured map as Google Earth kml file (beta).
%
%  dflowfm.add_CF_coordinates - appends CF coordinates to ncfile
%
% PRE-PROCESSING
%
% Convert delft3d-flow model to  Delft3D-FM
%  dflowfm.mdf2mdu     - convert Delft3D-flow model input to D-Flow FM model input
%  dflowfm.opendap2obs - get list of observation points from netCDF (OPeNDAP) time series collection
%  dflowfm.analyseHis  - validate water levels with netCDF (OPeNDAP) time series collection for time series & t_tide
%  dflowfm.indexHis    - show overview of locations incl. coordinates
%  dflowfm.fillDep     - fill depth values from OPeNDAP data source (single grid or gridset of tiles)
%
% See also: delft3d
