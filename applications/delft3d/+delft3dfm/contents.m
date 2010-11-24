function G = readNet(varargin)
%Delft3D-FM   toolbox for handling Deltares Delft3D-Flexible Mesh (FM) netCDF files
%
% Delft3D-FM (Flexible Mesh) is the new (1D, 2D, 3D) unstructured  
% hydrodynamic flow model solver of Deltares, developed within the  
% UNSTRUC project. Delft3D-FM is currently in development phase,
% and was as presented at the JONSMOD 2010 conference.
% It can currently solve 1D flow systems a la SOBEK, and 2D flow systems
% a la Delft3D-FLOW and SIMONA's WAQUA/TRIWAQ. A 3D extension is foreseen. 
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at delft3d.sales@deltares.nl or sobek.sales@deltares.nl.
%
% The Delft3D-FM netCDF output specification has been published at
% the Deltares wiki: http://public.deltares.nl/display/NETCDF/netCDF.
%
% Read/plot grid (no time)
%  delft3dfm.readNet          - Reads network data of unstructured net.
%  delft3dfm.plotNet          - Plot an unstructured grid.
%  delft3dfm.plotNetkml       - Plot an unstructured grid as Google Earth kml file (beta).
%  delft3dfm.peri2cell        - turn perimeter matrix into cell
%
% Read/plot map (per timestep)
%  delft3dfm.readMap          - Reads solution data on an unstructured net.
%  delft3dfm.plotMap          - Plot an unstructured map.
%  delft3dfm.plotMapkml       - Plot an unstructured map as Google Earth kml file (beta).
%
% Convert delft3d-flow model to  Delft3D-FM
%  delft3dfm.mdf2mdu          - convert Delft3D-flow model input to delft3dfm model input
%  delft3dfm.opendap2obs      - get list of observation points from netCDF (OPeNDAP) time series collection
%  delft3dfm.analyseHis       - validate water levels with netCDF (OPeNDAP) time series collection for time series & t_tide
%
% See also: delft3d
