function Network=sobek(cmd,varargin)
%SOBEK Read and plot SOBEK topology.
%   Network = SOBEK('open',FileName) opens the files associated with a
%   SOBEK network. The function supports both old SOBEK-RE and new
%   SOBEK-Rural/Urban/River networks. In case of a SOBEK-RE model select
%   the DEFTOP.1 file; in case of a SOBEK-Rural/Urban/River model select
%   the NETWORK.NTW file.
%
%   SOBEK('plot',Network) plots the network in the current axes.
%
%   SOBEK('plot',Network,HisFile,Quantity,Time) plots the specified
%   quantity from the specified HIS-file at the specified time on the
%   network in the current axes.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
