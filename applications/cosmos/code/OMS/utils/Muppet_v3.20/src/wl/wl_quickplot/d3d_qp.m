function outdata=d3d_qp(cmd,varargin)
%D3D_QP QuickPlot user interface: plotting interface for Delft3D output data.
%   To start the interface type: d3d_qp
%
%   See also QPFOPEN, QPREAD.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

%VERSION = 2.14.00

error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
