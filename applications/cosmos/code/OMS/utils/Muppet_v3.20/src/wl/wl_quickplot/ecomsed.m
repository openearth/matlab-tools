function Out = ecomsed(cmd,varargin)
%ECOMSED Read an ECOMSED data file.
%   S = ECOMSED('open',FILENAME) opens a ECOMSED data file, scans the
%   contents of the file and returns a structure containing all information
%   necessary to read data from the file. Supported files include 
%   * GCMPLT     files containing time history data for all grid elements, 
%   * GCMTSR     files containing time history data for selected grid elements.
%   * MODEL_GRID files containing physical information for model_grid.
%
%   D = ECOMSED('read',S,QUANT,TIMESTEP) reads data of selected quantity
%   from the file specified using the structure S obtained from an ECOMSED
%   open call. Reads only the data for the specified time step(s); defaults
%   to all time steps.
%
%   D = ECOMSED('read',S,QUANT,TIMESTEP,INDEX1,INDEX2,...) reads only the
%   data with the specified indices. It is like reading all data and
%   subsequently selecting a submatrix: D(TIMESTEP,INDEX1,INDEX2,...).
%
%   Example
%      % open data file
%      S = ecomsed('open','gcmplt.0030');
%      % read water level for third time step
%      WL = ecomsed('read',S,'ARCET',3);
%
% Note: in the GCMPLT file (not in the GCMTSR file) the scalar variables 
%       (e.g. T,S) are written in a matrix with one extra dummy layer. They have 
%       KB layers, where KB is the number of interfaces, while the scalars are 
%       defined in only KB-1 sigma layers. The extra dummy layer KB does not 
%       contain zeros, but values very similar (but not exactly identical) to the 
%       values in the last real layer KB-1.
%
%See web : <a href="http://www.hydroqual.com/ehst_ecomsed.html">www.hydroqual.com/ehst_ecomsed.html</a>
%See also: ECOMSED_INP, ECOMSED_VECTOR_CEN, 

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
