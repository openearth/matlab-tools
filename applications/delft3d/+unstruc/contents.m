function G = readNet(varargin)
%unstruc   toolbox for plotting Deltares unstruc netCDF files
%
% UNSTRUC is the new (1D, 2D, 3D) unstructured hydrodynamic flow 
% model solver of Deltares. UNSTRUC is currently in development phase.
% Tt can currently solve 1D flow systems a la Sobek, and 2D flow systems
% a la Delft3D-FLOW/SIMONA-WAQUA/TRIWAQ. A 3D extension is foreseen. 
% Beta test versions are available for Deltares partners, please contact the 
% Deltares Software Centre (DSC) at www.delft3d.nl or www.sobek.nl.
%
% The UNSTRUC netCDF output specification has been published at
% the Deltares wiki: http://public.deltares.nl/display/NETCDF/netCDF.
%
% unstruc.readNet          - Reads network data of unstructured net.
% unstruc.plotNet          - Plot an unstructured grid.
% unstruc.plotNet_test     - test unstruc.readNet/unstruc.plotNet
%
% unstruc.peri2cell        - turn perimeter matrix into cell
%
% unstruc.readMap          - Reads solution data on an unstructured net.
% unstruc.plotMap          - Plot an unstructured map.
% unstruc.plotMap_test     - test unstruc.readMap/unstruc.plotMap
%
% See also: delft3d
