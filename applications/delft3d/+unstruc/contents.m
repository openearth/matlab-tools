function G = readNet(varargin)
%D-Flow   toolbox for handling Deltares unstruc netCDF files
%
% D-Flow is the new (1D, 2D, 3D) unstructured hydrodynamic flow 
% model solver of Deltares, developed within the UNSTRUC project. 
% D-Flow is currently in development phase,
% and was as presented at the JONSMOD 2010 conference.
% It can currently solve 1D flow systems a la SOBEK, and 2D flow systems
% a la Delft3D-FLOW/SIMONA-WAQUA/TRIWAQ. A 3D extension is foreseen. 
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at delft3d.sales@deltares.nl or sobek.sales@deltares.nl.
%
% The D-Flow netCDF output specification has been published at
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
%  unstruc.analyseHis       - validate water levels with OPeNDAP database for time series & t_tide
%
% See also: delft3d
