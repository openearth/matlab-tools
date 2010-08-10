function G = readNet(varargin)
%UNSTRUC   toolbox for handling Deltares unstruc netCDF files
%
% UNSTRUC is the new (1D, 2D, 3D) unstructured hydrodynamic flow 
% model solver of Deltares. UNSTRUC is currently in development phase,
% and was as presented at the JONSMOD 2010 conference.
% It can currently solve 1D flow systems a la Sobek, and 2D flow systems
% a la Delft3D-FLOW/SIMONA-WAQUA/TRIWAQ. A 3D extension is foreseen. 
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at www.delft3d.nl or www.sobek.nl.
%
% The UNSTRUC netCDF output specification has been published at
% the Deltares wiki: http://public.deltares.nl/display/NETCDF/netCDF.
%
% Read/plot grid
%  unstruc.readNet          - Reads network data of unstructured net.
%  unstruc.plotNet          - Plot an unstructured grid.
%  unstruc.peri2cell        - turn perimeter matrix into cell
%
% Read/plot map (timestep)
%  unstruc.readMap          - Reads solution data on an unstructured net.
%  unstruc.plotMap          - Plot an unstructured map.
%
% Convert delft3d-flow model to unstruc
%  unstruc.mdf2mdu          - convert Delft3D-flow model input to UNSTRUC model input
%  unstruc.opendap2obs      - get list of observation points from netCDF time series collection
%
% See also: delft3d
