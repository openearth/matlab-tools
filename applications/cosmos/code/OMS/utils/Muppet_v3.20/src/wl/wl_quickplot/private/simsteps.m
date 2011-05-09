function [OutTxt,OutFig]=simsteps(C,i)
%SIMSTEPS Performs an timestep analysis.
%   SIMSTEPS(NfsTrimFile,i)
%   analyses the i-th dataset written to the
%   Delft3D FLOW file. It returns information on
%   maximum allowed timestep and the used timestep.
%   By default the last dataset written is used.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
